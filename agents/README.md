# Gastromic — AI Agent Katmanı (`agents/`)

**Sorumlu:** Üye 2 — Scrum Master & AI Agent Engineer

Bu katman AI çekirdeğini (ajanlar + müzakere + rota) barındırır. **API anahtarı
olmadan** çalışır (varsayılan `mock` mod): jüri/takım arkadaşları `pip install pydantic`
dışında bir şey kurmadan tüm hattı offline koşabilir. Gerçek LLM/RAG entegrasyonu
`crew` moduyla (Sprint 2/3) devreye girer.

## Sprint 1 — İskelet (PDF plan → kod)

| # | Plan görevi | Karşılığı |
|---|---|---|
| 1 | `agents/` altında CrewAI iskeleti | [`crew.py`](gastro_agents/crew.py) |
| 2 | Profiler Agent — prompt + tool | [`prompts/profiler.py`](gastro_agents/prompts/profiler.py) + [`tools/preference_tool.py`](gastro_agents/tools/preference_tool.py) |
| 3 | Gurme RAG Agent — prompt | [`prompts/gourmet_rag.py`](gastro_agents/prompts/gourmet_rag.py) + [`tools/venue_retriever_tool.py`](gastro_agents/tools/venue_retriever_tool.py) |
| 4 | Çalışan boş Router/Supervisor stub | [`router.py`](gastro_agents/router.py) |

## Sprint 2 — AI Beyni (PDF plan → kod)

| # | Plan görevi | Karşılığı |
|---|---|---|
| 1 | Profiler + RAG + Optimizer'ı birbirine bağlama | [`router.py`](gastro_agents/router.py) tam hat + [`crew.py`](gastro_agents/crew.py) 3-ajan crew |
| 2 | Agent Debate (3 iterasyon) müzakere mantığı | [`debate.py`](gastro_agents/debate.py) + [`prompts/debate.py`](gastro_agents/prompts/debate.py) |
| 3 | Bütçe/lezzet/alerjen çatışma kuralları | [`conflicts.py`](gastro_agents/conflicts.py) |
| 4 | Ajan çıktısını gastro_data JSON'da stabilize etme | [`stabilize.py`](gastro_agents/stabilize.py) |
| 5 | Optimizer Agent'ı Üye 1'in TSP modülüne bağlama | [`tools/tsp_tool.py`](gastro_agents/tools/tsp_tool.py) + [`prompts/optimizer.py`](gastro_agents/prompts/optimizer.py) |

Ortak veri sözleşmesi: [`contracts.py`](gastro_agents/contracts.py) (`gastro_data`,
schema `0.2.0-sprint2` — Üye 3'ün resmi Pydantic modeliyle uzlaştırılacak).

## Mimari (Sprint 2 tam hat)

```
UserPreferences (tercih ekranı)
        │
        ▼
  SupervisorRouter ── mode=mock (offline)  |  mode=crew (CrewAI + Gemini/OpenAI)
        │
        ├─▶ Profiler Agent ──(preference_normalizer)──▶ TasteProfile
        ├─▶ Gurme RAG Agent ─(venue_retriever)────────▶ aday mekanlar (geniş)
        ├─▶ Agent Debate (3 tur) ─ conflicts.py ile müzakere:
        │     • DietGuardian    → alerjen/sağlık VETO
        │     • BudgetLogistics → bütçe veto/itiraz
        │     • GourmetCritic   → lezzet/otantiklik puanı
        │        ⇒ uzlaşı mekan listesi + debate_log
        └─▶ Optimizer Agent ─(tsp_route_solver)───────▶ GastroRoute (TSP)
        ▼
     stabilize() ⇒ GastroData (kanonik JSON)
```

## Çalıştırma (mock — anahtar gerekmez)

```bash
pip install pydantic
python agents/run_demo.py          # repo kökünden
# veya:  cd agents && python -m gastro_agents
```

Örnek çıktı (500 TL bütçe, süt/yumurta alerjisi, organik mod): Debate turist tuzağı
+ bütçe aşan + sütlü mekanları eler → 3 uzlaşı mekan → TSP ile 6.43 km rota.

## Testler

```bash
cd agents && python -m pytest -q          # 13 test (Sprint 1 + Sprint 2)
```

## Sprint 3'e devir (extension points)

- **Gerçek LLM:** `.env`'de `GASTRO_LLM_MODE=crew`, `GASTRO_LLM_PROVIDER=gemini|openai` + anahtar.
- **Gerçek RAG:** `tools/venue_retriever_tool.py` içindeki CSV/mock kaynağı, embedding + ChromaDB ile (Üye 3) değişecek.
- **Gerçek TSP:** `tools/tsp_tool.py::_try_member1_tsp` — Üye 1'in `optimization.tsp.solve` modülü gelince fallback devralınır.
- **Alerjen taraması:** `conflicts.py::check_allergen` şu an ad/kategori sezgiseli; gerçek menü/içerik taraması Sprint 3.
- **Debate tur sayısı:** `GASTRO_DEBATE_ROUNDS` (varsayılan 3).
