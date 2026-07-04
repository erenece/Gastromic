import os
from dotenv import load_dotenv

load_dotenv()

GOOGLE_PLACES_API_KEY = os.getenv("GOOGLE_PLACES_API_KEY", "")

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

RAW_DIR = "data/raw"
PROCESSED_DIR = "data/processed"
