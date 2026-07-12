"""Gurme RAG Agent tool: `venue_retriever`.

Sprint 1 sürümü (iskelet): data_pipeline/data/processed/places.csv varsa oradan
naive filtre yapar; yoksa gömülü mock mekan listesini kullanır. Gerçek RAG
(embedding + ChromaDB benzerlik araması, Üye 3) Sprint 2'de bu tool'un arkasına
takılacaktır. Turist-tuzağı elemesi basit bir sezgiyle hesaplanır.
"""
from __future__ import annotations

import csv

from ..config import PLACES_CSV
from ..contracts import TasteProfile, VenueCandidate

# CSV yokken kullanılan gömülü örnek mekanlar (İstanbul)
_MOCK_VENUES: list[dict] = [
    {"place_id": "mock-1", "name": "Çiya Sofrası", "category": "organik,ev yemeği", "rating": 4.6, "review_count": 12000, "price_level": 2},
    {"place_id": "mock-2", "name": "Zübeyir Ocakbaşı", "category": "ızgara,kebap", "rating": 4.5, "review_count": 9000, "price_level": 3},
    {"place_id": "mock-3", "name": "Bi Nevi Deli", "category": "vejetaryen,vegan", "rating": 4.7, "review_count": 3500, "price_level": 2},
    {"place_id": "mock-4", "name": "Karaköy Lokantası", "category": "meze,balık", "rating": 4.6, "review_count": 15000, "price_level": 3},
    {"place_id": "mock-5", "name": "Tarihi Turist Kebap", "category": "kebap,turistik", "rating": 3.4, "review_count": 22000, "price_level": 3},
    {"place_id": "mock-6", "name": "Emin Usta Burger", "category": "burger,sokak lezzeti", "rating": 4.3, "review_count": 2000, "price_level": 1},
]


def _to_float(v) -> float | None:
    try:
        if v in (None, ""):
            return None
        return float(v)
    except (TypeError, ValueError):
        return None


def _to_int(v) -> int | None:
    try:
        if v in (None, ""):
            return None
        return int(float(v))
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


def _load_csv_rows() -> list[dict] | None:
    if not PLACES_CSV.exists():
        return None
    with open(PLACES_CSV, "r", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def retrieve_venues(profile: TasteProfile, city: str = "İstanbul", limit: int = 5) -> list[VenueCandidate]:
    rows = _load_csv_rows()
    source = rows if rows else _MOCK_VENUES

    candidates: list[VenueCandidate] = []
    for row in source:
        name = row.get("name") or row.get("displayName") or "Bilinmeyen"
        category = row.get("category") or row.get("primaryType") or ""
        rating = row.get("rating")
        review_count = row.get("review_count") or row.get("userRatingCount")
        price_level = row.get("price_level") or row.get("priceLevel")

        trap = _tourist_trap_score(rating, review_count)
        # turist tuzağını ele
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
                price_level=_to_int(price_level),
                tourist_trap_score=trap,
                match_reason=(
                    f"{profile.mode.value} moduna uygun · tuzak skoru {trap}"
                    if matched
                    else f"otantik alternatif · tuzak skoru {trap}"
                ),
            )
        )

    # sıralama: mod-eşleşmesi önce, sonra düşük tuzak, sonra yüksek puan
    def _sort_key(c: VenueCandidate):
        return (0 if _category_match(profile, c.category) else 1, c.tourist_trap_score, -(c.rating or 0.0))

    candidates.sort(key=_sort_key)
    return candidates[:limit]
