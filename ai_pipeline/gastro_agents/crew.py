"""CrewAI iskeleti (Sprint 1) + Profiler/RAG/Optimizer bağlama (Sprint 2, Görev 1).

Gerçek sağlayıcı (Gemini/OpenAI) takıldığında kullanılacak katman. CrewAI
Agent/Task/Crew tanımlarını (rol/hedef/backstory + tool) barındırır.

ÖNEMLİ: mock modda BU MODÜL ÇALIŞTIRILMAZ. SupervisorRouter mock modda saf-Python
hattı kullanır (router.py + debate.py + tsp_tool.py). Buradaki crewai importları
BİLEREK tembeldir (lazy) — böylece crewai kurulu olmadan da paket/testler çalışır.
"""
from __future__ import annotations

from .contracts import GastroData, UserPreferences
from .debate import run_debate
from .prompts import gourmet_rag as p_rag
from .prompts import optimizer as p_opt
from .prompts import profiler as p_profiler
from .stabilize import stabilize
from .tools.preference_tool import normalize_preferences
from .tools.tsp_tool import solve_route
from .tools.venue_retriever_tool import retrieve_venues


def _require_crewai():
    try:
        import crewai  # noqa: F401

        return crewai
    except ImportError as exc:  # pragma: no cover - sadece crew modunda
        raise RuntimeError(
            "CrewAI kurulu değil. Gerçek ajan hattı için:\n"
            "  pip install -r ai_pipeline/requirements.txt\n"
            "ve bir sağlayıcı anahtarı (GEMINI_API_KEY / OPENAI_API_KEY) ayarlayın.\n"
            "Anahtarsız çalışmak için mock modu kullanın (GASTRO_LLM_MODE=mock)."
        ) from exc


def _build_llm():
    """crew modunda kullanılacak LLM (Sprint 2'de sağlayıcı netleşecek)."""
    from .config import LLM_MODEL, LLM_PROVIDER
    from crewai import LLM  # type: ignore

    if LLM_PROVIDER == "gemini":
        # CrewAI/litellm 'gemini/<model>' bekler; google-genai stili id'yi normalize et
        model = LLM_MODEL or "gemini-2.0-flash"
        if not model.startswith("gemini/"):
            model = f"gemini/{model}"
        return LLM(model=model)
    if LLM_PROVIDER == "openai":
        return LLM(model=LLM_MODEL or "gpt-4o-mini")
    raise RuntimeError("crew motoru için gerçek sağlayıcı gerekli: GASTRO_LLM_PROVIDER=gemini|openai")


def build_tools():
    """Profiler / RAG / Optimizer tool'larını CrewAI BaseTool olarak sarar (lazy)."""
    from crewai.tools import BaseTool  # type: ignore

    from .contracts import TasteProfile, UserPreferences as _UP, VenueCandidate

    class PreferenceNormalizerTool(BaseTool):
        name: str = "preference_normalizer"
        description: str = "Kullanıcı tercihlerini yapılandırılmış TasteProfile'a çevirir."

        def _run(self, **kwargs) -> str:
            return normalize_preferences(_UP(**kwargs)).model_dump_json()

    class VenueRetrieverTool(BaseTool):
        name: str = "venue_retriever"
        description: str = "TasteProfile'a uygun, turist tuzağı olmayan mekanları getirir."

        def _run(self, profile_json: str, city: str = "İstanbul") -> str:
            cands = retrieve_venues(TasteProfile.model_validate_json(profile_json), city)
            return "[" + ",".join(c.model_dump_json() for c in cands) + "]"

    class TSPRouteSolverTool(BaseTool):
        name: str = "tsp_route_solver"
        description: str = "Uzlaşı mekanlarını en kısa rotaya dizer (Üye 1 TSP / fallback)."

        def _run(self, candidates_json: str) -> str:
            import json

            cands = [VenueCandidate.model_validate(x) for x in json.loads(candidates_json)]
            return solve_route(cands).model_dump_json()

    return PreferenceNormalizerTool(), VenueRetrieverTool(), TSPRouteSolverTool()


def build_agents(llm=None):
    """Profiler + Gurme RAG + Optimizer CrewAI ajanları (Sprint 2: üçü de bağlı)."""
    from crewai import Agent  # type: ignore

    pref_tool, venue_tool, tsp_tool = build_tools()

    profiler = Agent(role=p_profiler.ROLE, goal=p_profiler.GOAL, backstory=p_profiler.BACKSTORY,
                     tools=[pref_tool], llm=llm, allow_delegation=False, verbose=True)
    gourmet = Agent(role=p_rag.ROLE, goal=p_rag.GOAL, backstory=p_rag.BACKSTORY,
                    tools=[venue_tool], llm=llm, allow_delegation=False, verbose=True)
    optimizer = Agent(role=p_opt.ROLE, goal=p_opt.GOAL, backstory=p_opt.BACKSTORY,
                      tools=[tsp_tool], llm=llm, allow_delegation=False, verbose=True)
    return profiler, gourmet, optimizer


def run_crew(prefs: UserPreferences) -> GastroData:
    """Gerçek CrewAI hattını çalıştırır (Sprint 2 sağlayıcısı gerekir).

    İskelet: 3 ajan (Profiler+RAG+Optimizer) sıralı bağlanır ve çalıştırılır. LLM
    serbest çıktısından GastroData'nın güvenilir ayrıştırılması Sprint 2/3 işidir;
    şimdilik deterministik hat (debate + tsp) üretim-hazır çıktıyı üretir, crew'in
    serbest çıktısı meta['crew_raw']'a iliştirilir.
    """
    _require_crewai()
    from crewai import Crew, Process, Task  # type: ignore

    llm = _build_llm()
    profiler, gourmet, optimizer = build_agents(llm)

    t1 = Task(description=p_profiler.task_description(prefs), expected_output=p_profiler.EXPECTED_OUTPUT, agent=profiler)
    t2 = Task(description=p_rag.task_description(prefs), expected_output=p_rag.EXPECTED_OUTPUT, agent=gourmet, context=[t1])
    t3 = Task(description=p_opt.task_description(prefs), expected_output=p_opt.EXPECTED_OUTPUT, agent=optimizer, context=[t2])
    crew = Crew(agents=[profiler, gourmet, optimizer], tasks=[t1, t2, t3], process=Process.sequential, verbose=True)
    result = crew.kickoff()

    # Deterministik hat ile stabilize edilmiş gastro_data (Sprint 2 ayrıştırma köprüsü)
    from .config import DEBATE_ROUNDS

    profile = normalize_preferences(prefs)
    survivors, debate_log = run_debate(retrieve_venues(profile, prefs.city, limit=10), profile, rounds=DEBATE_ROUNDS)
    route = solve_route(survivors)
    data = GastroData(
        request=prefs, profile=profile, candidates=survivors, debate=debate_log, route=route,
        notes=["crew modu (iskelet): CrewAI 3-ajan orkestrasyonu çalıştı.",
                "LLM serbest çıktısından GastroData ayrıştırma Sprint 2/3'te tamamlanacak."],
        meta={"engine": "crew", "llm": {"provider": llm.__class__.__name__}, "crew_raw": str(result)},
    )
    return stabilize(data)
