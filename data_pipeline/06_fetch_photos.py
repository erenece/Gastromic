"""Mevcut places.csv Place ID'leri için Google Places (New) fotoğraf URL'lerini çeker.

Kullanım:
  cd data_pipeline
  # backend/.env veya data_pipeline/.env → GOOGLE_PLACES_API_KEY (SERVER key, Android kısıtlaması YOK)
  python 06_fetch_photos.py --validate-key
  python 06_fetch_photos.py --offset 0 --limit 800

Çıktı: data/processed/image_urls.json
Ardından: python ../backend/patch_venue_images.py --env dev
"""
from __future__ import annotations

import argparse
import csv
import json
import time
from pathlib import Path

import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

from config import GOOGLE_PLACES_API_KEY, IMAGE_URLS_JSON, PROCESSED_DIR

DETAILS_URL = "https://places.googleapis.com/v1/places/{place_id}"
PHOTO_FIELD_MASK = "photos"
TEST_PLACE_ID = "ChIJ--06nDC5yhQRuNBtIm8tHkk"


class PlacesKeyError(RuntimeError):
    """API key yanlış veya Android kısıtlamalı."""


def _build_session() -> requests.Session:
    session = requests.Session()
    retry = Retry(
        total=3,
        connect=3,
        read=3,
        backoff_factor=0.8,
        status_forcelist=[429, 500, 502, 503, 504],
        allowed_methods=["GET"],
        raise_on_status=False,
    )
    adapter = HTTPAdapter(max_retries=retry, pool_connections=4, pool_maxsize=4)
    session.mount("https://", adapter)
    return session


def _load_cache(path: Path) -> dict[str, dict]:
    if not path.exists():
        return {}
    raw = json.loads(path.read_text(encoding="utf-8"))
    cache: dict[str, dict] = {}
    for place_id, value in raw.items():
        if isinstance(value, str):
            cache[place_id] = {"imageUrl": value, "photoAttribution": ""}
        elif isinstance(value, dict):
            cache[place_id] = {
                "imageUrl": value.get("imageUrl") or "",
                "photoAttribution": value.get("photoAttribution") or "",
            }
    return cache


def _save_cache(path: Path, cache: dict[str, dict]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(cache, ensure_ascii=False, indent=2), encoding="utf-8")


def _photo_attribution(photo: dict) -> str:
    parts: list[str] = []
    for attr in photo.get("authorAttributions") or []:
        name = (attr.get("displayName") or "").strip()
        if name:
            parts.append(name)
    return " · ".join(parts)


def _parse_error(resp: requests.Response) -> str:
    try:
        return resp.json().get("error", {}).get("message", resp.text[:200])
    except Exception:
        return resp.text[:200]


def _ensure_key_works(session: requests.Session, place_id: str = TEST_PLACE_ID) -> None:
    headers = {
        "X-Goog-Api-Key": GOOGLE_PLACES_API_KEY,
        "X-Goog-FieldMask": PHOTO_FIELD_MASK,
    }
    resp = session.get(
        DETAILS_URL.format(place_id=place_id),
        headers=headers,
        params={"languageCode": "tr"},
        timeout=30,
    )
    if resp.status_code == 200:
        print("API key OK — Places (New) erişimi çalışıyor.")
        return

    message = _parse_error(resp)
    if resp.status_code == 403 and ("Android" in message or "android" in message.lower()):
        raise PlacesKeyError(
            "Bu API key Android uygulama kısıtlamalı — PC script'i çalıştıramaz.\n"
            "Google Cloud Console → Credentials → YENİ key oluştur:\n"
            "  • Application restrictions: None (veya IP)\n"
            "  • API restrictions: Places API (New)\n"
            "Sonra backend/.env → GOOGLE_PLACES_API_KEY=... (mobil Maps key'inden FARKLI)"
        )
    if resp.status_code == 403:
        raise PlacesKeyError(
            f"API key reddedildi (403): {message}\n"
            "Places API (New) etkin mi ve key kısıtlamaları doğru mu kontrol edin."
        )
    raise PlacesKeyError(f"API test isteği başarısız ({resp.status_code}): {message}")


def fetch_photo_entry(
    session: requests.Session,
    place_id: str,
    max_height: int = 800,
) -> tuple[dict | None, str | None]:
    """(entry, error_kind). error_kind: 'android' | 'transient' | None"""
    headers = {
        "X-Goog-Api-Key": GOOGLE_PLACES_API_KEY,
        "X-Goog-FieldMask": PHOTO_FIELD_MASK,
    }
    url = DETAILS_URL.format(place_id=place_id)

    resp: requests.Response | None = None
    last_error: Exception | None = None
    for attempt in range(4):
        try:
            resp = session.get(url, headers=headers, params={"languageCode": "tr"}, timeout=30)
            if resp.status_code in {403, 429, 500, 502, 503, 504} and attempt < 3:
                wait = 2.0 * (attempt + 1)
                print(f"  ! HTTP {resp.status_code}, {wait:.0f}s sonra tekrar ({attempt + 1}/4)")
                time.sleep(wait)
                continue
            break
        except requests.exceptions.SSLError as exc:
            last_error = exc
            wait = 1.0 + attempt
            print(f"  ! SSL hatası, {wait:.0f}s sonra tekrar ({attempt + 1}/4)")
            time.sleep(wait)
            session.close()
            session = _build_session()
        except requests.RequestException as exc:
            last_error = exc
            time.sleep(1.0 + attempt)
    else:
        print(f"  ✗ {place_id}: ağ hatası — {last_error}")
        return None, "transient"

    if resp is None:
        return None, "transient"

    if resp.status_code == 403:
        message = _parse_error(resp)
        if "Android" in message or "android" in message.lower():
            return None, "android"
        print(f"  ✗ {place_id}: HTTP 403 — {message[:120]}")
        return None, "transient"

    if resp.status_code != 200:
        print(f"  ✗ {place_id}: HTTP {resp.status_code} — {_parse_error(resp)[:120]}")
        return None, "transient"

    photos = resp.json().get("photos") or []
    if not photos:
        return None, None

    photo = photos[0]
    photo_name = photo.get("name")
    if not photo_name:
        return None, None

    image_url = (
        f"https://places.googleapis.com/v1/{photo_name}/media"
        f"?maxHeightPx={max_height}&key={GOOGLE_PLACES_API_KEY}"
    )
    return {
        "imageUrl": image_url,
        "photoAttribution": _photo_attribution(photo),
    }, None


def main() -> None:
    parser = argparse.ArgumentParser(description="Google Places fotoğraf URL cache")
    parser.add_argument("--offset", type=int, default=0)
    parser.add_argument("--limit", type=int, default=800)
    parser.add_argument("--sleep", type=float, default=0.35)
    parser.add_argument("--max-height", type=int, default=800)
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--validate-key", action="store_true", help="Key test et ve çık")
    parser.add_argument(
        "--retry-failed",
        action="store_true",
        help="Bu batch'teki boş cache kayıtlarını silip yeniden dene",
    )
    args = parser.parse_args()

    if not GOOGLE_PLACES_API_KEY:
        raise SystemExit(
            "GOOGLE_PLACES_API_KEY bulunamadı.\n"
            "backend/.env veya data_pipeline/.env dosyasına SERVER key ekleyin."
        )

    session = _build_session()
    try:
        _ensure_key_works(session)
    except PlacesKeyError as exc:
        raise SystemExit(str(exc)) from exc

    if args.validate_key:
        return

    places_path = Path(PROCESSED_DIR) / "places.csv"
    cache_path = Path(IMAGE_URLS_JSON)
    if not places_path.exists():
        raise SystemExit(f"places.csv bulunamadı: {places_path}")

    with open(places_path, encoding="utf-8-sig", newline="") as f:
        rows = list(csv.DictReader(f))

    batch = rows[args.offset : args.offset + args.limit]
    print(f"Toplam mekan: {len(rows)} | Batch: {args.offset}..{args.offset + len(batch)}")

    if args.dry_run:
        print(f"Dry-run: {len(batch)} kayıt işlenecek → {cache_path}")
        return

    cache = _load_cache(cache_path)
    ok = skip = empty = android_errors = 0

    try:
        for row in batch:
            place_id = (row.get("Place ID") or "").strip()
            name = (row.get("Place Name") or place_id)[:50]
            if not place_id:
                continue

            existing = cache.get(place_id, {})
            if args.retry_failed and not existing.get("imageUrl"):
                cache.pop(place_id, None)
                existing = {}

            if existing.get("imageUrl"):
                skip += 1
                continue

            entry, error_kind = fetch_photo_entry(session, place_id, max_height=args.max_height)
            if entry:
                cache[place_id] = entry
                ok += 1
                print(f"  ✓ {name}")
            elif error_kind == "android":
                android_errors += 1
                print(f"  ✗ {name} (Android key kısıtı — atlandı, cache'e yazılmadı)")
            else:
                if error_kind is None:
                    cache[place_id] = {"imageUrl": "", "photoAttribution": ""}
                    empty += 1
                    print(f"  – {name} (fotoğraf yok)")
                else:
                    print(f"  ? {name} (geçici hata — cache'e yazılmadı, sonra tekrar dene)")

            if ok and ok % 25 == 0:
                _save_cache(cache_path, cache)

            time.sleep(args.sleep)
    finally:
        session.close()

    _save_cache(cache_path, cache)
    with_url = sum(1 for v in cache.values() if v.get("imageUrl"))
    print(
        f"\nBitti → {cache_path}\n"
        f"  Bu batch: {ok} yeni URL, {skip} zaten vardı, {empty} fotoğraf yok, {android_errors} Android 403\n"
        f"  Cache toplam: {len(cache)} kayıt, {with_url} görsel URL"
    )
    if android_errors:
        print(
            "\nUyarı: Android 403 alındı. Cloud Console'da key → Application restrictions = None "
            "olduğundan emin olun, 2-3 dk bekleyip --retry-failed ile tekrar çalıştırın."
        )


if __name__ == "__main__":
    main()
