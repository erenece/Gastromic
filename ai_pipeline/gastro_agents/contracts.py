"""gastro_data — ajan hattının ortak veri sözleşmesi.

Sprint 1: temel şema (profil + adaylar).
Sprint 2: Agent Debate + Optimizer/TSP rota alanları eklendi (schema 0.2.0).

NOT (kritik bağımlılık #1): Bu, Üye 2'nin ajanlarının tükettiği/ürettiği geçici
sözleşmedir. Üye 3'ün resmi `gastro_data` Pydantic modeli hazır olunca Sprint 2/3'te
uzlaştırılacaktır. Alan adları bilerek Flutter tercih ekranıyla hizalanmıştır.
"""
from __future__ import annotations

from enum import Enum
from typing import Optional

from pydantic import BaseModel, Field


class DailyMode(str, Enum):
    """Tercih ekranındaki 'Günlük Mod' seçenekleri."""

    SPORCU = "sporcu"
    VEJETARYEN = "vejetaryen"
    ORGANIK = "organik"
    KACAMAK = "kacamak"


class GeoPoint(BaseModel):
    lat: float
    lng: float


class UserPreferences(BaseModel):
    """Kullanıcı tercih ekranından (Flutter) gelen girdi = pipeline girişi."""

    budget_per_person: int = Field(ge=50, le=3000, description="Kişi başı bütçe (TL)")
    city: str = "İstanbul"
    location: Optional[GeoPoint] = None
    allergens: list[str] = Field(default_factory=list, description="süt, yumurta, buğday ...")
    sensitivities: list[str] = Field(
        default_factory=list, description="laktoz intoleransı, çölyak, diyabet ..."
    )
    daily_mode: DailyMode = DailyMode.ORGANIK
    smoking_area: bool = False
    alcohol_served: bool = False
    # Ziyaret zamanı — yoğunluk (popular times) sorgusu için (profil ekranındaki "gün")
    visit_day: str = "Saturday"  # density veri seti İngilizce gün adı kullanıyor
    visit_hour: int = Field(default=20, ge=0, le=23)


class TasteProfile(BaseModel):
    """Profiler Agent çıktısı — yapılandırılmış damak/kısıt profili."""

    budget_band: str
    budget_per_person: int
    dietary_flags: list[str] = Field(default_factory=list)
    avoid_ingredients: list[str] = Field(default_factory=list)
    preferred_categories: list[str] = Field(default_factory=list)
    mode: DailyMode
    mode_summary: str = ""
    hard_constraints: list[str] = Field(default_factory=list)


class VenueCandidate(BaseModel):
    """Gurme RAG Agent çıktısındaki tek mekan adayı."""

    place_id: str
    name: str
    category: str = ""
    types: str = ""  # Google Places tip etiketleri (vegan_restaurant, bakery, ...)
    rating: Optional[float] = None
    review_count: Optional[int] = None
    price_level: Optional[int] = None
    location: Optional[GeoPoint] = None
    tourist_trap_score: float = 0.0  # 0 = otantik, 1 = turist tuzağı
    match_reason: str = ""
    # Sprint 2 (debate) alanları
    estimated_cost_per_person: Optional[int] = None
    consensus_score: float = 0.0
    # Yoğunluk (Üye 1 popular-times verisi). NOT: 0.0-1.0 normalize — Flutter
    # operation_view'ın busyness sözleşmesiyle birebir hizalı (veri seti 0-100'dür).
    busyness: Optional[float] = Field(default=None, ge=0.0, le=1.0)
    quietest_hour: Optional[int] = Field(default=None, ge=0, le=23)


# --- Sprint 2: Agent Debate ---
class DebateTurn(BaseModel):
    """Müzakerede tek bir ajan-personasının tek hamlesi."""

    round: int
    persona: str  # DietGuardian | GourmetCritic | BudgetLogistics | Supervisor
    action: str  # veto | downrank | uprank | approve
    target_place_id: str
    reason: str


class DebateRound(BaseModel):
    """3-iterasyonlu müzakerenin tek turu."""

    index: int
    phase: str = ""  # filtreleme | puanlama | uzlasma
    turns: list[DebateTurn] = Field(default_factory=list)
    dropped: list[str] = Field(default_factory=list)  # bu turda elenen place_id'ler
    surviving: list[str] = Field(default_factory=list)
    converged: bool = False


# --- Sprint 2: Optimizer / TSP rota ---
class GastroRoute(BaseModel):
    ordered_place_ids: list[str] = Field(default_factory=list)
    total_distance_km: float = 0.0
    solver: str = ""  # member1_tsp | nearest_neighbor_fallback | trivial


class GastroData(BaseModel):
    """Ajan hattının uçtan uca çıktı sözleşmesi (JSON'a stabilize edilir)."""

    schema_version: str = "0.2.0-sprint2"
    request: UserPreferences
    profile: TasteProfile
    candidates: list[VenueCandidate] = Field(default_factory=list)
    debate: list[DebateRound] = Field(default_factory=list)  # Sprint 2
    route: Optional[GastroRoute] = None  # Sprint 2: Optimizer/TSP çıktısı
    ai_summary: Optional[str] = None  # AI beyni (Gemini) GastroPass rehber metni
    notes: list[str] = Field(default_factory=list)
    meta: dict = Field(default_factory=dict)
