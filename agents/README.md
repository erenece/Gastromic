# Gastromic — AI Agent Katmanı (`agents/`)

**Sorumlu:** Üye 2 — Scrum Master & AI Agent Engineer

AI çekirdeği: ajanlar + müzakere + rota + **AI beyni (Gemini)**.

**Mimari ilke:** Güvenlik-kritik mantık (alerjen vetosu, bütçe, TSP) **deterministik**
katmanda kalır — Gemini burada halüsinasyonla alerjen sızdıramaz. **Gemini** yalnızca
doğal-dil sentezini (GastroPass gurme rehber metni) üretir. Anahtar/SDK yoksa otomatik
**mock**'a düşer; hat offline hiç kırılmaz.

## AI Beyni (Gemini)

- Varsayılan sağlayıcı: **gemini** (`gemini-2.0-flash-001`), istemci: `google-genai`.
- Aktive etmek için: `agents/.env` içine `GEMINI_API_KEY=...` (https://aistudio.google.com/apikey).
- Anahtar yoksa → mock'a düşer, şablon özet üretir (offline çalışır).

| Değişken | Varsayılan | Açıklama |
|---|---|---|
| `GASTRO_ENGINE` | `lite` | `lite` (deterministik omurga + AI sentez) \| `crew` (tam CrewAI) |
| `GASTRO_LLM_PROVIDER` | `gemini` | `gemini` \| `openai` (S3) \| `mock` |
| `GASTRO_LLM_MODEL` | `gemini-2.0-flash-001` | Gemini model id |
| `GEMINI_API_KEY` | — | Gemini anahtarı (yoksa mock) |
| `GASTRO_DEBATE_ROUNDS` | `3` | Agent Debate tur sayısı |

## Sprint 1 — İskelet · Sprint 2 — AI Beyni (PDF plan → kod)

| Sprint | # | Plan görevi | Karşılığı |
|---|---|---|---|
| 1 | 1 | CrewAI iskeleti | [`crew.py`](gastro_agents/crew.py) |
| 1 | 2 | Profiler prompt + tool | [`prompts/profiler.py`](gastro_agents/prompts/profiler.py) + [`tools/preference_tool.py`](gastro_agents/tools/preference_tool.py) |
| 1 | 3 | Gurme RAG prompt | [`prompts/gourmet_rag.py`](gastro_agents/prompts/gourmet_rag.py) + [`tools/venue_retriever_tool.py`](gastro_agents/tools/venue_retriever_tool.py) |
| 1 | 4 | Router/Supervisor stub | [`router.py`](gastro_agents/router.py) |
| 2 | 1 | Profiler+RAG+Optimizer bağlama | [`router.py`](gastro_agents/router.py) + [`crew.py`](gastro_agents/crew.py) |
| 2 | 2 | Agent Debate (3 iterasyon) | [`debate.py`](gastro_agents/debate.py) + [`prompts/debate.py`](gastro_agents/prompts/debate.py) |
| 2 | 3 | Bütçe/lezzet/alerjen çatışma kuralları | [`conflicts.py`](gastro_agents/conflicts.py) |
| 2 | 4 | gastro_data JSON'da stabilize | [`stabilize.py`](gastro_agents/stabilize.py) |
| 2 | 5 | Optimizer'ı TSP modülüne bağlama | [`tools/tsp_tool.py`](gastro_agents/tools/tsp_tool.py) + [`prompts/optimizer.py`](gastro_agents/prompts/optimizer.py) |
| — | — | **AI beyni (Gemini) sentezi** | [`gemini_llm.py`](gastro_agents/gemini_llm.py) + [`llm.py`](gastro_agents/llm.py) + [`prompts/gastropass.py`](gastro_agents/prompts/gastropass.py) |

## Mimari

```
UserPreferences (tercih ekranı)
        │
        ▼   engine=lite (varsayılan) | engine=crew (CrewAI)
  SupervisorRouter
        ├─▶ Profiler ──(preference_normalizer)──▶ TasteProfile          [deterministik]
        ├─▶ Gurme RAG ─(venue_retriever)────────▶ aday mekanlar         [deterministik]
        ├─▶ Agent Debate (3 tur) ─ conflicts.py:                         [deterministik = güvenlik rayı]
        │      DietGuardian(alerjen VETO) · BudgetLogistics(bütçe) · GourmetCritic(lezzet)
        ├─▶ Optimizer ─(tsp_route_solver)──────▶ GastroRoute            [deterministik]
        └─▶ 🧠 AI Beyni (Gemini) ──▶ GastroPass rehber metni (ai_summary)  [LLM sentez]
        ▼
     stabilize() ⇒ GastroData (kanonik JSON)
```

## Çalıştırma

```bash
# Offline (anahtarsız — AI metni şablon olur):
pip install pydantic
python agents/run_demo.py

# Gemini beyniyle (gerçek GastroPass metni):
pip install -r agents/requirements.txt          # google-genai dahil
echo "GEMINI_API_KEY=..." > agents/.env
python agents/run_demo.py
```

## Testler

```bash
cd agents && python -m pytest -q          # 18 test (Sprint 1 + 2 + LLM sağlayıcı)
```

## Sprint 3'e devir

- **Gerçek RAG:** `tools/venue_retriever_tool.py` → embedding + ChromaDB (Üye 3).
- **Gerçek TSP:** `tools/tsp_tool.py::_try_member1_tsp` → Üye 1'in `optimization.tsp.solve`.
- **Menü-düzeyi alerjen taraması:** `conflicts.py::check_allergen` (şu an ad/kategori sezgiseli).
- **LLM-içi debate:** ajanların Gemini ile gerçek müzakeresi (şu an deterministik).
- **OpenAI sağlayıcı:** `llm.py` içine adapter.
