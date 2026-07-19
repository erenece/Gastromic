"""Ajan çıktısını gastro_data JSON'da stabilize etme (Sprint 2, Görev 4).

Ajanların (mock ya da crew) ürettiği ham çıktıyı kanonik, tutarlı ve referans-bütün
bir GastroData'ya sabitler:
  1. Adayları place_id'ye göre tekilleştir
  2. Rota referans bütünlüğü: rota id'leri yalnızca mevcut adaylardan olabilir
  3. schema_version'ı sabitle
  4. Pydantic ile yeniden doğrula (bozuksa hata fırlat)
"""
from __future__ import annotations

from .contracts import GastroData

SCHEMA_VERSION = "0.2.0-sprint2"


def stabilize(data: GastroData) -> GastroData:
    # 1) adayları tekilleştir (ilk görüleni koru, sırayı bozma)
    seen: set[str] = set()
    unique = []
    for c in data.candidates:
        if c.place_id in seen:
            continue
        seen.add(c.place_id)
        unique.append(c)
    data.candidates = unique

    # 2) rota referans bütünlüğü
    if data.route is not None:
        data.route.ordered_place_ids = [pid for pid in data.route.ordered_place_ids if pid in seen]

    # 3) şema sürümü
    data.schema_version = SCHEMA_VERSION

    # 4) yeniden doğrula (round-trip) — geçersizse burada patlar
    return GastroData.model_validate(data.model_dump())
