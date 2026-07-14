"""Router / Supervisor (Sprint 1 stub -> Sprint 2 tam hat).

Ajanları uçtan uca orkestreleyen 'amir'. Sprint 2'de Profiler + Gurme RAG +
Optimizer ajanları Agent Debate (3 iterasyon) ile bağlanır ve çıktı gastro_data'da
stabilize edilir. mock modda tamamen offline/deterministik çalışır (anahtarsız);
crew modu gerçek CrewAI + LLM sağlayıcısı (Sprint 2 gerçek entegrasyon) ister.
"""
from __future__ import annotations

from .config import DEBATE_ROUNDS, LLM_MODE
from .contracts import GastroData, UserPreferences
from .debate import run_debate
from .mock_llm import MockLLM
from .stabilize import stabilize
from .tools.preference_tool import normalize_preferences
from .tools.tsp_tool import solve_route
from .tools.venue_retriever_tool import retrieve_venues


class SupervisorRouter:
    """Ajan hattının amiri. mode='mock' (varsayılan, offline) veya mode='crew'."""

    def __init__(self, mode: str | None = None, debate_rounds: int | None = None, llm=None):
        self.mode = (mode or LLM_MODE).lower()
        self.debate_rounds = DEBATE_ROUNDS if debate_rounds is None else debate_rounds
        self.llm = llm or MockLLM()

    def run(self, prefs: UserPreferences) -> GastroData:
        if self.mode == "crew":
            from .crew import run_crew

            return run_crew(prefs)
        return self._run_mock(prefs)

    # --- Sprint 2 mock hattı (offline, deterministik) ---
    def _run_mock(self, prefs: UserPreferences) -> GastroData:
        notes = [f"LLM modu: mock ({self.llm.model}) — offline, deterministik."]

        # 1) Profiler Agent
        self.llm.invoke(f"Profiler görevi: {prefs.model_dump_json()}")
        profile = normalize_preferences(prefs)

        # 2) Gurme RAG Agent (geniş getir; kısıt elemesi debate'te)
        self.llm.invoke(f"GourmetRAG görevi: {profile.model_dump_json()}")
        raw_candidates = retrieve_venues(profile, prefs.city, limit=10)

        # 3) Agent Debate — Profiler/RAG/Optimizer cephelerinin müzakeresi (3 tur)
        survivors, debate_log = run_debate(raw_candidates, profile, rounds=self.debate_rounds)
        dropped_total = sum(len(r.dropped) for r in debate_log)
        notes.append(
            f"Agent Debate: {len(debate_log)} tur, {len(raw_candidates)} adaydan "
            f"{dropped_total} eleme, {len(survivors)} uzlaşı."
        )

        # 4) Optimizer Agent -> TSP (Üye 1 modülü / fallback)
        self.llm.invoke(f"Optimizer görevi: {len(survivors)} durak")
        route = solve_route(survivors)
        notes.append(
            f"Optimizer/TSP: {route.solver}, {route.total_distance_km} km, "
            f"{len(route.ordered_place_ids)} durak."
        )

        # 5) gastro_data'da stabilize et
        data = GastroData(
            request=prefs,
            profile=profile,
            candidates=survivors,
            debate=debate_log,
            route=route,
            notes=notes,
            meta={
                "mode": "mock",
                "agents": ["profiler", "gourmet_rag", "optimizer"],
                "debate_rounds": self.debate_rounds,
                "llm": {"provider": self.llm.provider, "model": self.llm.model},
            },
        )
        return stabilize(data)
