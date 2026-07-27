"""CSV verilerini Firestore `venues` koleksiyonuna yükler."""
from __future__ import annotations

import argparse
import csv
import json
import os
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT))
sys.path.insert(0, str(REPO_ROOT / "ai_pipeline"))

from backend.config import (
    DEFAULT_SERVICE_ACCOUNT_DEV,
    DEFAULT_SERVICE_ACCOUNT_PROD,
    DEFAULT_VISIT_DAY,
    DEFAULT_VISIT_HOUR,
    FIREBASE_PROJECT_DEV,
    FIREBASE_PROJECT_PROD,
    FIREBASE_SERVICE_ACCOUNT_DEV,
    FIREBASE_SERVICE_ACCOUNT_PROD,
    IMAGE_URLS_JSON,
    PLACES_CSV,
    REVIEWS_CSV,
    SECRETS_DIR,
)

from gastro_agents.conflicts import estimate_cost
from gastro_agents.tools.density_tool import busyness_at

_PRICE_ENUM = {
    "PRICE_LEVEL_FREE": 1,
    "PRICE_LEVEL_INEXPENSIVE": 1,
    "PRICE_LEVEL_MODERATE": 2,
    "PRICE_LEVEL_EXPENSIVE": 3,
    "PRICE_LEVEL_VERY_EXPENSIVE": 4,
}


def _price_level(raw) -> int:
    if raw in (None, ""):
        return 2
    key = str(raw).strip().upper()
    if key in _PRICE_ENUM:
        return _PRICE_ENUM[key]
    try:
        return int(float(raw))
    except (TypeError, ValueError):
        return 2


def _to_float(value):
    try:
        return None if value in (None, "") else float(value)
    except (TypeError, ValueError):
        return None


def _to_int(value):
    try:
        return None if value in (None, "") else int(float(value))
    except (TypeError, ValueError):
        return None


def _tourist_trap_score(rating, review_count) -> float:
    r = _to_float(rating)
    n = _to_int(review_count)
    if r is None or n is None:
        return 0.0
    score = 0.0
    if n > 10000:
        score += 0.5
    if r < 4.0:
        score += 0.5
    return round(min(score, 1.0), 2)


def _split_category(category: str) -> tuple[str, str]:
    if not category:
        return "", ""
    parts = [p.strip() for p in category.split(",") if p.strip()]
    if not parts:
        return "", ""
    if len(parts) == 1:
        return parts[0], parts[0]
    return parts[0], parts[1]


def _extract_district(address: str, city: str) -> str:
    if not address:
        return city or ""
    match = re.search(r"/([^/,]+)/", address)
    if match:
        return match.group(1).strip()
    return city or ""


def _load_places() -> list[dict]:
    if not PLACES_CSV.exists():
        raise FileNotFoundError(f"places.csv bulunamadı: {PLACES_CSV}")

    by_id: dict[str, dict] = {}
    with open(PLACES_CSV, "r", encoding="utf-8-sig", newline="") as f:
        for row in csv.DictReader(f):
            place_id = (row.get("Place ID") or "").strip()
            if not place_id:
                continue
            category = row.get("Category") or ""
            if place_id in by_id:
                existing = by_id[place_id]["Category"]
                merged = ", ".join(dict.fromkeys([c.strip() for c in f"{existing},{category}".split(",") if c.strip()]))
                row["Category"] = merged
            by_id[place_id] = row
    return list(by_id.values())


def _load_reviews_by_place() -> dict[str, list[dict]]:
    if not REVIEWS_CSV.exists():
        return {}
    grouped: dict[str, list[dict]] = {}
    with open(REVIEWS_CSV, "r", encoding="utf-8-sig", newline="") as f:
        for idx, row in enumerate(csv.DictReader(f)):
            place_id = (row.get("Place ID") or "").strip()
            if not place_id:
                continue
            grouped.setdefault(place_id, []).append(
                {
                    "id": f"seed_{idx}",
                    "author": row.get("Author") or "Anonim",
                    "rating": _to_float(row.get("Author Rating")) or 0.0,
                    "comment": row.get("Review Text") or "",
                    "date": row.get("Date") or "",
                }
            )
    return grouped


def _load_image_urls() -> dict[str, dict]:
    if not IMAGE_URLS_JSON.exists():
        return {}
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


def _venue_doc(row: dict, image_urls: dict[str, dict]) -> dict:
    place_id = row["Place ID"]
    category, sub_category = _split_category(row.get("Category") or "")
    city = row.get("City") or ""
    address = row.get("Address") or ""
    price_level = _price_level(row.get("Price Level"))
    rating = _to_float(row.get("Average Rating")) or 0.0
    review_count = _to_int(row.get("Total Review Count")) or 0
    busyness = busyness_at(place_id, DEFAULT_VISIT_DAY, DEFAULT_VISIT_HOUR)
    image = image_urls.get(place_id, {})
    working_hours, opening_week, is_open_now = _opening_hours_from_row(row)

    doc = {
        "name": row.get("Place Name") or "",
        "rating": rating,
        "reviewCount": review_count,
        "imageUrl": image.get("imageUrl") or row.get("Image URL") or "",
        "photoAttribution": image.get("photoAttribution") or "",
        "category": category,
        "subCategory": sub_category,
        "city": city,
        "district": _extract_district(address, city),
        "address": address,
        "latitude": _to_float(row.get("Latitude")) or 0.0,
        "longitude": _to_float(row.get("Longitude")) or 0.0,
        "priceLevel": price_level,
        "price": estimate_cost(price_level),
        "busyness": busyness if busyness is not None else 0.5,
        "types": row.get("Types") or "",
        "isOpenNow": is_open_now if is_open_now is not None else True,
        "touristTrapScore": _tourist_trap_score(rating, review_count),
    }
    if working_hours:
        doc["workingHours"] = working_hours
    if opening_week:
        doc["openingHoursWeek"] = opening_week
    return doc


def _opening_hours_from_row(row: dict) -> tuple[str, list[str], bool | None]:
    working = (row.get("Working Hours") or "").strip()
    week_raw = (row.get("Opening Hours Week") or "").strip()
    week: list[str] = []
    if week_raw:
        try:
            parsed = json.loads(week_raw)
            if isinstance(parsed, list):
                week = [str(x) for x in parsed if str(x).strip()]
        except json.JSONDecodeError:
            week = []

    open_raw = row.get("Is Open Now")
    is_open_now: bool | None
    if open_raw in (None, ""):
        is_open_now = None
    elif isinstance(open_raw, bool):
        is_open_now = open_raw
    else:
        is_open_now = str(open_raw).strip().lower() in {"true", "1", "yes", "evet"}

    return working, week, is_open_now


def _as_abs(path: Path) -> Path:
    return path if path.is_absolute() else REPO_ROOT / path


def _resolve_service_account(env: str) -> tuple[str, Path | None]:
    """Service account JSON yolunu çözümler (env → GOOGLE_APPLICATION_CREDENTIALS → secrets/)."""
    if env == "dev":
        project = FIREBASE_PROJECT_DEV
        explicit = FIREBASE_SERVICE_ACCOUNT_DEV
        defaults = [DEFAULT_SERVICE_ACCOUNT_DEV]
        glob_pattern = "gastromic-dev*.json"
    else:
        project = FIREBASE_PROJECT_PROD
        explicit = FIREBASE_SERVICE_ACCOUNT_PROD
        defaults = [DEFAULT_SERVICE_ACCOUNT_PROD]
        glob_pattern = "gastromic-prod*.json"

    candidates: list[Path] = []
    if explicit:
        candidates.append(_as_abs(Path(explicit)))
    gac = os.getenv("GOOGLE_APPLICATION_CREDENTIALS", "").strip()
    if gac:
        candidates.append(_as_abs(Path(gac)))
    candidates.extend(_as_abs(p) for p in defaults)
    candidates.extend(sorted(SECRETS_DIR.glob(glob_pattern)))

    seen: set[Path] = set()
    for path in candidates:
        resolved = path.resolve()
        if resolved in seen:
            continue
        seen.add(resolved)
        if resolved.is_file():
            return project, resolved
    return project, None


def _init_firebase(env: str):
    import firebase_admin
    from firebase_admin import credentials, firestore

    project, sa_path = _resolve_service_account(env)

    if sa_path is not None:
        cred = credentials.Certificate(str(sa_path))
        firebase_admin.initialize_app(cred, {"projectId": project})
        return firestore.client(), project, str(sa_path)

    # Son çare: Application Default Credentials (gcloud auth application-default login)
    try:
        cred = credentials.ApplicationDefault()
        firebase_admin.initialize_app(cred, {"projectId": project})
        return firestore.client(), project, "application-default"
    except Exception:
        pass

    secrets_hint = SECRETS_DIR / ("gastromic-dev.json" if env == "dev" else "gastromic-prod.json")
    raise SystemExit(
        f"\nFirestore bağlantısı kurulamadı ({env}).\n\n"
        f"1) Firebase Console → Project Settings → Service Accounts → Generate new private key\n"
        f"2) İndirilen JSON dosyasını şuraya koyun:\n   {secrets_hint}\n"
        f"   veya backend/.env içine yazın:\n"
        f"   FIREBASE_SERVICE_ACCOUNT_{env.upper()}=<json dosya yolu>\n\n"
        f"Proje ID: {project}\n"
        f"Secrets klasörü: {SECRETS_DIR}\n"
    )


def seed(env: str, dry_run: bool = False, review_limit: int = 20) -> dict:
    places = _load_places()
    reviews_by_place = _load_reviews_by_place()

    if dry_run:
        image_urls = _load_image_urls()
        sample = _venue_doc(places[0], image_urls) if places else {}
        return {
            "dry_run": True,
            "venues": len(places),
            "reviews_total": sum(len(v) for v in reviews_by_place.values()),
            "image_urls_cached": len(image_urls),
            "sample_venue_id": places[0]["Place ID"] if places else None,
            "sample_doc": sample,
        }

    db, project, cred_source = _init_firebase(env)
    print(f"Firestore bağlantısı OK → proje: {project}, kimlik: {cred_source}")
    image_urls = _load_image_urls()
    if image_urls:
        with_url = sum(1 for v in image_urls.values() if v.get("imageUrl"))
        print(f"Görsel cache: {with_url}/{len(image_urls)} mekan")
    batch = db.batch()
    batch_count = 0
    venue_count = 0
    review_count = 0

    for row in places:
        place_id = row["Place ID"]
        venue_ref = db.collection("venues").document(place_id)
        batch.set(venue_ref, _venue_doc(row, image_urls))
        batch_count += 1
        venue_count += 1

        if batch_count >= 450:
            batch.commit()
            batch = db.batch()
            batch_count = 0

        for review in reviews_by_place.get(place_id, [])[:review_limit]:
            review_ref = venue_ref.collection("reviews").document(review["id"])
            batch.set(
                review_ref,
                {
                    "userName": review["author"],
                    "rating": review["rating"],
                    "comment": review["comment"],
                    "date": review["date"],
                    "source": "google_places_seed",
                },
            )
            batch_count += 1
            review_count += 1
            if batch_count >= 450:
                batch.commit()
                batch = db.batch()
                batch_count = 0

    if batch_count:
        batch.commit()

    return {"env": env, "venues": venue_count, "reviews": review_count}


def main():
    parser = argparse.ArgumentParser(description="Firestore venue seed")
    parser.add_argument("--env", choices=["dev", "prod"], default="dev")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--review-limit", type=int, default=20)
    args = parser.parse_args()
    result = seed(args.env, dry_run=args.dry_run, review_limit=args.review_limit)
    print(result)


if __name__ == "__main__":
    main()
