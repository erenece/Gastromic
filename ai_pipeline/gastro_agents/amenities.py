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
# Yalnızca gerçek alkol servisi olan mekan tipleri — genel restoranlarda false kalır.
_ALCOHOL_KEYWORDS = ("bar", "pub", "meyhane", "meyhanesi")


def infer_amenities(types: str = "", category: str = "", name: str = "") -> tuple[bool, bool]:
    haystack = f"{types} {category} {name}".lower()
    type_tokens = {t.strip().lower() for t in types.split(",") if t.strip()}

    alcohol = bool(type_tokens & _ALCOHOL_TYPES) or any(k in haystack for k in _ALCOHOL_KEYWORDS)
    # Sigara: varsayılan olarak tüm mekanlarda içilebilir kabul edilir.
    smoking = True
    return alcohol, smoking
