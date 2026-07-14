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

# Orkestrasyon motoru:
#   "lite" -> hafif deterministik hat + AI beyni sentezi (varsayılan)
#   "crew" -> tam CrewAI orkestrasyonu (gerçek sağlayıcı gerekir)
ENGINE = os.getenv("GASTRO_ENGINE", "lite").lower()

# AI beyni sağlayıcısı:
#   "gemini" (varsayılan) -> google-genai; anahtar/SDK yoksa otomatik mock'a düşer
#   "openai" -> Sprint 3
#   "mock"   -> her zaman offline
LLM_PROVIDER = os.getenv("GASTRO_LLM_PROVIDER", "gemini").lower()
LLM_MODEL = os.getenv("GASTRO_LLM_MODEL", "gemini-2.0-flash-001")

# Agent Debate tur sayısı — Sprint 2: 3 iterasyon (filtreleme/puanlama/uzlaşma).
DEBATE_ROUNDS = int(os.getenv("GASTRO_DEBATE_ROUNDS", "3"))
