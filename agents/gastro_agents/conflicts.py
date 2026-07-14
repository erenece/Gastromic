"""Bütçe / lezzet / alerjen çatışma kuralları (Sprint 2, Görev 3).

Öncelik sırası (yüksekten düşüğe) — Agent Debate bunu uygular:
  1. Alerjen / sağlık hassasiyeti  -> KATI VETO (pazarlıksız)
  2. Bütçe tavanı                  -> aşırı aşımda veto, hafif aşımda downrank
  3. Lezzet / otantiklik           -> yumuşak puan (sıralama)
"""
from __future__ import annotations

from typing import Optional

from .contracts import TasteProfile, VenueCandidate

# price_level (1-4) -> kişi başı yaklaşık maliyet (TL, İstanbul kabası)
PRICE_LEVEL_TL: dict[int, int] = {1: 150, 2: 400, 3: 900, 4: 1800}

BUDGET_VETO_FACTOR = 1.5  # bütçenin bu katını aşan mekan elenir


def estimate_cost(price_level: Optional[int]) -> int:
    return PRICE_LEVEL_TL.get(price_level or 2, 400)


def check_allergen(candidate: VenueCandidate, profile: TasteProfile) -> Optional[str]:
    """Kaçınılan bir içerik mekan adı/kategorisinde geçiyorsa onu döndürür (veto sebebi).

    Sprint 1/2 sezgisel: gerçek menü taraması (Üye 3'ün RAG'ı) Sprint 3'te bunu
    içerik düzeyine taşıyacak. Şimdilik ad+kategori üzerinden kaba eşleşme.
    """
    haystack = f"{candidate.name} {candidate.category}".lower()
    for ingredient in profile.avoid_ingredients:
        token = ingredient.strip().lower()
        if token and token in haystack:
            return ingredient
    return None


def check_budget(candidate: VenueCandidate, profile: TasteProfile) -> tuple[str, int]:
    """('veto'|'downrank'|'ok', tahmini_maliyet) döndürür."""
    cost = candidate.estimated_cost_per_person or estimate_cost(candidate.price_level)
    budget = profile.budget_per_person
    if cost > budget * BUDGET_VETO_FACTOR:
        return "veto", cost
    if cost > budget:
        return "downrank", cost
    return "ok", cost


def taste_score(candidate: VenueCandidate) -> float:
    """Lezzet/otantiklik yumuşak puanı: yüksek puan × düşük turist-tuzağı."""
    rating = candidate.rating or 0.0
    return round(rating * (1.0 - candidate.tourist_trap_score), 3)
