"""Ortak backend yapılandırması — tek veri kaynağı: data_pipeline."""
from __future__ import annotations

import os
from pathlib import Path

from dotenv import load_dotenv

REPO_ROOT = Path(__file__).resolve().parents[1]
BACKEND_DIR = Path(__file__).resolve().parent
SECRETS_DIR = BACKEND_DIR / "secrets"

load_dotenv(BACKEND_DIR / ".env")
load_dotenv()
DATA_PROCESSED_DIR = REPO_ROOT / "data_pipeline" / "data" / "processed"
PLACES_CSV = DATA_PROCESSED_DIR / "places.csv"
REVIEWS_CSV = DATA_PROCESSED_DIR / "reviews.csv"
IMAGE_URLS_JSON = DATA_PROCESSED_DIR / "image_urls.json"
DENSITY_CSV = DATA_PROCESSED_DIR / "density_training_data.csv"
POPULAR_TIMES_RAW = REPO_ROOT / "data_pipeline" / "data" / "raw" / "popular_times_raw.json"
CHROMA_DB_DIR = REPO_ROOT / "backend" / "chroma_db"

FIREBASE_PROJECT_DEV = os.getenv("FIREBASE_PROJECT_DEV", "gastromic-dev")
FIREBASE_PROJECT_PROD = os.getenv("FIREBASE_PROJECT_PROD", "gastromic-prod")
FIREBASE_SERVICE_ACCOUNT_DEV = os.getenv("FIREBASE_SERVICE_ACCOUNT_DEV", "")
FIREBASE_SERVICE_ACCOUNT_PROD = os.getenv("FIREBASE_SERVICE_ACCOUNT_PROD", "")

# Varsayılan service account dosya yolları (backend/secrets/ altına koyun)
DEFAULT_SERVICE_ACCOUNT_DEV = SECRETS_DIR / "gastromic-dev.json"
DEFAULT_SERVICE_ACCOUNT_PROD = SECRETS_DIR / "gastromic-prod.json"

DEFAULT_VISIT_DAY = os.getenv("GASTRO_VISIT_DAY", "Saturday")
DEFAULT_VISIT_HOUR = int(os.getenv("GASTRO_VISIT_HOUR", "20"))
