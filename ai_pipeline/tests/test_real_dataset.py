"""Gerçek data_pipeline veri setine karşı testler.

Bu dosya conftest'in hermetik izolasyonunu BİLEREK geri alır ve Üye 1'in ürettiği
gerçek places.csv / density_training_data.csv şemasını doğrular. Dosyalar repoda
yoksa testler atlanır (CI/klon farkı kırmasın).
"""
from __future__ import annotations

import pytest

from gastro_agents import config
from gastro_agents.contracts import DailyMode, UserPreferences
from gastro_agents.tools import density_tool, venue_retriever_tool
from gastro_agents.tools.preference_tool import normalize_preferences
from gastro_agents.tools.venue_retriever_tool import retrieve_venues

REAL_PLACES = config.REPO_ROOT / "data_pipeline" / "data" / "processed" / "places.csv"
REAL_DENSITY = config.REPO_ROOT / "data_pipeline" / "data" / "processed" / "density_training_data.csv"


@pytest.fixture
def real_places(monkeypatch):
    if not REAL_PLACES.exists():
        pytest.skip("gerçek places.csv yok")
    monkeypatch.setattr(config, "PLACES_CSV", REAL_PLACES)
    venue_retriever_tool.reset_cache()
    yield
    venue_retriever_tool.reset_cache()


@pytest.fixture
def real_density(monkeypatch):
    if not REAL_DENSITY.exists():
        pytest.skip("gerçek density_training_data.csv yok")
    monkeypatch.setattr(config, "DENSITY_CSV", REAL_DENSITY)
    density_tool.reset_cache()
    yield
    density_tool.reset_cache()


def _profile(budget=2000):
    return normalize_preferences(
        UserPreferences(budget_per_person=budget, daily_mode=DailyMode.ORGANIK)
    )


def test_real_csv_columns_are_parsed(real_places):
    """BOM'lu 'Place ID'/'Place Name'/'Average Rating' başlıkları doğru eşlenmeli."""
    venues = retrieve_venues(_profile(), city="İstanbul", limit=20, source="csv")
    assert venues, "gerçek veriden İstanbul mekanı gelmeli"
    assert all(v.name != "Bilinmeyen" for v in venues), "isim kolonu eşleşmedi"
    assert any(v.rating is not None for v in venues), "puan kolonu eşleşmedi"
    assert any(v.location is not None for v in venues), "koordinat kolonu eşleşmedi"
    assert all(v.place_id for v in venues)


def test_city_filter_isolates_requested_city(real_places):
    """7 şehirlik veri setinde şehir filtresi şart."""
    istanbul = retrieve_venues(_profile(), city="İstanbul", limit=50, source="csv")
    adana = retrieve_venues(_profile(), city="Adana", limit=50, source="csv")
    assert istanbul and adana
    assert not ({v.place_id for v in istanbul} & {v.place_id for v in adana})


def test_price_level_enum_is_mapped(real_places):
    """PRICE_LEVEL_* enum'u 1..4 seviyeye ve TL tahminine çevrilmeli."""
    venues = retrieve_venues(_profile(), city="İstanbul", limit=50, source="csv")
    levels = {v.price_level for v in venues if v.price_level is not None}
    assert levels, "fiyat seviyesi hiç eşleşmedi (enum mapping bozuk)"
    assert levels <= {1, 2, 3, 4}
    assert all(v.estimated_cost_per_person for v in venues if v.price_level)


def test_density_lookup_returns_normalized_busyness(real_density):
    """Veri seti 0-100; tool 0.0-1.0 (Flutter sözleşmesi) döndürmeli."""
    index = density_tool._load_index()
    assert index, "yoğunluk indeksi boş"
    place_id = next(iter(index))
    day, hour = next(iter(index[place_id]))
    value = density_tool.busyness_at(place_id, day, hour)
    assert value is not None and 0.0 <= value <= 1.0


def test_density_quietest_hour_within_open_range(real_density):
    index = density_tool._load_index()
    place_id = next(iter(index))
    day = next(iter(index[place_id]))[0]
    hour = density_tool.quietest_hour(place_id, day)
    if hour is not None:
        assert 10 <= hour <= 23


def test_unknown_place_returns_none(real_density):
    assert density_tool.busyness_at("olmayan-place-id", "Saturday", 20) is None
