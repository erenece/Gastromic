# Gastromic Backend (Sprint 3)

Unified API + Firestore seed for `data_pipeline`, `ai_pipeline`, and legacy `rag/`.

## Setup

```bash
cd gastromic
pip install -r backend/requirements.txt
pip install -r ai_pipeline/requirements.txt
cp backend/.env.example backend/.env
```

## Run API

From repo root:

```bash
uvicorn backend.main:app --reload --host 0.0.0.0 --port 8000
```

## Firestore seed

```bash
python backend/firestore_seed.py --env dev --dry-run
python backend/firestore_seed.py --env dev
python backend/firestore_seed.py --env prod
```

## Chroma index

```bash
curl -X POST http://localhost:8000/index-venues
```

Data source: `data_pipeline/data/processed/`.
