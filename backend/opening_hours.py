"""Google Places API (New) — açılış saatlerini çeker ve Türkçe metne dönüştürür."""
from __future__ import annotations

import os
import time
from datetime import datetime
from pathlib import Path

import requests
from dotenv import load_dotenv
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

_BACKEND_DIR = Path(__file__).resolve().parent
load_dotenv(_BACKEND_DIR / ".env")
load_dotenv()

PLACES_DETAILS_URL = "https://places.googleapis.com/v1/places/{place_id}"
FIELD_MASK = "regularOpeningHours,currentOpeningHours"

_TR_WEEKDAYS = (
    "Pazartesi",
    "Salı",
    "Çarşamba",
    "Perşembe",
    "Cuma",
    "Cumartesi",
    "Pazar",
)


def _api_key() -> str:
    key = os.getenv("GOOGLE_PLACES_API_KEY", "").strip()
    if not key:
        raise RuntimeError("GOOGLE_PLACES_API_KEY tanımlı değil (.env)")
    return key


def _session() -> requests.Session:
    """Her çağrıda taze session — Windows/Python SSL session reuse sorunlarını azaltır."""
    session = requests.Session()
    retry = Retry(
        total=4,
        connect=4,
        read=4,
        backoff_factor=0.6,
        status_forcelist=(429, 500, 502, 503, 504),
        allowed_methods=("GET",),
        raise_on_status=False,
    )
    adapter = HTTPAdapter(max_retries=retry)
    session.mount("https://", adapter)
    return session


def fetch_place_hours(place_id: str) -> tuple[dict | None, str | None]:
    """Google'dan ham açılış saati verisini döndürür.

    Returns:
        (data, error_message) — data None ise error_message dolu olabilir.
    """
    headers = {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": _api_key(),
        "X-Goog-FieldMask": FIELD_MASK,
    }
    url = PLACES_DETAILS_URL.format(place_id=place_id) + "?languageCode=tr"

    last_error: str | None = None
    for attempt in range(4):
        try:
            with _session() as session:
                resp = session.get(url, headers=headers, timeout=30)
        except requests.RequestException as exc:
            last_error = str(exc)
            time.sleep(0.5 * (attempt + 1))
            continue

        if resp.status_code != 200:
            body = resp.text[:240].replace("\n", " ")
            last_error = f"HTTP {resp.status_code}: {body}"
            if resp.status_code in (429, 500, 502, 503, 504):
                time.sleep(0.5 * (attempt + 1))
                continue
            return None, last_error

        data = resp.json()
        return (
            {
                "regularOpeningHours": data.get("regularOpeningHours"),
                "currentOpeningHours": data.get("currentOpeningHours"),
            },
            None,
        )

    return None, last_error or "Google Places isteği başarısız"


def _today_line(weekday_descriptions: list[str]) -> str | None:
    if not weekday_descriptions:
        return None
    today = _TR_WEEKDAYS[datetime.now().weekday()]
    for line in weekday_descriptions:
        normalized = line.strip()
        if normalized.lower().startswith(today.lower()):
            return normalized
    return None


def format_opening_hours(raw: dict | None) -> dict:
    """Firestore + mobil için normalize edilmiş saat alanları."""
    if not raw:
        return {
            "workingHours": "Bilgi mevcut değil",
            "isOpenNow": None,
            "openingHoursWeek": [],
        }

    regular = raw.get("regularOpeningHours") or {}
    current = raw.get("currentOpeningHours") or {}
    week = list(regular.get("weekdayDescriptions") or [])

    open_now = current.get("openNow")
    if open_now is None:
        open_now = regular.get("openNow")

    today = _today_line(week)
    if today:
        working = today
    elif week:
        working = " · ".join(week[:2])
    else:
        working = "Bilgi mevcut değil"

    if open_now is not None and working != "Bilgi mevcut değil":
        status = "Açık" if open_now else "Kapalı"
        working = f"{working} · {status}"

    return {
        "workingHours": working,
        "isOpenNow": open_now,
        "openingHoursWeek": week,
    }


def fetch_and_format(place_id: str) -> dict:
    raw, error = fetch_place_hours(place_id)
    result = format_opening_hours(raw)
    if error:
        result["error"] = error
    return result
