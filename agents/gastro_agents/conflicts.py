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


# Kaçınılan içerik -> mekanda o içeriğe işaret eden anahtar kelimeler.
# ÇİFT DİLLİ olmak ZORUNDA: gerçek veri seti (Google Places) İngilizce isim/tip
# taşır ("Ice Cream Shop", "bakery"); sadece Türkçe token aramak vetoyu gerçek
# veride tamamen etkisiz bırakıyordu (10 adayda 0 eleme ölçüldü).
_ALLERGEN_KEYWORDS: dict[str, list[str]] = {
    "süt": ["süt", "sütlü", "sütçü", "milk", "dairy", "ice cream", "ice_cream", "dondurma",
            "muhallebi", "sütlaç", "yogurt", "yoğurt", "kaymak", "creamery"],
    "peynir": ["peynir", "cheese"],
    "tereyağı": ["tereyağ", "butter"],
    "krema": ["krema", "cream"],
    "yumurta": ["yumurta", "egg", "omlet", "omelet"],
    "buğday": ["buğday", "wheat", "bakery", "pastane", "börek", "pide", "pizza", "pasta",
               "noodle", "simit", "mantı"],
    "gluten": ["gluten", "bakery", "pastane", "börek", "pide", "pizza", "pasta", "ekmek",
               "bread", "simit", "mantı"],
    "arpa": ["arpa", "barley"],
    "çavdar": ["çavdar", "rye"],
    "bal": ["bal ", "honey"],
    "şeker": ["şeker", "dessert", "tatlı", "pastane", "patisserie", "bakery", "candy",
              "chocolate", "çikolata", "baklava"],
    "şerbet": ["şerbet", "baklava", "dessert", "tatlı"],
    "sakatat": ["sakatat", "offal", "işkembe", "kokoreç"],
}

# Bu tipler hayvansal alerjenler için "güvenli sinyal" sayılır (vegan mutfak).
_VEGAN_SAFE_TYPES = ("vegan_restaurant", "vegan restaurant")
_ANIMAL_ALLERGENS = {"süt", "peynir", "tereyağı", "krema", "yumurta"}

# "Glutensiz" mekanı çölyak hastasına yasaklamak tam ters etki olurdu; substring
# eşleşmesi ("gluten" ⊂ "glutensiz") bu tuzağa düşüyordu. Bu ifadeler mekanın o
# alerjeni BİLEREK dışladığını gösterir -> veto iptal.
_SAFE_SIGNALS: dict[str, list[str]] = {
    "gluten": ["glutensiz", "gluten-free", "gluten free"],
    "buğday": ["glutensiz", "gluten-free", "gluten free"],
    "arpa": ["glutensiz", "gluten-free", "gluten free"],
    "çavdar": ["glutensiz", "gluten-free", "gluten free"],
    "süt": ["laktozsuz", "lactose-free", "lactose free", "sütsüz", "dairy-free", "dairy free"],
    "peynir": ["vegan", "dairy-free", "dairy free"],
    "tereyağı": ["vegan", "dairy-free", "dairy free"],
    "krema": ["vegan", "dairy-free", "dairy free"],
    "yumurta": ["vegan", "egg-free", "yumurtasız"],
    "şeker": ["şekersiz", "sugar-free", "sugar free"],
}


def check_allergen(candidate: VenueCandidate, profile: TasteProfile) -> Optional[str]:
    """Kaçınılan içeriğe işaret eden mekan varsa o içeriği döndürür (veto sebebi).

    Ad + kategori + Google Places tipleri üzerinde çift dilli anahtar kelime taraması.
    Vegan mekanlar hayvansal alerjenlerden muaf tutulur (yanlış-pozitif önleme).

    SINIR: Bu hâlâ mekan-düzeyi sezgiseldir, menü-düzeyi değil. Gerçek içerik
    taraması Üye 3'ün yorum/menü RAG'ı ile Sprint 3'te gelecek.
    """
    haystack = f"{candidate.name} {candidate.category} {candidate.types}".lower()
    is_vegan_safe = any(t in haystack for t in _VEGAN_SAFE_TYPES)

    for ingredient in profile.avoid_ingredients:
        key = ingredient.strip().lower()
        if not key:
            continue
        if is_vegan_safe and key in _ANIMAL_ALLERGENS:
            continue  # vegan mutfak: hayvansal alerjen riski yok
        if any(signal in haystack for signal in _SAFE_SIGNALS.get(key, [])):
            continue  # mekan bu alerjeni bilerek dışlıyor (ör. "glutensiz")
        for keyword in _ALLERGEN_KEYWORDS.get(key, [key]):
            if keyword in haystack:
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


# Puan güvenilirliği: 3 yorumla 5.0 alan mekan, 2000 yorumla 4.7 alandan iyi değildir.
# Bayes tipi büzülme ile az-yorumlu puanları önsel ortalamaya çekeriz.
RATING_PRIOR_MEAN = 4.0
RATING_PRIOR_WEIGHT = 50  # kaç yorumluk "önsel" ağırlık


def adjusted_rating(candidate: VenueCandidate) -> float:
    """Yorum sayısına göre güven-düzeltilmiş puan (rating inflation koruması)."""
    rating = candidate.rating
    if rating is None:
        return 0.0
    n = candidate.review_count or 0
    return (rating * n + RATING_PRIOR_MEAN * RATING_PRIOR_WEIGHT) / (n + RATING_PRIOR_WEIGHT)


def taste_score(candidate: VenueCandidate) -> float:
    """Lezzet/otantiklik yumuşak puanı: güven-düzeltilmiş puan × düşük turist-tuzağı."""
    return round(adjusted_rating(candidate) * (1.0 - candidate.tourist_trap_score), 3)


BUSY_DOWNRANK_THRESHOLD = 0.85  # bu yoğunluğun üstü "kalabalık saat" sayılır


def check_busyness(candidate: VenueCandidate, threshold: float = BUSY_DOWNRANK_THRESHOLD):
    """('downrank'|'ok'|'unknown', busyness_0_1) döndürür.

    Yoğunluk bir KONFOR kısıtıdır, sağlık değil: veto etmez, yalnızca puan kırar.
    """
    busyness = candidate.busyness
    if busyness is None:
        return "unknown", None
    if busyness >= threshold:
        return "downrank", busyness
    return "ok", busyness
