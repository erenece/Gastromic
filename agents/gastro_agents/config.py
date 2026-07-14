"""Ajan katmanı yapılandırması. .env varsa okur (python-dotenv opsiyonel)."""
from __future__ import annotations

import os
from pathlib import Path

try:  # dotenv opsiyonel; yoksa sessizce geç
    from dotenv import load_dotenv

    load_dotenv()
except Exception:  # pragma: no cover
    pass

# .../Gastromic/agents/gastro_agents/config.py -> parents[2] = repo kökü
REPO_ROOT = Path(__file__).resolve().parents[2]
DATA_PROCESSED_DIR = REPO_ROOT / "data_pipeline" / "data" / "processed"
PLACES_CSV = DATA_PROCESSED_DIR / "places.csv"
REVIEWS_CSV = DATA_PROCESSED_DIR / "reviews.csv"

# Çalışma modu:
#   "mock" -> offline, sağlayıcı/anahtar gerektirmez (Sprint 1 varsayılanı)
#   "crew" -> gerçek CrewAI + LLM sağlayıcısı (Sprint 2)
LLM_MODE = os.getenv("GASTRO_LLM_MODE", "mock").lower()

# crew modunda kullanılacak sağlayıcı (Sprint 2'de netleşecek)
LLM_PROVIDER = os.getenv("GASTRO_LLM_PROVIDER", "mock").lower()  # mock|gemini|openai
LLM_MODEL = os.getenv("GASTRO_LLM_MODEL", "")

# Agent Debate tur sayısı — Sprint 2: 3 iterasyon (filtreleme/puanlama/uzlaşma).
DEBATE_ROUNDS = int(os.getenv("GASTRO_DEBATE_ROUNDS", "3"))
