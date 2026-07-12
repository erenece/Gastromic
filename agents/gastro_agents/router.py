"""Router / Supervisor stub (Sprint 1, Deliverable 4).

Ajanları sırayla orkestreleyen 'amir'. Sprint 1'de çalışan boş stub:
mock modda Profiler -> Gurme RAG hattını saf-Python ile çalıştırır ve geçerli
GastroData üretir (offline, anahtarsız). Sprint 2: Optimizer Agent + Agent Debate
(3 iterasyon) tam da buraya eklenecek.
"""
from __future__ import annotations

from .config import DEBATE_ROUNDS, LLM_MODE
from .contracts import GastroData, UserPreferences
from .mock_llm import MockLLM
from .tools.preference_tool import normalize_preferences
from .tools.venue_retriever_tool import retrieve_venues


class SupervisorRouter:
    """Ajan hattının amiri. mode='mock' (varsayılan) veya mode='crew'."""

    def __init__(self, mode: str | None = None, debate_rounds: int | None = None, llm=None):
        self.mode = (mode or LLM_MODE).lower()
        self.debate_rounds = DEBATE_ROUNDS if debate_rounds is None else debate_rounds
        self.llm = llm or MockLLM()

    def run(self, prefs: UserPreferences) -> GastroData:
        if self.mode == "crew":
            from .crew import run_crew

            return run_crew(prefs)
        return self._run_mock(prefs)

    # --- Sprint 1 mock hattı (offline, deterministik) ---
    def _run_mock(self, prefs: UserPreferences) -> GastroData:
        notes = [f"LLM modu: mock ({self.llm.model}) — offline, gerçek çıkarım yok."]

        # 1) Profiler Agent
        self.llm.invoke(f"Profiler görevi: {prefs.model_dump_json()}")
        profile = normalize_preferences(prefs)

        # 2) Gurme RAG Agent
        self.llm.invoke(f"GourmetRAG görevi: {profile.model_dump_json()}")
        candidates = retrieve_venues(profile, prefs.city)

        # 3) Optimizer Agent + Agent Debate -> Sprint 2 (bilinçli boş)
        if self.debate_rounds > 0:
            notes.append(
                f"Agent Debate {self.debate_rounds} tur istendi; Sprint 2'de aktive edilecek."
            )
        else:
            notes.append("Agent Debate: Sprint 2 (şu an 0 tur).")
        notes.append("Rota optimizasyonu (TSP): Sprint 2 — Optimizer Agent.")

        return GastroData(
            request=prefs,
            profile=profile,
            candidates=candidates,
            route=None,
            notes=notes,
            meta={
                "mode": "mock",
                "agents": ["profiler", "gourmet_rag"],
                "pending": ["optimizer", "agent_debate"],
                "llm": {"provider": self.llm.provider, "model": self.llm.model},
            },
        )
