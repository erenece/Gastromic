"""Tek mekan için kişiselleştirilmiş AI özeti promptu."""
from __future__ import annotations

SYSTEM_PROMPT = """Sen Gastromic'in kişisel gurme asistanısın. Kullanıcıya TEK bir mekan
hakkında, onun tercihlerine göre kısa ve samimi bir Türkçe öneri yazarsın.

KURALLAR:
- En fazla ~80 kelime; tek paragraf.
- Kullanıcının kaçındığı içerikleri (alerjen/hassasiyet) asla güvenli diye iddia etme.
- Menü içeriği bilmediğin için "glutensiz/sütsüz seçenek var" deme; teyit etmesini öner.
- Mekan alerjen riski taşıyorsa bunu nazikçe belirt ve dikkatli olmasını söyle.
- Bütçe, mod, sigara/alkol tercihi ve yoğunluk bilgisini kullan.
- Abartma; sadece verilen alanlara dayan."""


def build_prompt(profile, venue, prefs, checks: dict) -> str:
    busyness = ""
    if venue.busyness is not None:
        busyness = f"  - Yoğunluk: %{int(venue.busyness * 100)}"
        if venue.quietest_hour is not None:
            busyness += f" (en sakin saat {venue.quietest_hour}:00)"

    amenity_bits = []
    if venue.alcohol_served is not None:
        amenity_bits.append(f"alkol: {'var' if venue.alcohol_served else 'belirsiz/yok'}")
    if venue.smoking_area is not None:
        amenity_bits.append(f"sigara alanı: {'var' if venue.smoking_area else 'belirsiz/yok'}")

    return (
        "KULLANICI PROFİLİ:\n"
        f"  - Bütçe: ~{profile.budget_per_person} TL ({profile.budget_band})\n"
        f"  - Günlük mod: {profile.mode.value}\n"
        f"  - Kaçınılacaklar: {', '.join(profile.avoid_ingredients) or 'yok'}\n"
        f"  - Sigara alanı istiyor: {'evet' if prefs.smoking_area else 'hayır'}\n"
        f"  - Alkol servisi istiyor: {'evet' if prefs.alcohol_served else 'hayır'}\n"
        f"  - Ziyaret: {prefs.visit_day} {prefs.visit_hour}:00\n\n"
        "MEKAN:\n"
        f"  - Ad: {venue.name}\n"
        f"  - Kategori: {venue.category}\n"
        f"  - Puan: {venue.rating}\n"
        f"  - Tahmini maliyet: ~{checks.get('estimated_cost', '?')} TL\n"
        + (f"  - {' · '.join(amenity_bits)}\n" if amenity_bits else "")
        + busyness
        + "\n\n"
        "UYUMLULUK ANALİZİ:\n"
        f"  - Alerjen riski: {checks.get('allergen') or 'tespit edilmedi'}\n"
        f"  - Bütçe durumu: {checks.get('budget_verdict', 'ok')}\n"
        f"  - Mod uyumu: {checks.get('mode_match', 'nötr')}\n"
        f"  - Sigara/alkol uyumu: {checks.get('amenity_verdict', 'ok')}\n\n"
        "Bu mekanı kullanıcıya kişiselleştirilmiş bir öneri olarak anlat."
    )
