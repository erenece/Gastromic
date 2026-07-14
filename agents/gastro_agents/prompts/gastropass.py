"""GastroPass kültür rehberi promptu — AI beyninin (Gemini) sentez görevi.

Deterministik hattın ürettiği profil + uzlaşı mekanlar + rotayı, sıcak bir Türkçe
gurme rehber metnine çevirir. (Sprint 3 Üye 2 'GastroPass kültür rehberi LLM promptu'
görevinin de tohumu.)
"""
from __future__ import annotations

SYSTEM_PROMPT = """Sen Gastromic'in GastroPass kültür rehberisin. Sana bir kullanıcı
profili, uzlaşıya varılmış mekan listesi ve optimize edilmiş bir rota verilir. Bunları
sıcak, bilgilendirici ve TÜRKÇE bir gurme rehber metnine dönüştürürsün.

KURALLAR:
- Kullanıcının KAÇINDIĞI içerikleri (hard_constraints) asla önerme, önermekle kalma
  övme bile. Bu kırmızı çizgidir.
- Yalnızca sana verilen mekanlardan bahset; yeni mekan/menü UYDURMA (halüsinasyon yok).
- Rota sırasını takip et; her mekan için bir cümle yeterli.
- En fazla ~120 kelime; akıcı, davetkâr, abartısız bir dil.
"""


def build_prompt(profile, venues, route) -> str:
    lines = [f"  - {v.name} ({v.category}) · puan {v.rating}" for v in venues]
    return (
        "KULLANICI PROFİLİ:\n"
        f"  - Bütçe bandı: {profile.budget_band} (~{profile.budget_per_person} TL)\n"
        f"  - Günlük mod: {profile.mode.value}\n"
        f"  - KAÇINILACAKLAR: {', '.join(profile.avoid_ingredients) or 'yok'}\n\n"
        f"UZLAŞI MEKANLAR (rota sırası: {' -> '.join(route.ordered_place_ids)}):\n"
        + "\n".join(lines)
        + f"\n\nToplam rota mesafesi: {route.total_distance_km} km.\n\n"
        "Bu bilgilerle kısa bir GastroPass gurme rehber metni yaz."
    )
