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
# Üye 1'in Apify popular-times hattından üretilen yoğunluk verisi (place x gün x saat)
DENSITY_CSV = DATA_PROCESSED_DIR / "density_training_data.csv"

# Orkestrasyon motoru:
#   "lite" -> hafif deterministik hat + AI beyni sentezi (varsayılan)
#   "crew" -> tam CrewAI orkestrasyonu (gerçek sağlayıcı gerekir)
ENGINE = os.getenv("GASTRO_ENGINE", "lite").lower()

# AI beyni sağlayıcısı:
#   "gemini" (varsayılan) -> google-genai; anahtar/SDK yoksa otomatik mock'a düşer
#   "openai" -> Sprint 3
#   "mock"   -> her zaman offline
LLM_PROVIDER = os.getenv("GASTRO_LLM_PROVIDER", "gemini").lower()
# 'gemini-flash-latest': güncel flash modelini takip eden kararlı alias. NOT: bazı
# anahtarlarda 'gemini-2.0-flash*' free-tier kotası 0'dır (429) — alias bunu aşar.
LLM_MODEL = os.getenv("GASTRO_LLM_MODEL", "gemini-flash-latest")

# Gemini "thinking" bütçesi. 0 = kapalı (varsayılan). Açık bırakılırsa gizli düşünme
# tokenleri çıktı bütçesini yiyip metni MAX_TOKENS ile kesiyor (ölçüldü: %93).
THINKING_BUDGET = int(os.getenv("GASTRO_THINKING_BUDGET", "0"))

# Agent Debate tur sayısı — Sprint 2: 3 iterasyon (filtreleme/puanlama/uzlaşma).
DEBATE_ROUNDS = int(os.getenv("GASTRO_DEBATE_ROUNDS", "3"))

# Bir günlük lezzet rotasındaki azami durak sayısı. Gerçek veri setinde (3434 mekan)
# uzlaşı listesi kabarık olabiliyor; rota gerçekçi kalsın diye en iyi N durak alınır.
MAX_ROUTE_STOPS = int(os.getenv("GASTRO_MAX_ROUTE_STOPS", "4"))
