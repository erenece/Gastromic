"""Mekan tip/kategori metninden sigara ve alkol sinyallerini çıkarır."""
from __future__ import annotations

_ALCOHOL_TYPES = {
    "bar",
    "cocktail_bar",
    "wine_bar",
    "pub",
    "night_club",
    "brewery",
    "beer_garden",
}
_SMOKING_TYPES = {"hookah_bar", "night_club", "bar"}
_ALCOHOL_KEYWORDS = ("bar", "pub", "bira", "wine", "cocktail", "alkol")
_SMOKING_KEYWORDS = ("sigara", "smoking", "nargile", "hookah", "shisha")


def infer_amenities(types: str = "", category: str = "", name: str = "") -> tuple[bool, bool]:
    haystack = f"{types} {category} {name}".lower()
    type_tokens = {t.strip().lower() for t in types.split(",") if t.strip()}

    alcohol = bool(type_tokens & _ALCOHOL_TYPES) or any(k in haystack for k in _ALCOHOL_KEYWORDS)
    smoking = bool(type_tokens & _SMOKING_TYPES) or any(k in haystack for k in _SMOKING_KEYWORDS)
    return alcohol, smoking
