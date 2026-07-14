"""Router/Supervisor smoke testleri (mock mod, offline) — Sprint 1 + Sprint 2 hattı."""
from __future__ import annotations

from gastro_agents.contracts import DailyMode, GastroData, GastroRoute, UserPreferences
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
    assert out.schema_version == "0.2.0-sprint2"


def test_profiler_derives_avoided_ingredients():
    out = SupervisorRouter(mode="mock").run(_prefs())
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
    reloaded = GastroData.model_validate_json(out.model_dump_json())
    assert reloaded.profile.mode == out.profile.mode
    assert len(reloaded.candidates) == len(out.candidates)
    assert len(reloaded.debate) == len(out.debate)


def test_route_and_debate_active_in_sprint2():
    out = SupervisorRouter(mode="mock").run(_prefs())
    # Sprint 2: debate ve rota artık AKTİF (Sprint 1'de ertelenmişti)
    assert len(out.debate) == 3, "3 iterasyonlu Agent Debate beklenir"
    assert isinstance(out.route, GastroRoute)
    assert out.route.ordered_place_ids, "optimize rota beklenir"
    assert "optimizer" in out.meta["agents"]
