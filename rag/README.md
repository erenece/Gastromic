# Deprecated — use `backend/` instead

This folder is kept for historical reference. Sprint 3 consolidated services into [`../backend/`](../backend/):

- **FastAPI:** `uvicorn backend.main:app --reload` (repo root)
- **Firestore seed:** `python backend/firestore_seed.py --env dev --dry-run`
- **Chroma index:** `POST /index-venues`

Data source of truth: `data_pipeline/data/processed/` (not `rag/data/`).

> **GitHub:** `rag/data/` repoda izlenmez (aynı CSV/JSON zaten `data_pipeline/data/` altında).
> Yerelde veri varsa script'ler `rag/data/` yolunu kullanmaya devam eder.
