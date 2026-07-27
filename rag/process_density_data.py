import json
from pathlib import Path
import pandas as pd
from config import PROCESSED_DIR, RAW_DIR
 
MIN_DAYS_REQUIRED = 5
RAW_PATH = Path(RAW_DIR) / "popular_times_raw.json"
PLACES_PATH = Path(PROCESSED_DIR) / "places.csv"
OUT_PATH = Path(PROCESSED_DIR) / "density_training_data.csv"
 
 
def load_raw():
    if not RAW_PATH.exists():
        print("popular_times_raw.json not found")
        raise SystemExit(f"{RAW_PATH} not found")
 
    f = open(RAW_PATH, "r", encoding="utf-8")
    data = json.load(f)
    f.close()
    return data
 
def load_places():
    if not PLACES_PATH.exists():
        print("places.csv not found")
        raise SystemExit(f"{PLACES_PATH} not found")
    return pd.read_csv(PLACES_PATH)
 
def flatten(raw_data):
    rows = []
    skipped_places = 0
 
    for place in raw_data:
        days = place.get("populartimes", [])
 
        if len(days) < MIN_DAYS_REQUIRED:
            skipped_places = skipped_places + 1
            continue
 
        for day in days:
            day_name = day.get("day")
            hour_list = day.get("data", [])
 
            for entry in hour_list:
                new_row = {}
                new_row["place_id"] = place["place_id"]
                new_row["day_of_week"] = day_name
                new_row["hour"] = entry.get("hour")
                new_row["busyness"] = entry.get("busyness")
                rows.append(new_row)
 
    print("Places skipped (fewer than", MIN_DAYS_REQUIRED, "days of data):", skipped_places)
 
    result_df = pd.DataFrame(rows)
    return result_df
 
def main():
    raw_data = load_raw()
    places_df = load_places()
    print("Raw popular-times records:", len(raw_data))
 
    flat_df = flatten(raw_data)
    print("Flattened rows (place x day x hour):", len(flat_df))
 
    before = len(flat_df)
    flat_df = flat_df.dropna(subset=["busyness"])
    after = len(flat_df)
    if before != after:
        print("Dropped", before - after, "rows with missing busyness")
 
    features = places_df.rename(columns={"Place ID": "place_id"})
    training_df = flat_df.merge(features, on="place_id", how="left")
    unmatched = training_df["Category"].isna().sum()
    if unmatched > 0:
        print(unmatched, "rows could not be matched to places.csv")
        training_df = training_df.dropna(subset=["Category"])
 
    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    training_df.to_csv(OUT_PATH, index=False)
 
    print("Places in final dataset:", training_df["place_id"].nunique())
    print("Done.", len(training_df), "rows ->", OUT_PATH)
 
if __name__ == "__main__":
    main()