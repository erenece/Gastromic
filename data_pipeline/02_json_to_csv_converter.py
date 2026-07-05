import json
import pandas as pd
import os
from config import RAW_DIR, PROCESSED_DIR

output_folder = PROCESSED_DIR
file_name = os.path.join(RAW_DIR, "google_places_raw.json")
os.makedirs(output_folder, exist_ok=True)

with open(file_name, "r", encoding="utf-8") as f:
    json_data = json.load(f)

places_list = []
reviews_list = []

for place in json_data:
    place_id = place.get("place_id")

    types_text = ", ".join(place.get("tipler", []))

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
        "Price Level": place.get("fiyat_seviyesi")
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