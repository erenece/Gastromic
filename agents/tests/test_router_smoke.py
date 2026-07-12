"""Router/Supervisor stub smoke testleri (mock mod, offline).

Retrospektif notu: Sprint 1'de unit test eforu yetersiz kalmıştı; bu dosya ajan
katmanı için ilk güvenlik ağını kurar.
"""
from __future__ import annotations

from gastro_agents.contracts import DailyMode, GastroData, UserPreferences
from gastro_agents.router import SupervisorRouter


def _prefs() -> UserPreferences:
    return UserPreferences(
        budget_per_person=500,
        city="İstanbul",
        allergens=["süt", "yumurta"],
        sensitivities=["laktoz intoleransı"],
        daily_mode=DailyMode.ORGANIK,
    )


def test_router_runs_offline_and_returns_gastrodata():
    out = SupervisorRouter(mode="mock").run(_prefs())
    assert isinstance(out, GastroData)
    assert out.meta["mode"] == "mock"
    assert out.meta["llm"]["provider"] == "mock"


def test_profiler_derives_avoided_ingredients():
    out = SupervisorRouter(mode="mock").run(_prefs())
    # süt alerjeni + laktoz intoleransı -> süt türevleri kaçınılacaklara girer
    assert "süt" in out.profile.avoid_ingredients
    assert "peynir" in out.profile.avoid_ingredients  # laktoz map'inden
    assert out.profile.budget_band == "orta"  # 500 TL


def test_no_tourist_traps_in_candidates():
    out = SupervisorRouter(mode="mock").run(_prefs())
    assert out.candidates, "en az bir aday beklenir"
    assert all(c.tourist_trap_score < 0.8 for c in out.candidates)
    assert all("turistik" not in c.category.lower() for c in out.candidates)


def test_gastrodata_json_roundtrip():
    out = SupervisorRouter(mode="mock").run(_prefs())
    dumped = out.model_dump_json()
    reloaded = GastroData.model_validate_json(dumped)
    assert reloaded.profile.mode == out.profile.mode
    assert len(reloaded.candidates) == len(out.candidates)


def test_debate_and_route_deferred_to_sprint2():
    out = SupervisorRouter(mode="mock").run(_prefs())
    assert out.route is None  # TSP rota Sprint 2
    assert "optimizer" in out.meta["pending"]
    assert "agent_debate" in out.meta["pending"]
