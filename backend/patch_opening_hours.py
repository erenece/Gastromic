"""Firestore venues — Google Places'ten çalışma saatlerini günceller."""
from __future__ import annotations

import argparse
import sys
import time
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT))

from backend.firestore_seed import _init_firebase
from backend.opening_hours import fetch_place_hours, format_opening_hours


def patch(
    env: str,
    *,
    dry_run: bool = False,
    limit: int | None = None,
    skip_existing: bool = False,
) -> dict:
    db, project, cred = _init_firebase(env)
    print(f"Firestore opening hours patch -> {project} ({cred})")

    docs = list(db.collection("venues").stream())
    if limit:
        docs = docs[:limit]

    updated = 0
    skipped = 0
    failed = 0

    for doc in docs:
        data = doc.to_dict() or {}
        if skip_existing and data.get("openingHoursWeek"):
            skipped += 1
            continue

        if dry_run:
            updated += 1
            continue

        try:
            raw, api_error = fetch_place_hours(doc.id)
            hours = format_opening_hours(raw)
            if api_error:
                print(f"  ✗ {doc.id}: {api_error}")
                failed += 1
                time.sleep(0.4)
                continue
        except Exception as exc:
            print(f"  ✗ {doc.id}: {exc}")
            failed += 1
            time.sleep(0.3)
            continue

        if hours["workingHours"] == "Bilgi mevcut değil" and not hours["openingHoursWeek"]:
            print(f"  - {doc.id}: Google'da saat bilgisi yok")
            skipped += 1
            time.sleep(0.15)
            continue

        print(f"  OK {doc.id}: {hours['workingHours'][:70]}")

        payload = {
            "workingHours": hours["workingHours"],
            "openingHoursWeek": hours["openingHoursWeek"],
        }
        if hours["isOpenNow"] is not None:
            payload["isOpenNow"] = hours["isOpenNow"]

        doc.reference.set(payload, merge=True)
        updated += 1
        if updated % 25 == 0:
            print(f"  … {updated} mekan güncellendi")
        time.sleep(0.15)

    return {
        "env": env,
        "dry_run": dry_run,
        "updated": updated,
        "skipped": skipped,
        "failed": failed,
        "total": len(docs),
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Firestore çalışma saatlerini güncelle")
    parser.add_argument("--env", choices=["dev", "prod"], default="dev")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--limit", type=int, default=None)
    parser.add_argument(
        "--skip-existing",
        action="store_true",
        help="openingHoursWeek dolu olanları atla",
    )
    args = parser.parse_args()
    result = patch(
        args.env,
        dry_run=args.dry_run,
        limit=args.limit,
        skip_existing=args.skip_existing,
    )
    print(result)


if __name__ == "__main__":
    main()
