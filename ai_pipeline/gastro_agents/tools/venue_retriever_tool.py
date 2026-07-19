"""Gurme RAG Agent tool: `venue_retriever`.

Kaynak önceliği:
  1. data_pipeline/data/processed/places.csv (Üye 1'in gerçek Google Places veri seti)
  2. yoksa gömülü mock mekan listesi (offline/test)

Gerçek CSV şeması (BOM'lu, insan-okur başlıklar):
  Place ID, Place Name, City, Category, Address, Latitude, Longitude, Types,
  Average Rating, Total Review Count, Price Level(PRICE_LEVEL_* enum)

Bu tool YALNIZCA şehir filtresi + turist tuzağı elemesi yapar ve geniş getirir
(recall). Bütçe/alerjen/yoğunluk elemesi bilerek buraya konmaz — o çatışma çözümü
Agent Debate'in (debate.py) işidir.
"""
from __future__ import annotations

import csv

from .. import config
from ..conflicts import estimate_cost
from ..contracts import GeoPoint, TasteProfile, VenueCandidate

# Google Places fiyat enum'u -> 1..4 seviye
_PRICE_ENUM = {
    "PRICE_LEVEL_FREE": 1,
    "PRICE_LEVEL_INEXPENSIVE": 1,
    "PRICE_LEVEL_MODERATE": 2,
    "PRICE_LEVEL_EXPENSIVE": 3,
    "PRICE_LEVEL_VERY_EXPENSIVE": 4,
}

# Türkçe karakterleri sadeleştirerek şehir karşılaştırması (İstanbul == Istanbul)
_TR_FOLD = str.maketrans({
    "İ": "i", "I": "i", "ı": "i", "Ş": "s", "ş": "s", "Ğ": "g", "ğ": "g",
    "Ü": "u", "ü": "u", "Ö": "o", "ö": "o", "Ç": "c", "ç": "c",
})

_MOCK_VENUES: list[dict] = [
    {"place_id": "mock-1", "name": "Çiya Sofrası", "city": "İstanbul", "category": "organik,ev yemeği", "rating": 4.6, "review_count": 12000, "price_level": 2, "lat": 40.9903, "lng": 29.0270},
    {"place_id": "mock-2", "name": "Zübeyir Ocakbaşı", "city": "İstanbul", "category": "ızgara,kebap", "rating": 4.5, "review_count": 9000, "price_level": 3, "lat": 41.0362, "lng": 28.9787},
    {"place_id": "mock-3", "name": "Bi Nevi Deli", "city": "İstanbul", "category": "vejetaryen,vegan", "rating": 4.7, "review_count": 3500, "price_level": 2, "lat": 40.9887, "lng": 29.0245},
    {"place_id": "mock-4", "name": "Karaköy Lokantası", "city": "İstanbul", "category": "meze,balık", "rating": 4.6, "review_count": 15000, "price_level": 3, "lat": 41.0256, "lng": 28.9741},
    {"place_id": "mock-5", "name": "Tarihi Turist Kebap", "city": "İstanbul", "category": "kebap,turistik", "rating": 3.4, "review_count": 22000, "price_level": 3, "lat": 41.0055, "lng": 28.9769},
    {"place_id": "mock-6", "name": "Emin Usta Burger", "city": "İstanbul", "category": "burger,sokak lezzeti", "rating": 4.3, "review_count": 2000, "price_level": 1, "lat": 41.0430, "lng": 29.0046},
    {"place_id": "mock-7", "name": "Bebek Sütlü Tatlıcısı", "city": "İstanbul", "category": "tatlı,sütlü", "rating": 4.4, "review_count": 3000, "price_level": 2, "lat": 41.0776, "lng": 29.0433},
]

_PLACES_CACHE: dict[str, list[dict]] = {}


def reset_cache() -> None:
    _PLACES_CACHE.clear()


def _fold(value: str) -> str:
    return (value or "").translate(_TR_FOLD).strip().lower()


def _to_float(v) -> float | None:
    try:
        return None if v in (None, "") else float(v)
    except (TypeError, ValueError):
        return None


def _to_int(v) -> int | None:
    try:
        return None if v in (None, "") else int(float(v))
    except (TypeError, ValueError):
        return None


def _price_level(raw) -> int | None:
    if raw in (None, ""):
        return None
    key = str(raw).strip().upper()
    if key in _PRICE_ENUM:
        return _PRICE_ENUM[key]
    return _to_int(raw)


def _pick(row: dict, *keys):
    for key in keys:
        if key in row and row[key] not in (None, ""):
            return row[key]
    return None


def _normalize(row: dict) -> dict:
    """Gerçek CSV başlıklarını da mock anahtarlarını da tek şemaya indirger."""
    return {
        "place_id": _pick(row, "Place ID", "place_id", "id"),
        "name": _pick(row, "Place Name", "name", "displayName") or "Bilinmeyen",
        "city": _pick(row, "City", "city") or "",
        "category": _pick(row, "Category", "category", "primaryType") or "",
        "types": _pick(row, "Types", "types") or "",
        "rating": _pick(row, "Average Rating", "rating"),
        "review_count": _pick(row, "Total Review Count", "review_count", "userRatingCount"),
        "price_level": _price_level(_pick(row, "Price Level", "price_level", "priceLevel")),
        "lat": _pick(row, "Latitude", "lat", "latitude"),
        "lng": _pick(row, "Longitude", "lng", "longitude"),
    }


def _load_rows() -> list[dict] | None:
    """Gerçek places.csv'yi okur (BOM güvenli, önbellekli). Yoksa None."""
    path = config.PLACES_CSV
    key = str(path)
    if key in _PLACES_CACHE:
        return _PLACES_CACHE[key]
    if not path.exists():
        return None
    with open(path, "r", encoding="utf-8-sig", newline="") as f:
        rows = [_normalize(r) for r in csv.DictReader(f)]
    _PLACES_CACHE[key] = rows
    return rows


def _tourist_trap_score(rating, review_count) -> float:
    """Çok yorum + düşük puan => turist tuzağı sinyali (0..1)."""
    r = _to_float(rating)
    n = _to_int(review_count)
    if r is None or n is None:
        return 0.0
    score = 0.0
    if n > 10000:
        score += 0.5
    if r < 4.0:
        score += 0.5
    return round(min(score, 1.0), 2)


def _category_match(profile: TasteProfile, haystack: str) -> bool:
    text = (haystack or "").lower()
    return any(pc.split()[0].lower() in text for pc in profile.preferred_categories)


def retrieve_venues(
    profile: TasteProfile,
    city: str = "İstanbul",
    limit: int = 10,
    source: str = "auto",
) -> list[VenueCandidate]:
    """source: 'auto' (csv varsa csv, yoksa mock) | 'csv' | 'mock'."""
    rows = None if source == "mock" else _load_rows()
    if rows is None:
        if source == "csv":
            return []
        rows = [_normalize(r) for r in _MOCK_VENUES]

    wanted_city = _fold(city)
    candidates: list[VenueCandidate] = []
    for row in rows:
        # şehir filtresi (7 şehirlik veri setinde şart)
        if wanted_city and row["city"] and _fold(row["city"]) != wanted_city:
            continue

        category = row["category"]
        searchable = f"{category} {row['types']}"
        trap = _tourist_trap_score(row["rating"], row["review_count"])
        if trap >= 0.8 or "turistik" in category.lower():
            continue

        lat, lng = _to_float(row["lat"]), _to_float(row["lng"])
        matched = _category_match(profile, searchable)
        candidates.append(
            VenueCandidate(
                place_id=str(row["place_id"] or row["name"]),
                name=row["name"],
                category=category,
                types=row["types"],
                rating=_to_float(row["rating"]),
                review_count=_to_int(row["review_count"]),
                price_level=row["price_level"],
                location=GeoPoint(lat=lat, lng=lng) if lat is not None and lng is not None else None,
                tourist_trap_score=trap,
                estimated_cost_per_person=estimate_cost(row["price_level"]),
                match_reason=(
                    f"{profile.mode.value} moduna uygun · tuzak skoru {trap}"
                    if matched
                    else f"otantik alternatif · tuzak skoru {trap}"
                ),
            )
        )

    def _sort_key(c: VenueCandidate):
        text = f"{c.category}".lower()
        return (0 if _category_match(profile, text) else 1, c.tourist_trap_score, -(c.rating or 0.0))

    candidates.sort(key=_sort_key)
    return candidates[:limit]
