"""image_urls.json → Firestore venues.imageUrl (yalnızca görsel alanlarını günceller)."""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT))

from backend.config import IMAGE_URLS_JSON
from backend.firestore_seed import _init_firebase


def _load_image_cache() -> dict[str, dict]:
    if not IMAGE_URLS_JSON.exists():
        raise SystemExit(f"image_urls.json bulunamadı: {IMAGE_URLS_JSON}\nÖnce: python data_pipeline/06_fetch_photos.py")
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


def patch(env: str, dry_run: bool = False, limit: int | None = None) -> dict:
    cache = _load_image_cache()
    items = [(pid, data) for pid, data in cache.items() if data.get("imageUrl")]
    if limit:
        items = items[:limit]

    if dry_run:
        return {
            "dry_run": True,
            "would_update": len(items),
            "sample": items[0] if items else None,
        }

    db, project, cred = _init_firebase(env)
    print(f"Firestore patch → {project} ({cred})")

    batch = db.batch()
    batch_count = 0
    updated = 0

    for place_id, data in items:
        batch.set(
            db.collection("venues").document(place_id),
            {
                "imageUrl": data["imageUrl"],
                "photoAttribution": data.get("photoAttribution") or "",
            },
            merge=True,
        )
        batch_count += 1
        updated += 1
        if batch_count >= 450:
            batch.commit()
            batch = db.batch()
            batch_count = 0

    if batch_count:
        batch.commit()

    return {"env": env, "updated": updated, "skipped_empty": len(cache) - len(items)}


def main() -> None:
    parser = argparse.ArgumentParser(description="Firestore venue görsellerini güncelle")
    parser.add_argument("--env", choices=["dev", "prod"], default="dev")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--limit", type=int, default=None, help="Test için ilk N kayıt")
    args = parser.parse_args()
    result = patch(args.env, dry_run=args.dry_run, limit=args.limit)
    print(result)


if __name__ == "__main__":
    main()
