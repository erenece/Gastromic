import json
import pandas as pd
import os
from config import RAW_DIR, PROCESSED_DIR

output_folder = PROCESSED_DIR
file_name = os.path.join(RAW_DIR, "google_places_raw.json")
os.makedirs(output_folder, exist_ok=True)


def _format_hours(place: dict) -> tuple[str, str]:
    regular = place.get("regular_opening_hours") or {}
    current = place.get("current_opening_hours") or {}
    week = regular.get("weekdayDescriptions") or []
    week_json = json.dumps(week, ensure_ascii=False)
    if not week:
        return "", week_json
    open_now = current.get("openNow")
    if open_now is None:
        open_now = regular.get("openNow")
    line = week[0]
    if open_now is not None:
        line = f"{line} · {'Açık' if open_now else 'Kapalı'}"
    return line, week_json

with open(file_name, "r", encoding="utf-8") as f:
    json_data = json.load(f)

places_list = []
reviews_list = []

for place in json_data:
    place_id = place.get("place_id")

    types_text = ", ".join(place.get("tipler", []))
    working_hours, opening_week_json = _format_hours(place)
    open_now = (place.get("current_opening_hours") or {}).get("openNow")
    if open_now is None:
        open_now = (place.get("regular_opening_hours") or {}).get("openNow")

    place_row = {
        "Place ID": place_id,
        "Place Name": place.get("mekan_adi"),
        "City": place.get("sehir"),
        "Category": place.get("kategori"),
        "Address": place.get("adres"),
        "Latitude": place.get("konum", {}).get("latitude"),
        "Longitude": place.get("konum", {}).get("longitude"),
        "Types": types_text,
        "Average Rating": place.get("puan"),
        "Total Review Count": place.get("yorum_sayisi"),
        "Price Level": place.get("fiyat_seviyesi"),
        "Working Hours": working_hours,
        "Opening Hours Week": opening_week_json,
        "Is Open Now": open_now,
    }
    places_list.append(place_row)

    for review in place.get("google_yorumlari", []):
        review_row = {
            "Place ID": place_id,
            "Place Name": place.get("mekan_adi"),
            "Author": review.get("yazar"),
            "Author Rating": review.get("puan"),
            "Date": review.get("tarih"),
            "Review Text": review.get("yorum")
        }
        reviews_list.append(review_row)

df_places = pd.DataFrame(places_list)
df_reviews = pd.DataFrame(reviews_list)

places_path = os.path.join(output_folder, "places.csv")
reviews_path = os.path.join(output_folder, "reviews.csv")

df_places.to_csv(places_path, index=False, encoding="utf-8-sig")
df_reviews.to_csv(reviews_path, index=False, encoding="utf-8-sig")

print("Process completed")