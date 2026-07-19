"""Sprint 2 birim testleri: Agent Debate, çatışma kuralları, TSP, stabilize."""
from __future__ import annotations

from gastro_agents.conflicts import check_allergen, check_budget, check_busyness, taste_score
from gastro_agents.contracts import (
    DailyMode,
    GastroData,
    GastroRoute,
    GeoPoint,
    TasteProfile,
    UserPreferences,
    VenueCandidate,
)
from gastro_agents.debate import run_debate
from gastro_agents.stabilize import stabilize
from gastro_agents.tools.preference_tool import normalize_preferences
from gastro_agents.tools.tsp_tool import solve_route
from gastro_agents.tools.venue_retriever_tool import retrieve_venues


def _profile(budget=500) -> TasteProfile:
    return normalize_preferences(
        UserPreferences(
            budget_per_person=budget,
            allergens=["süt", "yumurta"],
            sensitivities=["laktoz intoleransı"],
            daily_mode=DailyMode.ORGANIK,
        )
    )


# --- Agent Debate ---
def test_debate_runs_three_phases():
    profile = _profile()
    survivors, log = run_debate(retrieve_venues(profile), profile, rounds=3)
    assert [r.phase for r in log] == ["filtreleme", "puanlama", "uzlasma"]
    assert len(survivors) >= 1


def test_allergen_veto_removes_dairy_dessert():
    profile = _profile()
    survivors, log = run_debate(retrieve_venues(profile), profile, rounds=3)
    ids = {c.place_id for c in survivors}
    assert "mock-7" not in ids, "sütlü tatlıcı alerjen vetosu ile elenmeli"
    vetoes = [t for r in log for t in r.turns if t.action == "veto" and t.persona == "DietGuardian"]
    assert any(t.target_place_id == "mock-7" for t in vetoes)


def test_budget_veto_removes_over_budget_at_500():
    profile = _profile(budget=500)
    survivors, _ = run_debate(retrieve_venues(profile), profile, rounds=3)
    ids = {c.place_id for c in survivors}
    # price_level 3 (~900TL) mekanlar 500TL bütçenin 1.5 katını aşar -> veto
    assert "mock-2" not in ids and "mock-4" not in ids


def test_higher_budget_keeps_more_venues():
    lo, _ = run_debate(retrieve_venues(_profile(500)), _profile(500), rounds=3)
    hi, _ = run_debate(retrieve_venues(_profile(2000)), _profile(2000), rounds=3)
    assert len(hi) > len(lo), "yüksek bütçe daha çok mekan bırakmalı"


def test_busyness_downranks_crowded_venue():
    """Yoğunluk konfor kısıtı: veto etmez ama kalabalık mekanı geri düşürür."""
    profile = _profile(budget=2000)
    calm = VenueCandidate(place_id="calm", name="Sakin Yer", category="organik",
                          rating=4.5, price_level=2, busyness=0.20)
    busy = VenueCandidate(place_id="busy", name="Kalabalik Yer", category="organik",
                          rating=4.5, price_level=2, busyness=0.95, quietest_hour=15)
    survivors, log = run_debate([busy, calm], profile, rounds=3)

    ids = [c.place_id for c in survivors]
    assert ids == ["calm", "busy"], "kalabalık mekan puan kırılıp geri düşmeli"
    assert {"calm", "busy"} == set(ids), "yoğunluk veto etmemeli, sadece sıralamayı değiştirmeli"
    downranks = [t for r in log for t in r.turns
                 if t.action == "downrank" and t.target_place_id == "busy"]
    assert downranks and "yoğunluk" in downranks[0].reason


# --- Çatışma kuralları ---
def test_conflict_rules_priority():
    profile = _profile(budget=500)
    dairy = VenueCandidate(place_id="x", name="Sütçü Dede", category="tatlı,sütlü", rating=4.5)
    assert check_allergen(dairy, profile) is not None  # süt yakalanır
    cheap = VenueCandidate(place_id="y", name="Büfe", category="sokak", price_level=1)
    pricey = VenueCandidate(place_id="z", name="Fine Dining", category="gurme", price_level=4)
    assert check_budget(cheap, profile)[0] == "ok"
    assert check_budget(pricey, profile)[0] == "veto"


def test_allergen_matches_english_venue_data():
    """Gerçek veri seti İngilizce; sadece Türkçe token aramak vetoyu etkisiz bırakıyordu."""
    profile = _profile()  # süt + laktoz intoleransı
    en = VenueCandidate(place_id="en", name="Moda Ice Cream Shop", category="Ice Cream Shop",
                        types="ice_cream_shop, dessert_shop, food")
    assert check_allergen(en, profile) is not None, "İngilizce dondurmacı süt vetosu almalı"


def test_gluten_free_venue_is_not_vetoed_for_celiac():
    """'Glutensiz' mekanı çölyak hastasına yasaklamak tam ters etki olurdu."""
    profile = normalize_preferences(
        UserPreferences(budget_per_person=1000, sensitivities=["çölyak"])
    )
    gf = VenueCandidate(place_id="gf", name="Nohut Falafel (Glutensiz Mutfak)",
                        category="Restaurant", types="restaurant, food")
    assert check_allergen(gf, profile) is None


def test_vegan_venue_is_not_vetoed_for_dairy():
    profile = _profile()  # süt alerjisi
    vegan = VenueCandidate(place_id="vg", name="Bi Nevi Deli", category="Vegan Restaurant",
                           types="vegan_restaurant, restaurant, food")
    assert check_allergen(vegan, profile) is None


def test_rating_inflation_is_shrunk_by_review_count():
    """3 yorumla 5.0 alan mekan, 2000 yorumla 4.7 alanı geçmemeli."""
    few = VenueCandidate(place_id="few", name="Yeni Yer", rating=5.0, review_count=3)
    many = VenueCandidate(place_id="many", name="Koklu Yer", rating=4.7, review_count=2000)
    assert taste_score(many) > taste_score(few)
    # az yorumlu 5.0 önsel ortalamaya (4.0) doğru büzülür
    assert taste_score(few) < 4.5


# --- TSP / Optimizer ---
def test_route_solver_orders_and_measures():
    cands = [
        VenueCandidate(place_id="a", name="A", location=GeoPoint(lat=41.00, lng=29.00)),
        VenueCandidate(place_id="b", name="B", location=GeoPoint(lat=41.02, lng=29.01)),
        VenueCandidate(place_id="c", name="C", location=GeoPoint(lat=41.05, lng=29.03)),
    ]
    route = solve_route(cands)
    assert isinstance(route, GastroRoute)
    assert route.solver == "nearest_neighbor_fallback"  # Üye 1 modülü henüz yok
    assert set(route.ordered_place_ids) == {"a", "b", "c"}
    assert route.total_distance_km > 0


def test_route_trivial_with_single_point():
    route = solve_route([VenueCandidate(place_id="solo", name="Tek", location=GeoPoint(lat=41.0, lng=29.0))])
    assert route.solver == "trivial"
    assert route.total_distance_km == 0.0


# --- Stabilize (gastro_data) ---
def test_stabilize_dedups_and_fixes_route_integrity():
    prof = _profile()
    dup = VenueCandidate(place_id="dup", name="D", location=GeoPoint(lat=41.0, lng=29.0))
    data = GastroData(
        request=UserPreferences(budget_per_person=500),
        profile=prof,
        candidates=[dup, dup.model_copy()],  # aynı place_id iki kez
        route=GastroRoute(ordered_place_ids=["dup", "ghost"], total_distance_km=1.0, solver="x"),
    )
    out = stabilize(data)
    assert len(out.candidates) == 1  # tekilleştirildi
    assert out.route.ordered_place_ids == ["dup"]  # var olmayan 'ghost' düştü
    assert out.schema_version == "0.2.0-sprint2"
