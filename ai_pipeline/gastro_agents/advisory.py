"""AI özet metnine eklenecek tercih uyarıları — yalnızca öneri metninde kullanılır."""
from __future__ import annotations

from .conflicts import check_allergen
from .contracts import DailyMode, TasteProfile, VenueCandidate
from .tools.preference_tool import (
    MODE_MATCH_KEYWORDS,
    _SENSITIVITY_MAP,
    budget_band,
)


def compute_mode_match(
    candidate: VenueCandidate, profile: TasteProfile
) -> tuple[str, str | None]:
    """Mekan ad/kategori/tiplerinde mod anahtar kelimesi var mı?

    Returns:
        ("uyumlu", matched_keyword) veya ("uyumsuz", None)
    """
    haystack = f"{candidate.name} {candidate.category} {candidate.types}".lower()
    keywords = MODE_MATCH_KEYWORDS.get(profile.mode, [])
    for keyword in keywords:
        token = keyword.strip().lower()
        if token and token in haystack:
            return "uyumlu", token
    return "uyumsuz", None


def describe_rating(rating: float | None) -> str:
    if rating is None:
        return "puanı belirsiz"
    if rating >= 4.5:
        return f"{rating:.1f} gibi çok güçlü bir puanı"
    if rating >= 4.0:
        return f"{rating:.1f} gibi iyi bir puanı"
    if rating >= 3.5:
        return f"{rating:.1f} puanı"
    if rating >= 3.0:
        return f"{rating:.1f} gibi ortalama bir puanı"
    return f"{rating:.1f} gibi düşük bir puanı"


def describe_budget_fit(
    *,
    verdict: str,
    user_budget: int,
    venue_cost: int,
) -> tuple[str, str]:
    """(mekan_bütçe_bandı, kullanıcıya yönelik cümle parçası)"""
    band = budget_band(venue_cost)
    cost_text = f"~{venue_cost} TL ({band} bütçe seviyesi)"

    if verdict == "ok":
        fit = f"mekan maliyeti bütçene ({user_budget} TL) uygun görünüyor"
    elif verdict == "downrank":
        fit = (
            f"mekan maliyeti bütçenden ({user_budget} TL) biraz yüksek olabilir"
        )
    else:
        fit = f"mekan maliyeti bütçeni ({user_budget} TL) aşabilir"

    return band, f"{cost_text}; {fit}"


def describe_mode_match(mode: DailyMode, match: str, reason: str | None = None) -> str:
    label = mode.value
    if match == "uyumlu":
        return f"{label} moduna uygun görünüyor"
    return f"{label} modunu tam karşılamayabilir"


def _mini_profile(avoid: list[str]) -> TasteProfile:
    return TasteProfile(
        budget_band="orta",
        budget_per_person=500,
        avoid_ingredients=avoid,
        mode=DailyMode.ORGANIK,
    )


def check_user_allergen(candidate: VenueCandidate, allergens: list[str]) -> str | None:
    cleaned = [a.strip().lower() for a in allergens if a.strip()]
    if not cleaned:
        return None
    return check_allergen(candidate, _mini_profile(cleaned))


def check_user_condition(
    candidate: VenueCandidate, sensitivities: list[str]
) -> str | None:
    for raw in sensitivities:
        key = raw.strip().lower()
        if not key:
            continue
        mapped = _SENSITIVITY_MAP.get(key, [])
        if not mapped:
            continue
        if check_allergen(candidate, _mini_profile(mapped)):
            return raw.strip()
    return None


def build_advisory_clauses(
    *,
    allergen: str | None,
    condition: str | None,
    mode_match: str,
    profile: TasteProfile,
    requires_alcohol: bool,
    alcohol_served: bool | None,
    requires_smoking: bool,
    smoking_available: bool | None,
) -> list[str]:
    clauses: list[str] = []

    if condition:
        clauses.append(
            f"İçerik analizine göre mutfağında {condition} açısından dikkat gerektiren "
            "ürünler olabilir; hassasiyetin varsa sipariş verirken dikkatli olmanı öneririm."
        )

    if allergen:
        clauses.append(
            f"Alerjen listenizdeki {allergen} içeren ürünler bu mekanda bulunabilir — "
            "menüyü teyit etmeni öneririm."
        )

    if mode_match != "uyumlu":
        clauses.append(
            f"Bu mekan günlük modunuzu ({profile.mode.value}) tam karşılamayabilir."
        )

    if requires_alcohol and alcohol_served is False:
        clauses.append(
            "Alkol servisi tercih ediyorsan bu mekan tipinde genelde alkol sunulmayabilir."
        )
    elif requires_alcohol and alcohol_served is True:
        clauses.append("Alkol servisi mevcut görünüyor.")

    if requires_smoking and smoking_available is True:
        clauses.append("Sigara içilebilir alan bulunuyor.")
    elif requires_smoking and smoking_available is False:
        clauses.append("Sigara alanı konusunda menü veya mekanı teyit etmeni öneririm.")

    return clauses


def build_fallback_summary(
    *,
    name: str,
    district: str | None,
    rating: float | None,
    budget_verdict: str,
    user_budget: int,
    venue_cost: int,
    mode: DailyMode,
    mode_match: str,
    mode_match_reason: str | None,
) -> str:
    location = f"{district}'te bulunan " if district else ""
    rating_text = describe_rating(rating)
    _, budget_text = describe_budget_fit(
        verdict=budget_verdict,
        user_budget=user_budget,
        venue_cost=venue_cost,
    )
    mode_text = describe_mode_match(mode, mode_match, mode_match_reason)

    opening = f"{location}{name}, {rating_text} var ve {budget_text}."
    if mode_match == "uyumlu":
        closing = f"{mode_text.capitalize()}; keyifli bir ziyaret olabilir."
    else:
        closing = f"Ancak {mode_text.lower()}."
    return f"{opening} {closing}"


def enrich_ai_summary(base: str, clauses: list[str]) -> str:
    if not base.strip():
        return " ".join(clauses)
    if not clauses:
        return base.strip()

    text = base.strip()
    lower = text.lower()
    missing = [c for c in clauses if c.lower() not in lower]
    if not missing:
        return text
    return f"{text} {' '.join(missing)}"
