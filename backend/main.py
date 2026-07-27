"""Gastromic birleşik backend — FastAPI + AI pipeline + ChromaDB RAG."""
from __future__ import annotations

import sys
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import List, Optional

import requests
from fastapi import FastAPI, Query
from pydantic import BaseModel, Field

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT / "ai_pipeline"))

from gastro_agents.contracts import DailyMode, GeoPoint, UserPreferences
from gastro_agents.llm import build_llm
from gastro_agents.prompts import venue_summary
from gastro_agents.router import SupervisorRouter
from gastro_agents.tools.density_tool import busyness_at, enrich_busyness, quietest_hour
from gastro_agents.tools.tsp_tool import solve_route
from gastro_agents.tools.venue_retriever_tool import get_venue_by_id, retrieve_venues
from gastro_agents.tools.preference_tool import normalize_preferences
from gastro_agents.conflicts import check_allergen, check_amenities, check_budget

from backend.chroma_indexer import index_places_from_csv, index_popular_times
from backend.config import DEFAULT_VISIT_DAY, DEFAULT_VISIT_HOUR, POPULAR_TIMES_RAW
from backend.database import collection

app = FastAPI(title="GastroLogic API", version="1.0.0-sprint3")
router = SupervisorRouter()


@app.get("/")
def read_root():
    return {"message": "GastroLogic API çalışıyor", "version": "1.0.0-sprint3"}


@app.get("/health")
async def health_check():
    return {"status": "online", "message": "GastroLogic is ready"}


@app.post("/recommend")
async def recommend(prefs: UserPreferences):
    result = router.run(prefs)
    return result.model_dump(mode="json")


@app.get("/search")
async def search_places(query: str = Query(..., description="Aranacak kelime veya kriter")):
    results = collection.query(query_texts=[query], n_results=5)
    return {"status": "success", "query": query, "results": results}


@app.post("/index-venues")
async def index_venues():
    return index_places_from_csv()


@app.post("/index-popular-times")
async def index_popular_times_endpoint():
    return index_popular_times(POPULAR_TIMES_RAW)


@app.get("/predict-density/{place_id}")
async def predict_density(place_id: str, day: str = DEFAULT_VISIT_DAY, hour: int = DEFAULT_VISIT_HOUR):
    value = busyness_at(place_id, day, hour)
    quiet = quietest_hour(place_id, day)
    if value is None:
        return {"status": "not_found", "place_id": place_id, "day": day, "hour": hour}
    return {
        "status": "success",
        "place_id": place_id,
        "day": day,
        "hour": hour,
        "predicted_busyness": round(value * 100),
        "busyness_normalized": value,
        "quietest_hour": quiet,
    }


class RouteRequest(BaseModel):
    place_ids: List[str]
    city: str = "İstanbul"


@app.post("/optimize-route")
async def optimize_route(data: RouteRequest):
    profile = normalize_preferences(UserPreferences(city=data.city))
    candidates = retrieve_venues(profile, city=data.city, limit=50, source="csv")
    by_id = {c.place_id: c for c in candidates}
    selected = [by_id[pid] for pid in data.place_ids if pid in by_id]
    if len(selected) < 2:
        return {
            "status": "success",
            "optimized_route": data.place_ids,
            "total_distance_km": 0.0,
            "note": "Yeterli konum verisi yok",
        }
    route = solve_route(selected)
    return {
        "status": "success",
        "optimized_route": route.ordered_place_ids,
        "total_distance_km": route.total_distance_km,
        "solver": route.solver,
    }


@app.get("/get-fx-rates")
async def get_fx_rates():
    tcmb_url = "https://www.tcmb.gov.tr/kurlar/today.xml"
    try:
        response = requests.get(tcmb_url, timeout=10)
        if response.status_code != 200:
            return {"error": "TCMB sunucusuna ulaşılamadı."}
        root = ET.fromstring(response.content)
        rates = {}
        for currency in root.findall("Currency"):
            code = currency.get("CurrencyCode")
            if code in ["USD", "EUR", "GBP"]:
                forex_buying = currency.find("ForexBuying")
                forex_selling = currency.find("ForexSelling")
                rates[code] = {
                    "buying": forex_buying.text if forex_buying is not None else None,
                    "selling": forex_selling.text if forex_selling is not None else None,
                }
        return {"status": "success", "source": "TCMB", "rates": rates}
    except Exception as exc:
        return {"error": f"Kur çekilirken hata oluştu: {exc}"}


class RecommendForVenueRequest(BaseModel):
    venue_id: str
    budget_per_person: int = Field(ge=50, le=3000, default=500)
    city: str = "İstanbul"
    allergens: list[str] = Field(default_factory=list)
    sensitivities: list[str] = Field(default_factory=list)
    daily_mode: str = "organik"
    smoking_area: bool = False
    alcohol_served: bool = False
    visit_day: str = DEFAULT_VISIT_DAY
    visit_hour: int = DEFAULT_VISIT_HOUR
    location: Optional[GeoPoint] = None


@app.post("/recommend/summary")
async def recommend_summary(body: RecommendForVenueRequest):
    prefs = UserPreferences(
        budget_per_person=body.budget_per_person,
        city=body.city,
        location=body.location,
        allergens=body.allergens,
        sensitivities=body.sensitivities,
        daily_mode=DailyMode(body.daily_mode.lower()),
        smoking_area=body.smoking_area,
        alcohol_served=body.alcohol_served,
        visit_day=body.visit_day,
        visit_hour=body.visit_hour,
    )
    profile = normalize_preferences(prefs)
    candidate = get_venue_by_id(body.venue_id)
    if candidate is None:
        return {
            "venue_id": body.venue_id,
            "ai_summary": "Bu mekan için yeterli veri bulunamadı.",
            "match_reason": None,
            "fits_preferences": False,
        }

    enrich_busyness([candidate], prefs.visit_day, prefs.visit_hour)
    allergen = check_allergen(candidate, profile)
    budget_verdict, estimated_cost = check_budget(candidate, profile)
    amenity_verdict, amenity_reason = check_amenities(candidate, profile)
    searchable = f"{candidate.category} {candidate.types}".lower()
    mode_match = (
        "uyumlu"
        if any(pc.split()[0].lower() in searchable for pc in profile.preferred_categories)
        else "nötr"
    )

    checks = {
        "allergen": allergen,
        "budget_verdict": budget_verdict,
        "estimated_cost": estimated_cost,
        "amenity_verdict": amenity_verdict if amenity_verdict != "ok" else "ok",
        "mode_match": mode_match,
    }
    fits = allergen is None and budget_verdict != "veto"

    llm = build_llm()
    if llm.provider == "gemini":
        try:
            prompt = venue_summary.build_prompt(profile, candidate, prefs, checks)
            text = llm.invoke(prompt, system=venue_summary.SYSTEM_PROMPT)
            if text:
                return {
                    "venue_id": body.venue_id,
                    "ai_summary": text,
                    "match_reason": candidate.match_reason,
                    "fits_preferences": fits,
                    "checks": checks,
                }
        except Exception:
            pass

    summary_parts = [f"{candidate.name} · {profile.mode.value} moduna göre değerlendirildi."]
    if allergen:
        summary_parts.append(f"Alerjen riski: {allergen} — menüyü mutlaka teyit edin.")
    if budget_verdict == "veto":
        summary_parts.append(f"Tahmini maliyet (~{estimated_cost} TL) bütçenizi aşıyor.")
    elif budget_verdict == "downrank":
        summary_parts.append(f"Tahmini maliyet ~{estimated_cost} TL; bütçenize yakın.")
    if amenity_reason:
        summary_parts.append(amenity_reason)
    if mode_match == "uyumlu":
        summary_parts.append(f"{profile.mode.value.capitalize()} modunuza uygun bir profil.")

    return {
        "venue_id": body.venue_id,
        "ai_summary": " ".join(summary_parts),
        "match_reason": candidate.match_reason,
        "fits_preferences": fits,
        "checks": checks,
    }
