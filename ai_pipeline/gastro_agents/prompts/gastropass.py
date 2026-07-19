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
- Kullanıcının KAÇINDIĞI içerikleri (hard_constraints) asla önerme, övme.
- ⛔ EN ÖNEMLİSİ — DİYET UYGUNLUĞU İDDİA ETME: Bir mekanın glutensiz/sütsüz/vegan
  seçeneği olduğunu ASLA söyleme. Sana yalnızca kullanıcının NELERDEN KAÇINDIĞI
  verildi; mekanların menüsü hakkında hiçbir bilgin YOK. "Burada glutensiz seçenek
  var" demek çölyak hastasını hastalandırabilir. Bunun yerine kullanıcıya kısıtını
  mekânda teyit etmesini öner.
- Yalnızca sana verilen mekanlardan bahset; yeni mekan/menü/özellik UYDURMA.
- Mekan hakkında yalnızca sana VERİLEN alanları (ad, kategori, puan, yoğunluk)
  kullan; mutfak/atmosfer/fiyat hakkında tahmin yürütme.
- Rota sırasını takip et; her mekan için bir cümle yeterli.
- Yoğunluk bilgisi verilmişse zamanlama tavsiyesi ekle (ör. "kalabalık, X:00 daha sakin").
- En fazla ~120 kelime; akıcı, davetkâr, abartısız bir dil.
"""


def _venue_line(v) -> str:
    parts = [f"  - {v.name} ({v.category}) · puan {v.rating}"]
    if v.busyness is not None:
        parts.append(f"yoğunluk %{int(v.busyness * 100)}")
        if v.quietest_hour is not None:
            parts.append(f"en sakin {v.quietest_hour}:00")
    return " · ".join(parts)


def build_prompt(profile, venues, route, prefs=None) -> str:
    when = ""
    if prefs is not None:
        when = f"  - Ziyaret zamanı: {prefs.visit_day} {prefs.visit_hour}:00\n"
    lines = [_venue_line(v) for v in venues]
    return (
        "KULLANICI PROFİLİ:\n"
        f"  - Bütçe bandı: {profile.budget_band} (~{profile.budget_per_person} TL)\n"
        f"  - Günlük mod: {profile.mode.value}\n"
        + when
        + f"  - KAÇINILACAKLAR: {', '.join(profile.avoid_ingredients) or 'yok'}\n\n"
        f"UZLAŞI MEKANLAR (rota sırası: {' -> '.join(route.ordered_place_ids)}):\n"
        + "\n".join(lines)
        + f"\n\nToplam rota mesafesi: {route.total_distance_km} km.\n\n"
        "Bu bilgilerle kısa bir GastroPass gurme rehber metni yaz."
    )
