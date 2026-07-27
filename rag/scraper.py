import json
import time
import requests
from pathlib import Path

from config import (
    GOOGLE_PLACES_API_KEY,
    MAX_ENTERPRISE_CALLS_PER_RUN,
    MAX_RESULTS_PER_QUERY,
    CITIES,
    CATEGORIES,
    RAW_DIR,
)

TEXT_SEARCH_URL = "https://places.googleapis.com/v1/places:searchText"
DETAILS_URL = "https://places.googleapis.com/v1/places/{place_id}"

SEARCH_FIELD_MASK = (
    "places.id,places.displayName,places.formattedAddress,"
    "places.location,places.types,nextPageToken"
)

DETAILS_FIELD_MASK = (
    "id,displayName,rating,userRatingCount,priceLevel,"
    "reviews.rating,reviews.text,reviews.originalText,"
    "reviews.authorAttribution,reviews.publishTime,"
    "reviews.relativePublishTimeDescription"
)

enterprise_call_count = 0


def text_search(query: str, max_results: int = 60) -> list[dict]:
    headers = {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": GOOGLE_PLACES_API_KEY,
        "X-Goog-FieldMask": SEARCH_FIELD_MASK,
    }
    all_places = []
    page_token = None

    while len(all_places) < max_results:
        body = {"textQuery": query, "languageCode": "tr"}
        if page_token:
            body["pageToken"] = page_token
            time.sleep(2)

        resp = requests.post(TEXT_SEARCH_URL, headers=headers, json=body)
        resp.raise_for_status()
        data = resp.json()

        places = data.get("places", [])
        all_places.extend(places)

        page_token = data.get("nextPageToken")
        if not page_token or not places:
            break

    return all_places[:max_results]


def place_details(place_id: str) -> dict | None:
    global enterprise_call_count
    if enterprise_call_count >= MAX_ENTERPRISE_CALLS_PER_RUN:
        print(f" Enterprise kota tavanına ulaşıldı ({MAX_ENTERPRISE_CALLS_PER_RUN}). Duruluyor.")
        return None

    headers = {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": GOOGLE_PLACES_API_KEY,
        "X-Goog-FieldMask": DETAILS_FIELD_MASK,
    }
    url = DETAILS_URL.format(place_id=place_id) + "?languageCode=tr"
    resp = requests.get(url, headers=headers)
    enterprise_call_count += 1
    if resp.status_code != 200:
        print(f"  ✗ Detay alınamadı ({place_id}): {resp.status_code}")
        return None
    return resp.json()


def main():
    if not GOOGLE_PLACES_API_KEY:
        raise SystemExit("GOOGLE_PLACES_API_KEY .env dosyasında bulunamadı.")

    Path(RAW_DIR).mkdir(parents=True, exist_ok=True)
    all_venues = []

    for city in CITIES:
        for category in CATEGORIES:
            query = f"{category} {city}"
            print(f" Aranıyor: {query}")
            try:
                places = text_search(query, max_results=MAX_RESULTS_PER_QUERY)
            except requests.HTTPError as e:
                print(f"  ✗ Arama hatası: {e}")
                continue

            print(f"  → {len(places)} mekan bulundu")

            for place in places:
                place_id = place.get("id")
                if not place_id:
                    continue

                details = place_details(place_id)

                venue = {
                    "place_id": place_id,
                    "mekan_adi": place.get("displayName", {}).get("text", ""),
                    "sehir": city,
                    "kategori": category,
                    "adres": place.get("formattedAddress", ""),
                    "konum": place.get("location", {}),
                    "tipler": place.get("types", []),
                    "puan": details.get("rating") if details else None,
                    "yorum_sayisi": details.get("userRatingCount") if details else None,
                    "fiyat_seviyesi": details.get("priceLevel") if details else None,
                    "google_yorumlari": [
                        {
                            "yazar": r.get("authorAttribution", {}).get("displayName", ""),
                            "puan": r.get("rating"),
                            "yorum": r.get("text", {}).get("text", ""),
                            "tarih": r.get("relativePublishTimeDescription", ""),
                        }
                        for r in (details.get("reviews", []) if details else [])
                    ],
                }
                all_venues.append(venue)

                time.sleep(0.2)

            time.sleep(0.5)

    save_and_exit(all_venues)


def save_and_exit(venues: list[dict]):
    out_path = Path(RAW_DIR) / "google_places_raw.json"
    out_path.write_text(json.dumps(venues, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"\n Toplam {len(venues)} mekan kaydedildi → {out_path}")
    print(f"   Enterprise (yorum) çağrısı kullanımı: {enterprise_call_count}/{MAX_ENTERPRISE_CALLS_PER_RUN}")


if __name__ == "__main__":
    main()