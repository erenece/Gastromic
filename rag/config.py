import os
from dotenv import load_dotenv

load_dotenv()

GOOGLE_PLACES_API_KEY = os.getenv("GOOGLE_PLACES_API_KEY", "")

import os
from dotenv import load_dotenv

load_dotenv()

GOOGLE_PLACES_API_KEY = os.getenv("GOOGLE_PLACES_API_KEY", "")

# --- EKSİK OLAN APIFY TOKEN TANIMI ---
APIFY_API_TOKEN = os.getenv("APIFY_API_TOKEN", "")

MAX_ENTERPRISE_CALLS_PER_RUN = 800

CITIES = [
    "İstanbul", "Ankara", "İzmir", "Bursa", "Antalya",
    "Muğla", "Adana",
]

CATEGORIES = [
    "restoran", "kahvaltı salonu", "kebapçı", "balık restoranı", "meyhane",
    "kafe", "tatlıcı", "lokanta", "dünya mutfağı restoranı", "pub",
    "vejetaryen restoran", "vegan restoran",
]

MAX_RESULTS_PER_QUERY = 60

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

RAW_DIR = os.path.join(BASE_DIR, "data", "raw")
PROCESSED_DIR = os.path.join(BASE_DIR, "data", "processed")

MAX_ENTERPRISE_CALLS_PER_RUN = 800

CITIES = [
    "İstanbul", "Ankara", "İzmir", "Bursa", "Antalya",
    "Muğla", "Adana",
]

CATEGORIES = [
    "restoran", "kahvaltı salonu", "kebapçı", "balık restoranı", "meyhane",
    "kafe", "tatlıcı", "lokanta", "dünya mutfağı restoranı", "pub",
    "vejetaryen restoran", "vegan restoran",
]

MAX_RESULTS_PER_QUERY = 60


BASE_DIR = os.path.dirname(os.path.abspath(__file__))

RAW_DIR = os.path.join(BASE_DIR, "data", "raw")
PROCESSED_DIR = os.path.join(BASE_DIR, "data", "processed")