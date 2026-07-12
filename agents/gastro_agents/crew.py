"""CrewAI iskeleti (Sprint 1, Deliverable 1).

Gerçek sağlayıcı (Gemini/OpenAI) takıldığında (Sprint 2) kullanılacak katman.
CrewAI Agent/Task/Crew tanımlarını (rol/hedef/backstory + tool) barındırır.

ÖNEMLİ: mock modda BU MODÜL ÇALIŞTIRILMAZ. SupervisorRouter mock modda saf-Python
hattı kullanır (router.py). Burada crewai importları BİLEREK tembeldir (lazy) — böylece
crewai kurulu olmadan da paket import edilebilir ve mock demo/testler çalışır.
"""
from __future__ import annotations

from .contracts import GastroData, UserPreferences
from .prompts import gourmet_rag as p_rag
from .prompts import optimizer as p_opt
from .prompts import profiler as p_profiler
from .tools.preference_tool import normalize_preferences
from .tools.venue_retriever_tool import retrieve_venues


def _require_crewai():
    try:
        import crewai  # noqa: F401

        return crewai
    except ImportError as exc:  # pragma: no cover - sadece crew modunda
        raise RuntimeError(
            "CrewAI kurulu değil. Gerçek ajan hattı için:\n"
            "  pip install -r agents/requirements.txt\n"
            "ve bir sağlayıcı anahtarı (GEMINI_API_KEY / OPENAI_API_KEY) ayarlayın.\n"
            "Anahtarsız çalışmak için mock modu kullanın (GASTRO_LLM_MODE=mock)."
        ) from exc


def _build_llm():
    """crew modunda kullanılacak LLM (Sprint 2'de sağlayıcı netleşecek)."""
    from .config import LLM_MODEL, LLM_PROVIDER

    from crewai import LLM  # type: ignore

    if LLM_PROVIDER == "gemini":
        return LLM(model=LLM_MODEL or "gemini/gemini-1.5-flash")
    if LLM_PROVIDER == "openai":
        return LLM(model=LLM_MODEL or "gpt-4o-mini")
    raise RuntimeError(
        "crew modu için gerçek sağlayıcı gerekli: GASTRO_LLM_PROVIDER=gemini|openai"
    )


def build_tools():
    """Profiler ve RAG tool'larını CrewAI BaseTool olarak sar (lazy)."""
    from crewai.tools import BaseTool  # type: ignore

    from .contracts import TasteProfile, UserPreferences as _UP

    class PreferenceNormalizerTool(BaseTool):
        name: str = "preference_normalizer"
        description: str = "Kullanıcı tercihlerini yapılandırılmış TasteProfile'a çevirir."

        def _run(self, **kwargs) -> str:
            prefs = _UP(**kwargs)
            return normalize_preferences(prefs).model_dump_json()

    class VenueRetrieverTool(BaseTool):
        name: str = "venue_retriever"
        description: str = "TasteProfile'a uygun, turist tuzağı olmayan mekanları getirir."

        def _run(self, profile_json: str, city: str = "İstanbul") -> str:
            profile = TasteProfile.model_validate_json(profile_json)
            cands = retrieve_venues(profile, city)
            return "[" + ",".join(c.model_dump_json() for c in cands) + "]"

    return PreferenceNormalizerTool(), VenueRetrieverTool()


def build_agents(llm=None):
    """Profiler + Gurme RAG (+ Sprint 2 Optimizer placeholder) CrewAI ajanları."""
    from crewai import Agent  # type: ignore

    pref_tool, venue_tool = build_tools()

    profiler = Agent(
        role=p_profiler.ROLE,
        goal=p_profiler.GOAL,
        backstory=p_profiler.BACKSTORY,
        tools=[pref_tool],
        llm=llm,
        allow_delegation=False,
        verbose=True,
    )
    gourmet = Agent(
        role=p_rag.ROLE,
        goal=p_rag.GOAL,
        backstory=p_rag.BACKSTORY,
        tools=[venue_tool],
        llm=llm,
        allow_delegation=False,
        verbose=True,
    )
    # Sprint 2 placeholder — tanımlı ama şimdilik crew'a eklenmiyor.
    optimizer = Agent(
        role=p_opt.ROLE,
        goal=p_opt.GOAL,
        backstory=p_opt.BACKSTORY,
        llm=llm,
        allow_delegation=False,
        verbose=True,
    )
    return profiler, gourmet, optimizer


def run_crew(prefs: UserPreferences) -> GastroData:
    """Gerçek CrewAI hattını çalıştırır (Sprint 2 sağlayıcısı gerekir).

    Sprint 1'de yalnızca iskelet: LLM orkestrasyonu kurulur ve çalıştırılır; ancak
    yapılandırılmış çıktının (GastroData) LLM cevabından güvenilir ayrıştırılması
    Sprint 2 işidir. Deterministik profile/candidates aynı tool'lardan doldurulur,
    crew'in serbest çıktısı meta['crew_raw']'a iliştirilir.
    """
    _require_crewai()
    from crewai import Crew, Process, Task  # type: ignore

    llm = _build_llm()
    profiler, gourmet, _optimizer = build_agents(llm)

    t1 = Task(
        description=p_profiler.task_description(prefs),
        expected_output=p_profiler.EXPECTED_OUTPUT,
        agent=profiler,
    )
    t2 = Task(
        description=p_rag.task_description(prefs),
        expected_output=p_rag.EXPECTED_OUTPUT,
        agent=gourmet,
        context=[t1],
    )
    crew = Crew(
        agents=[profiler, gourmet],
        tasks=[t1, t2],
        process=Process.sequential,
        verbose=True,
    )
    result = crew.kickoff()

    profile = normalize_preferences(prefs)
    candidates = retrieve_venues(profile, prefs.city)
    return GastroData(
        request=prefs,
        profile=profile,
        candidates=candidates,
        notes=[
            "crew modu (iskelet): CrewAI orkestrasyonu çalıştı.",
            "LLM serbest çıktısından GastroData ayrıştırma Sprint 2'de tamamlanacak.",
        ],
        meta={"mode": "crew", "llm": {"provider": llm.__class__.__name__}, "crew_raw": str(result)},
    )
