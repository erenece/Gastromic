# Firebase (Firestore)

Deploy from repo root (requires Firebase CLI and project selection):

```bash
firebase deploy --only firestore:rules,firestore:indexes --project gastromic-dev
firebase deploy --only firestore:rules,firestore:indexes --project gastromic-prod
```

Seed venue data:

```bash
pip install -r backend/requirements.txt
python backend/firestore_seed.py --env dev --dry-run
python backend/firestore_seed.py --env dev
python backend/firestore_seed.py --env prod
```

Set service account paths in `backend/.env` (see `.env.example`).
