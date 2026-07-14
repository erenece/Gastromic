"""Gurme RAG Agent tool: `venue_retriever`.

Sprint 1/2 sürümü (iskelet): data_pipeline/data/processed/places.csv varsa oradan
naive filtre yapar; yoksa gömülü mock mekan listesini kullanır. Gerçek RAG
(embedding + ChromaDB benzerlik araması, Üye 3) Sprint 2/3'te bu tool'un arkasına
takılacaktır.

Bu tool YALNIZCA turist tuzağını eler ve geniş getirir (recall). Bütçe/alerjen
elemesi bilerek buraya konmaz — o çatışma çözümü Agent Debate'in (debate.py) işidir.
"""
from __future__ import annotations

import csv

from ..conflicts import estimate_cost
from ..config import PLACES_CSV
from ..contracts import GeoPoint, TasteProfile, VenueCandidate

# CSV yokken kullanılan gömülü örnek mekanlar (İstanbul, gerçekçi koordinatlar)
_MOCK_VENUES: list[dict] = [
    {"place_id": "mock-1", "name": "Çiya Sofrası", "category": "organik,ev yemeği", "rating": 4.6, "review_count": 12000, "price_level": 2, "lat": 40.9903, "lng": 29.0270},
    {"place_id": "mock-2", "name": "Zübeyir Ocakbaşı", "category": "ızgara,kebap", "rating": 4.5, "review_count": 9000, "price_level": 3, "lat": 41.0362, "lng": 28.9787},
    {"place_id": "mock-3", "name": "Bi Nevi Deli", "category": "vejetaryen,vegan", "rating": 4.7, "review_count": 3500, "price_level": 2, "lat": 40.9887, "lng": 29.0245},
    {"place_id": "mock-4", "name": "Karaköy Lokantası", "category": "meze,balık", "rating": 4.6, "review_count": 15000, "price_level": 3, "lat": 41.0256, "lng": 28.9741},
    {"place_id": "mock-5", "name": "Tarihi Turist Kebap", "category": "kebap,turistik", "rating": 3.4, "review_count": 22000, "price_level": 3, "lat": 41.0055, "lng": 28.9769},
    {"place_id": "mock-6", "name": "Emin Usta Burger", "category": "burger,sokak lezzeti", "rating": 4.3, "review_count": 2000, "price_level": 1, "lat": 41.0430, "lng": 29.0046},
    {"place_id": "mock-7", "name": "Bebek Sütlü Tatlıcısı", "category": "tatlı,sütlü", "rating": 4.4, "review_count": 3000, "price_level": 2, "lat": 41.0776, "lng": 29.0433},
]


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


def _category_match(profile: TasteProfile, category: str) -> bool:
    cat = (category or "").lower()
    return any(pc.split()[0].lower() in cat for pc in profile.preferred_categories)


def _geo(row) -> GeoPoint | None:
    lat = _to_float(row.get("lat") or row.get("latitude"))
    lng = _to_float(row.get("lng") or row.get("longitude"))
    return GeoPoint(lat=lat, lng=lng) if lat is not None and lng is not None else None


def _load_csv_rows() -> list[dict] | None:
    if not PLACES_CSV.exists():
        return None
    with open(PLACES_CSV, "r", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def retrieve_venues(profile: TasteProfile, city: str = "İstanbul", limit: int = 10) -> list[VenueCandidate]:
    rows = _load_csv_rows()
    source = rows if rows else _MOCK_VENUES

    candidates: list[VenueCandidate] = []
    for row in source:
        name = row.get("name") or row.get("displayName") or "Bilinmeyen"
        category = row.get("category") or row.get("primaryType") or ""
        rating = row.get("rating")
        review_count = row.get("review_count") or row.get("userRatingCount")
        price_level = _to_int(row.get("price_level") or row.get("priceLevel"))

        trap = _tourist_trap_score(rating, review_count)
        # turist tuzağını ele (debate ÖNCESİ tek eleme burada)
        if trap >= 0.8 or "turistik" in category.lower():
            continue

        matched = _category_match(profile, category)
        candidates.append(
            VenueCandidate(
                place_id=str(row.get("place_id") or row.get("id") or name),
                name=name,
                category=category,
                rating=_to_float(rating),
                review_count=_to_int(review_count),
                price_level=price_level,
                location=_geo(row),
                tourist_trap_score=trap,
                estimated_cost_per_person=estimate_cost(price_level),
                match_reason=(
                    f"{profile.mode.value} moduna uygun · tuzak skoru {trap}"
                    if matched
                    else f"otantik alternatif · tuzak skoru {trap}"
                ),
            )
        )

    def _sort_key(c: VenueCandidate):
        return (0 if _category_match(profile, c.category) else 1, c.tourist_trap_score, -(c.rating or 0.0))

    candidates.sort(key=_sort_key)
    return candidates[:limit]
