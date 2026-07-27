from __future__ import annotations

from ..contracts import DailyMode, TasteProfile, UserPreferences

# Sağlık hassasiyeti -> kaçınılacak içerikler (Arayüze göre güncellendi)
_SENSITIVITY_MAP: dict[str, list[str]] = {
    "laktoz intoleransı": ["süt", "peynir", "tereyağı", "krema"],
    "fruktoz intoleransı": ["bal", "yüksek fruktozlu şurup"],
    "çölyak": ["buğday", "gluten", "arpa", "çavdar"],
    "gluten hassasiyeti": ["buğday", "gluten"],
    "diyabet": ["şeker", "şerbet"],
    "gut": ["sakatat"],
    "hipertansiyon": ["aşırı tuz"],
    "fenilketonüri": ["protein", "et", "süt", "yumurta", "kuruyemiş", "glutensiz unlar"], # PKU için kaçınılacak temel yüksek fenilalaninli gıdalar
    "favizm": ["bakla", "yaban mersini"], # Favizm (G6PD eksikliği) için kritik kaçınılacak gıda
}

# Günlük mod -> tercih edilen mekan kategorileri (özet / debate)
_MODE_CATEGORIES: dict[DailyMode, list[str]] = {
    DailyMode.SPORCU: ["protein bowl", "ızgara", "salata", "sağlıklı"],
    DailyMode.VEJETARYEN: ["vejetaryen", "vegan", "meze", "sebze"],
    DailyMode.ORGANIK: ["organik", "çiftlik", "farm-to-table", "kahvaltı"],
    DailyMode.KACAMAK: ["burger", "tatlı", "pizza", "kebap", "sokak lezzeti"],
}

# Mod eşleşmesi — mekan ad/kategori/Google tiplerinde aranan anahtar kelimeler
MODE_MATCH_KEYWORDS: dict[DailyMode, list[str]] = {
    DailyMode.SPORCU: [
        "protein",
        "bowl",
        "ızgara",
        "izgara",
        "grill",
        "steakhouse",
        "salata",
        "salad",
        "sağlıklı",
        "saglikli",
        "healthy",
        "fit",
        "kebap",
        "kebab",
    ],
    DailyMode.VEJETARYEN: [
        "vejetaryen",
        "vegetarian",
        "vegan",
        "vegan_restaurant",
        "meze",
        "sebze",
        "vegetable",
        "salad",
    ],
    DailyMode.ORGANIK: [
        "organik",
        "organic",
        "çiftlik",
        "farm",
        "farm-to-table",
        "kahvaltı",
        "breakfast",
        "brunch",
        "natural",
    ],
    DailyMode.KACAMAK: [
        "burger",
        "hamburger",
        "tatlı",
        "tatli",
        "dessert",
        "pizza",
        "kebap",
        "kebab",
        "kebabçı",
        "kebapçı",
        "kebabci",
        "kebapci",
        "lahmacun",
        "pide",
        "adana",
        "urfa",
        "sokak",
        "street",
        "fast food",
        "fast_food",
        "döner",
        "doner",
        "tantuni",
        "kokoreç",
        "kokorec",
        "waffle",
        "patisserie",
        "bakery",
        "pastane",
        "ice cream",
        "ice_cream",
        "dondurma",
        "çiğ köfte",
        "cig kofte",
        "snack",
    ],
}


def budget_band(tl: int) -> str:
    if tl < 300:
        return "ekonomik"
    if tl < 800:
        return "orta"
    if tl < 1500:
        return "üst-orta"
    return "premium"


def normalize_preferences(prefs: UserPreferences) -> TasteProfile:
    """UserPreferences -> TasteProfile (deterministik)."""
    # Alerjiler listesindeki girdileri temizle ve doğrudan kaçınılacaklara ekle
    avoid: list[str] = [a.strip().lower() for a in prefs.allergens if a.strip()]
    flags: list[str] = []

    for s in prefs.sensitivities:
        key = s.strip().lower()
        if not key:
            continue
        avoid.extend(_SENSITIVITY_MAP.get(key, []))
        flags.append(key.replace(" ", "_"))

    # tekilleştir, sırayı koru
    avoid = list(dict.fromkeys(a.lower() for a in avoid))
    flags = list(dict.fromkeys(flags))
    hard = [f"içermez: {a}" for a in avoid]

    band = budget_band(prefs.budget_per_person)
    return TasteProfile(
        budget_band=band,
        budget_per_person=prefs.budget_per_person,
        dietary_flags=flags,
        avoid_ingredients=avoid,
        preferred_categories=_MODE_CATEGORIES.get(prefs.daily_mode, []),
        mode=prefs.daily_mode,
        mode_summary=f"{prefs.daily_mode.value} modu · {band} bütçe",
        hard_constraints=hard,
        requires_smoking_area=prefs.smoking_area,
        requires_alcohol=prefs.alcohol_served,
    )