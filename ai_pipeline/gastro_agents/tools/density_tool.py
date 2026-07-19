"""Yoğunluk tool'u: `density_lookup` — Üye 1'in popular-times verisine köprü.

Kaynak: data_pipeline/data/processed/density_training_data.csv
        (place_id, day_of_week, hour, busyness[0-100], ...)

DIKKAT — sözleşme uyumu: veri setinde busyness 0-100'dür; Flutter tarafı
(operation_view) busyness'ı 0.0-1.0 aralığında kullanır. Bu modül dışarıya
DAİMA 0.0-1.0 normalize değer verir ki gastro_data ile frontend hizalı kalsın.

Sprint 3: Üye 1'in ML yoğunluk tahmin modeli hazır olunca bu tool geçmiş-veri
aramasından model çıkarımına geçecek (arayüz aynı kalır).
"""
from __future__ import annotations

import csv

from .. import config

# {csv_yolu: {place_id: {(gün, saat): busyness_0_100}}} — yola göre önbellek
_CACHE: dict[str, dict[str, dict[tuple[str, int], float]]] = {}


def reset_cache() -> None:
    """Testler/yol değişimi için önbelleği temizler."""
    _CACHE.clear()


def _load_index() -> dict[str, dict[tuple[str, int], float]]:
    path = config.DENSITY_CSV
    key = str(path)
    if key in _CACHE:
        return _CACHE[key]

    index: dict[str, dict[tuple[str, int], float]] = {}
    if path.exists():
        with open(path, "r", encoding="utf-8-sig", newline="") as f:
            for row in csv.DictReader(f):
                place_id = (row.get("place_id") or "").strip()
                day = (row.get("day_of_week") or "").strip()
                if not place_id or not day:
                    continue
                try:
                    hour = int(float(row["hour"]))
                    busyness = float(row["busyness"])
                except (KeyError, TypeError, ValueError):
                    continue
                index.setdefault(place_id, {})[(day, hour)] = busyness

    _CACHE[key] = index
    return index


def busyness_at(place_id: str, day: str, hour: int) -> float | None:
    """Belirtilen gün/saatte yoğunluk — 0.0-1.0 normalize (yoksa None)."""
    record = _load_index().get(place_id)
    if not record:
        return None
    raw = record.get((day, hour))
    if raw is None:
        return None
    return round(min(max(raw, 0.0), 100.0) / 100.0, 3)


def quietest_hour(place_id: str, day: str, open_from: int = 10, open_to: int = 23) -> int | None:
    """Gün içinde (açık varsayılan saatlerde) en sakin saat."""
    record = _load_index().get(place_id)
    if not record:
        return None
    hours = [(h, v) for (d, h), v in record.items() if d == day and open_from <= h <= open_to]
    if not hours:
        return None
    return min(hours, key=lambda item: (item[1], item[0]))[0]


def enrich_busyness(candidates, day: str, hour: int) -> int:
    """Adaylara busyness + quietest_hour yazar; kaç adayda veri bulunduğunu döndürür."""
    found = 0
    for candidate in candidates:
        value = busyness_at(candidate.place_id, day, hour)
        if value is not None:
            candidate.busyness = value
            candidate.quietest_hour = quietest_hour(candidate.place_id, day)
            found += 1
    return found
