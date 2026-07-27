"""Google Places fotoğraflarını indirip Firebase Storage'a yükler, Firestore imageUrl günceller.

Mobil uygulama places.googleapis.com URL'lerini Android key ile yükleyemez (403).
Bu script görselleri Storage'a koyar — mobil doğrudan firebasestorage URL kullanır.

Kullanım:
  python backend/upload_venue_images.py --env dev --offset 0 --limit 100
  python backend/upload_venue_images.py --env dev --offset 100 --limit 100
"""
from __future__ import annotations

import argparse
import json
import sys
import time
from pathlib import Path
from urllib.parse import quote

import requests

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT))

from backend.config import FIREBASE_PROJECT_DEV, FIREBASE_PROJECT_PROD, IMAGE_URLS_JSON
from backend.firestore_seed import _init_firebase

STORAGE_BUCKET_DEV = "gastromic-dev.firebasestorage.app"
STORAGE_BUCKET_PROD = "gastromic-prod.firebasestorage.app"


def _load_cache() -> dict[str, dict]:
    raw = json.loads(IMAGE_URLS_JSON.read_text(encoding="utf-8"))
    out: dict[str, dict] = {}
    for place_id, value in raw.items():
        if isinstance(value, str):
            out[place_id] = {"imageUrl": value, "photoAttribution": ""}
        elif isinstance(value, dict):
            out[place_id] = {
                "imageUrl": value.get("imageUrl") or "",
                "photoAttribution": value.get("photoAttribution") or "",
            }
    return out


def _public_storage_url(bucket: str, blob_path: str) -> str:
    encoded = quote(blob_path, safe="")
    return f"https://firebasestorage.googleapis.com/v0/b/{bucket}/o/{encoded}?alt=media"


def upload_batch(env: str, offset: int, limit: int, sleep: float, dry_run: bool) -> dict:
    cache = _load_cache()
    items = [(pid, data) for pid, data in cache.items() if data.get("imageUrl")]
    batch = items[offset : offset + limit]
    bucket_name = STORAGE_BUCKET_DEV if env == "dev" else STORAGE_BUCKET_PROD

    if dry_run:
        return {"dry_run": True, "batch_size": len(batch), "bucket": bucket_name}

    db, project, cred = _init_firebase(env)
    print(f"Storage upload → {project} / {bucket_name} ({cred})")

    from firebase_admin import storage

    bucket = storage.bucket(bucket_name)
    ok = skip = fail = 0
    firestore_batch = db.batch()
    batch_count = 0

    for place_id, data in batch:
        google_url = data["imageUrl"]
        blob_path = f"venues/{place_id}/cover.jpg"

        existing = bucket.blob(blob_path)
        if existing.exists():
            public_url = _public_storage_url(bucket_name, blob_path)
            firestore_batch.set(
                db.collection("venues").document(place_id),
                {"imageUrl": public_url, "photoAttribution": data.get("photoAttribution") or ""},
                merge=True,
            )
            batch_count += 1
            skip += 1
            continue

        try:
            resp = requests.get(google_url, timeout=45, allow_redirects=True)
            if resp.status_code != 200 or not resp.content:
                fail += 1
                print(f"  ✗ {place_id[:20]}… download {resp.status_code}")
                continue

            content_type = resp.headers.get("Content-Type", "image/jpeg")
            blob = bucket.blob(blob_path)
            blob.upload_from_string(resp.content, content_type=content_type)
            blob.cache_control = "public, max-age=31536000"
            blob.patch()

            public_url = _public_storage_url(bucket_name, blob_path)
            firestore_batch.set(
                db.collection("venues").document(place_id),
                {"imageUrl": public_url, "photoAttribution": data.get("photoAttribution") or ""},
                merge=True,
            )
            batch_count += 1
            ok += 1
            print(f"  ✓ {place_id[:24]}…")

            if batch_count >= 400:
                firestore_batch.commit()
                firestore_batch = db.batch()
                batch_count = 0

        except Exception as exc:
            fail += 1
            print(f"  ✗ {place_id[:20]}… {type(exc).__name__}")

        time.sleep(sleep)

    if batch_count:
        firestore_batch.commit()

    return {"env": env, "uploaded": ok, "skipped_existing": skip, "failed": fail}


def main() -> None:
    parser = argparse.ArgumentParser(description="Venue görsellerini Firebase Storage'a yükle")
    parser.add_argument("--env", choices=["dev", "prod"], default="dev")
    parser.add_argument("--offset", type=int, default=0)
    parser.add_argument("--limit", type=int, default=100)
    parser.add_argument("--sleep", type=float, default=0.15)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    if not IMAGE_URLS_JSON.exists():
        raise SystemExit(f"Önce 06_fetch_photos.py çalıştırın: {IMAGE_URLS_JSON}")

    result = upload_batch(args.env, args.offset, args.limit, args.sleep, args.dry_run)
    print(result)


if __name__ == "__main__":
    main()
