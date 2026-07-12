"""gastro_data — ajan hattının ortak veri sözleşmesi (Sprint 1 taslağı).

NOT (kritik bağımlılık #1): Bu, Üye 2'nin ajanlarının tükettiği/ürettiği geçici
Sprint-1 sözleşmesidir. Üye 3'ün resmi `gastro_data` Pydantic modeli hazır olunca
Sprint 2 başında bu şema onunla uzlaştırılacaktır. Alan adları bilerek Flutter
tercih ekranıyla (bütçe/alerjen/hastalık/günlük mod) hizalanmıştır.
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
    """Kullanıcı tercih ekranından (Sprint 1 Flutter) gelen girdi = pipeline girişi."""

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
    rating: Optional[float] = None
    review_count: Optional[int] = None
    price_level: Optional[int] = None
    location: Optional[GeoPoint] = None
    tourist_trap_score: float = 0.0  # 0 = otantik, 1 = turist tuzağı
    match_reason: str = ""


class GastroData(BaseModel):
    """Ajan hattının uçtan uca çıktı sözleşmesi (JSON'a stabilize edilir)."""

    schema_version: str = "0.1.0-sprint1"
    request: UserPreferences
    profile: TasteProfile
    candidates: list[VenueCandidate] = Field(default_factory=list)
    route: Optional[list[str]] = None  # Sprint 2: Optimizer/TSP rota çıktısı
    notes: list[str] = Field(default_factory=list)
    meta: dict = Field(default_factory=dict)
