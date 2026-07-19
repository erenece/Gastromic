"""Profiler Agent tool: `preference_normalizer`.

Kullanıcı tercihlerini deterministik olarak yapılandırılmış TasteProfile'a çevirir.
LLM'den bağımsızdır; alerjen/hassasiyet -> kaçınılacak içerik eşlemesi burada yapılır.
"""
from __future__ import annotations

from ..contracts import DailyMode, TasteProfile, UserPreferences

# Sağlık hassasiyeti -> kaçınılacak içerikler
_SENSITIVITY_MAP: dict[str, list[str]] = {
    "laktoz intoleransı": ["süt", "peynir", "tereyağı", "krema"],
    "çölyak": ["buğday", "gluten", "arpa", "çavdar"],
    "gluten hassasiyeti": ["buğday", "gluten"],
    "fruktoz intoleransı": ["bal", "yüksek fruktozlu şurup"],
    "diyabet": ["şeker", "şerbet"],
    "gut": ["sakatat"],
    "hipertansiyon": ["aşırı tuz"],
}

# Günlük mod -> tercih edilen mekan kategorileri
_MODE_CATEGORIES: dict[DailyMode, list[str]] = {
    DailyMode.SPORCU: ["protein bowl", "ızgara", "salata", "sağlıklı"],
    DailyMode.VEJETARYEN: ["vejetaryen", "vegan", "meze", "sebze"],
    DailyMode.ORGANIK: ["organik", "çiftlik", "farm-to-table", "kahvaltı"],
    DailyMode.KACAMAK: ["burger", "tatlı", "pizza", "sokak lezzeti"],
}


def _budget_band(tl: int) -> str:
    if tl < 300:
        return "ekonomik"
    if tl < 800:
        return "orta"
    if tl < 1500:
        return "üst-orta"
    return "premium"


def normalize_preferences(prefs: UserPreferences) -> TasteProfile:
    """UserPreferences -> TasteProfile (deterministik)."""
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

    band = _budget_band(prefs.budget_per_person)
    return TasteProfile(
        budget_band=band,
        budget_per_person=prefs.budget_per_person,
        dietary_flags=flags,
        avoid_ingredients=avoid,
        preferred_categories=_MODE_CATEGORIES.get(prefs.daily_mode, []),
        mode=prefs.daily_mode,
        mode_summary=f"{prefs.daily_mode.value} modu · {band} bütçe",
        hard_constraints=hard,
    )
