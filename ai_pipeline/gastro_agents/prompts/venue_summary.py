"""Tek mekan için kişiselleştirilmiş AI özeti promptu."""
from __future__ import annotations

from ..advisory import (
    describe_budget_fit,
    describe_mode_match,
    describe_rating,
)

SYSTEM_PROMPT = """Sen Gastromic'in kişisel gurme asistanısın. Kullanıcıya TEK bir mekan
hakkında, onun tercihlerine göre samimi ve akıcı bir Türkçe öneri yazarsın.

KURALLAR:
- En fazla ~120 kelime; 2–3 kısa paragraf veya akıcı tek paragraf.
- İlçe/mahalle, puan, mekan maliyeti ve mod uyumunu doğal cümlelerle aç.
- ZORUNLU İFADELER bölümündeki puan/bütçe/mod cümlelerini OLDUĞU GİBİ veya çok yakın kullan;
  puanı abartma, düşük puanı yüksek gösterme, mekan maliyetini kullanıcı bütçesiyle karıştırma.
- Puan < 3.5 ise olumsuz veya temkinli dil kullan; 4.5+ ise olumlu dil kullanabilirsin.
- Mekan maliyeti kullanıcının bütçe bandından farklı olabilir — her zaman MEKAN maliyetini anlat.
- Hastalık/hassasiyet, alerjen, alkol ve sigara tercihlerini metnin İÇİNDE anlat.
- Mod uyumlu değilse "tam sana göre" veya "muazzam" gibi abartılı ifadeler KULLANMA.
- Abartma; sadece verilen alanlara dayan."""


def build_prompt(
    profile,
    venue,
    prefs,
    checks: dict,
    review_snippets: list[str] | None = None,
    district: str | None = None,
) -> str:
    busyness = ""
    if venue.busyness is not None:
        busyness = f"  - Yoğunluk: %{int(venue.busyness * 100)}"
        if venue.quietest_hour is not None:
            busyness += f" (en sakin saat {venue.quietest_hour}:00)"

    amenity_bits = []
    if venue.alcohol_served is not None:
        amenity_bits.append(
            f"alkol servisi: {'var' if venue.alcohol_served else 'yok/belirsiz'}"
        )
    if venue.smoking_area is not None:
        amenity_bits.append(
            f"sigara alanı: {'var' if venue.smoking_area else 'belirsiz'}"
        )

    reviews_block = ""
    if review_snippets:
        joined = " | ".join(s.strip() for s in review_snippets if s.strip())[:500]
        if joined:
            reviews_block = f"  - Yorum özetleri: {joined}\n"

    location_hint = ""
    if prefs.location is not None:
        location_hint = f"  - Kullanıcı konumu: {prefs.location.lat:.4f}, {prefs.location.lng:.4f}\n"

    mode_match = checks.get("mode_match", "uyumsuz")
    rating_phrase = describe_rating(venue.rating)
    venue_band, budget_phrase = describe_budget_fit(
        verdict=checks.get("budget_verdict", "ok"),
        user_budget=profile.budget_per_person,
        venue_cost=int(checks.get("estimated_cost") or 0),
    )
    mode_phrase = describe_mode_match(profile.mode, mode_match)

    condition_hint = checks.get("condition")
    condition_block = (
        f"  - Hassasiyet uyarısı metne dahil et: {condition_hint} (içerik analizi tonunda).\n"
        if condition_hint
        else "  - Hassasiyet uyarısı gerekmez.\n"
    )

    allergen_hint = checks.get("allergen")
    allergen_block = (
        f"  - Alerjen uyarısı metne dahil et: listenizdeki {allergen_hint} içeren ürünler olabilir.\n"
        if allergen_hint
        else "  - Alerjen uyarısı gerekmez.\n"
    )

    alcohol_block = ""
    if prefs.alcohol_served:
        if venue.alcohol_served is False:
            alcohol_block = (
                "  - Alkol tercihi var; bu mekan tipinde alkol olmayabilir — metne dahil et.\n"
            )
        elif venue.alcohol_served is True:
            alcohol_block = "  - Alkol tercihi var; alkol servisi mevcut — metne olumlu geçir.\n"

    smoking_block = ""
    if prefs.smoking_area:
        if venue.smoking_area is True:
            smoking_block = "  - Sigara alanı tercihi var; sigara içilebilir — metne dahil et.\n"
        else:
            smoking_block = (
                "  - Sigara alanı tercih ediyor; mekanda teyit etmesini öner — metne dahil et.\n"
            )

    district_line = f"  - İlçe: {district}\n" if district else ""

    return (
        "KULLANICI PROFİLİ:\n"
        f"  - Kullanıcı bütçesi: ~{profile.budget_per_person} TL ({profile.budget_band} bant)\n"
        f"  - Günlük mod: {profile.mode.value}\n"
        f"  - Alerjenler: {', '.join(checks.get('user_allergens') or []) or 'yok'}\n"
        f"  - Hassasiyetler: {', '.join(checks.get('user_conditions') or []) or 'yok'}\n"
        f"  - Alkol servisi istiyor: {'evet' if prefs.alcohol_served else 'hayır'}\n"
        f"  - Sigara alanı istiyor: {'evet' if prefs.smoking_area else 'hayır'}\n"
        f"  - Ziyaret: {prefs.visit_day} {prefs.visit_hour}:00\n"
        + location_hint
        + "\nMEKAN:\n"
        f"  - Ad: {venue.name}\n"
        + district_line
        + f"  - Kategori: {venue.category}\n"
        f"  - Tipler: {venue.types or 'belirtilmedi'}\n"
        f"  - Puan: {venue.rating}\n"
        f"  - Tahmini maliyet (MEKAN): ~{checks.get('estimated_cost', '?')} TL ({venue_band} bant)\n"
        f"  - Bütçe uyumu: {checks.get('budget_verdict', 'ok')}\n"
        f"  - {' · '.join(amenity_bits) or 'imkan bilgisi sınırlı'}\n"
        + reviews_block
        + busyness
        + "\n\n"
        "ZORUNLU İFADELER (birebir veya çok yakın kullan — abartma yok):\n"
        f"  - Puan ifadesi: {rating_phrase}\n"
        f"  - Maliyet ifadesi: {budget_phrase}\n"
        f"  - Mod ifadesi: {mode_phrase}\n\n"
        "METNE DAHİL EDİLECEK UYARILAR (doğal cümlelerle):\n"
        + condition_block
        + allergen_block
        + alcohol_block
        + smoking_block
        + "\n"
        "Bu mekanı kullanıcıya kişiselleştirilmiş, dürüst bir öneri olarak anlat."
    )
