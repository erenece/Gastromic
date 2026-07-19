"""Router / Supervisor — ajan hattının amiri.

İki eksen:
  - engine: "lite" (hafif deterministik hat + AI beyni sentezi) | "crew" (tam CrewAI)
  - provider (AI beyni): gemini (varsayılan) | openai | mock

Güvenlik-kritik mantık (alerjen vetosu, bütçe, TSP) deterministik katmanda kalır;
AI beyni (Gemini) yalnızca doğal-dil sentezini (GastroPass rehberi) üretir. Anahtar/SDK
yoksa otomatik mock'a düşülür ve şablon özet kullanılır — offline hiç kırılmaz.
"""
from __future__ import annotations

from .config import DEBATE_ROUNDS, ENGINE, MAX_ROUTE_STOPS
from .contracts import GastroData, UserPreferences
from .debate import run_debate
from .llm import build_llm
from .prompts import gastropass
from .stabilize import stabilize
from .tools.density_tool import enrich_busyness
from .tools.preference_tool import normalize_preferences
from .tools.tsp_tool import solve_route
from .tools.venue_retriever_tool import retrieve_venues


class SupervisorRouter:
    def __init__(self, engine: str | None = None, provider: str | None = None,
                 debate_rounds: int | None = None, llm=None):
        self.engine = (engine or ENGINE).lower()
        self.debate_rounds = DEBATE_ROUNDS if debate_rounds is None else debate_rounds
        self.llm = llm or build_llm(provider)

    def run(self, prefs: UserPreferences) -> GastroData:
        if self.engine == "crew":
            from .crew import run_crew

            return run_crew(prefs)
        return self._run_lite(prefs)

    # --- Hafif hat: deterministik omurga + AI beyni (Gemini) sentezi ---
    def _run_lite(self, prefs: UserPreferences) -> GastroData:
        notes: list[str] = []

        # 1) Profiler Agent (deterministik)
        profile = normalize_preferences(prefs)

        # 2) Gurme RAG Agent — geniş getir; kısıt elemesi debate'te (deterministik)
        raw_candidates = retrieve_venues(profile, prefs.city, limit=10)
        notes.append(f"Gurme RAG: {prefs.city} için {len(raw_candidates)} aday getirildi.")

        # 2b) Yoğunluk zenginleştirme (Üye 1 popular-times verisi)
        found = enrich_busyness(raw_candidates, prefs.visit_day, prefs.visit_hour)
        notes.append(
            f"Yoğunluk ({prefs.visit_day} {prefs.visit_hour}:00): "
            f"{found}/{len(raw_candidates)} adayda veri bulundu."
        )

        # 3) Agent Debate — çatışma kurallarıyla müzakere (deterministik güvenlik rayı)
        survivors, debate_log = run_debate(raw_candidates, profile, rounds=self.debate_rounds)
        dropped_total = sum(len(r.dropped) for r in debate_log)
        notes.append(
            f"Agent Debate: {len(debate_log)} tur, {len(raw_candidates)} adaydan "
            f"{dropped_total} eleme, {len(survivors)} uzlaşı."
        )

        # 4) Optimizer Agent -> TSP (deterministik; Üye 1 modülü / fallback)
        # Rota gerçekçi kalsın: uzlaşı listesinden en yüksek konsensüslü N durak.
        route_stops = survivors[:MAX_ROUTE_STOPS]
        route = solve_route(route_stops)
        notes.append(
            f"Optimizer/TSP: {route.solver}, {route.total_distance_km} km, "
            f"{len(route.ordered_place_ids)} durak "
            f"({len(survivors)} uzlaşı mekandan en iyi {len(route_stops)})."
        )

        # 5) AI BEYNİ (Gemini) — GastroPass rehber metni sentezi
        # Rehber metni rotayla tutarlı olsun: sadece rotadaki duraklar anlatılır
        ai_summary, brain_note = self._synthesize(profile, route_stops, route, prefs)
        notes.append(brain_note)

        # 6) gastro_data'da stabilize et
        data = GastroData(
            request=prefs,
            profile=profile,
            candidates=survivors,
            debate=debate_log,
            route=route,
            ai_summary=ai_summary,
            notes=notes,
            meta={
                "engine": self.engine,
                "agents": ["profiler", "gourmet_rag", "optimizer"],
                "debate_rounds": self.debate_rounds,
                "llm": {"provider": self.llm.provider, "model": self.llm.model},
            },
        )
        return stabilize(data)

    def _synthesize(self, profile, survivors, route, prefs) -> tuple[str, str]:
        """AI beyniyle GastroPass metni üret; Gemini yoksa/başarısızsa şablona düş."""
        if self.llm.provider == "gemini":
            prompt = gastropass.build_prompt(profile, survivors, route, prefs)
            try:
                text = self.llm.invoke(prompt, system=gastropass.SYSTEM_PROMPT)
                if text:
                    return text, f"AI beyni: gemini ({self.llm.model}) — GastroPass metni üretildi."
            except Exception as exc:  # ağ/kota hatası -> demo kırılmasın
                # Sessiz fallback gerçek arızayı gizler: hata mesajını nota taşı.
                detail = " ".join(str(exc).split())[:140] or type(exc).__name__
                return (
                    _template_summary(profile, survivors, route),
                    f"AI beyni: gemini çağrısı BAŞARISIZ ({type(exc).__name__}: {detail}) — şablona düşüldü.",
                )
        note = getattr(self.llm, "note", None)
        return (
            _template_summary(profile, survivors, route),
            "AI beyni: mock" + (f" — {note}" if note else "") + " (şablon özet).",
        )


def _template_summary(profile, survivors, route) -> str:
    names = ", ".join(v.name for v in survivors) or "uygun mekan bulunamadı"
    return (
        f"{profile.mode.value.capitalize()} modu · {profile.budget_band} bütçe rotası "
        f"({route.total_distance_km} km): {names}. "
        f"[Doğal dil GastroPass metni için GEMINI_API_KEY tanımlayın.]"
    )
