# Gastromic — AI Agent Katmanı (`agents/`)

**Sorumlu:** Üye 2 — Scrum Master & AI Agent Engineer
**Sprint 1 kapsamı:** AI çekirdeğinin **iskeleti**. Ajanlar tanımlanır, promptlar
yazılır, orkestrasyon (Router/Supervisor) uçtan uca **offline (mock)** çalışır.
Gerçek LLM/RAG entegrasyonu **Sprint 2**'dedir.

> Bu katman API anahtarı olmadan çalışır (varsayılan `mock` mod). Jüri/takım
> arkadaşları `pip install pydantic` dışında bir şey kurmadan demoyu koşabilir.

## Sprint 1 Deliverable'ları (PDF plan → kod)

| # | Plan görevi | Karşılığı |
|---|---|---|
| 1 | `agents/` altında CrewAI iskeleti | [`gastro_agents/crew.py`](gastro_agents/crew.py) — CrewAI Agent/Task/Crew tanımları (lazy import) |
| 2 | Profiler Agent — temel prompt + tool | [`prompts/profiler.py`](gastro_agents/prompts/profiler.py) + [`tools/preference_tool.py`](gastro_agents/tools/preference_tool.py) |
| 3 | Gurme RAG Agent — temel prompt | [`prompts/gourmet_rag.py`](gastro_agents/prompts/gourmet_rag.py) + [`tools/venue_retriever_tool.py`](gastro_agents/tools/venue_retriever_tool.py) |
| 4 | Çalışan boş Router/Supervisor stub | [`router.py`](gastro_agents/router.py) — `SupervisorRouter` (mock modda uçtan uca çalışır) |

Ortak veri sözleşmesi: [`contracts.py`](gastro_agents/contracts.py) (`gastro_data`
taslağı — Üye 3'ün resmi Pydantic modeliyle Sprint 2'de uzlaştırılacak).

## Mimari

```
UserPreferences (tercih ekranı)
        │
        ▼
  SupervisorRouter  ── mode=mock (Sprint 1, offline)
        │            └ mode=crew (Sprint 2, CrewAI + Gemini/OpenAI)
        ├─▶ Profiler Agent ──(preference_normalizer)──▶ TasteProfile
        ├─▶ Gurme RAG Agent ─(venue_retriever)────────▶ VenueCandidate[]
        └─▶ [Sprint 2] Optimizer Agent + Agent Debate (3 tur) ─▶ route
        ▼
     GastroData (JSON)
```

## Çalıştırma (mock — anahtar gerekmez)

```bash
# 1) Bağımlılık (sadece pydantic yeterli)
pip install pydantic

# 2) Demo (repo kökünden)
python agents/run_demo.py
#   veya
cd agents && python -m gastro_agents
```

Çıktı: örnek tercihler için tam `GastroData` JSON (profil + turist-tuzağı elenmiş
mekan adayları).

## Testler

```bash
cd agents && python -m pytest -q
```

## Sprint 2'ye devir (extension points)

- **Gerçek LLM:** `.env`'de `GASTRO_LLM_MODE=crew`, `GASTRO_LLM_PROVIDER=gemini|openai`
  + anahtar. `crew.py::_build_llm` sağlayıcıyı seçer.
- **Gerçek RAG:** `tools/venue_retriever_tool.py` içindeki CSV/mock kaynağı,
  embedding + ChromaDB benzerlik aramasıyla (Üye 3) değiştirilecek.
- **Agent Debate (3 iterasyon):** `router.py` içindeki `debate_rounds` kancası;
  `GASTRO_DEBATE_ROUNDS=3`.
- **Optimizer/TSP:** `prompts/optimizer.py` hazır; Üye 1'in TSP modülüne
  `tsp_route_solver` tool'u olarak bağlanacak, çıktı `GastroData.route`'a yazılacak.
