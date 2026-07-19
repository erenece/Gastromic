import json
from pathlib import Path
import pandas as pd
from apify_client import ApifyClient
from config import PROCESSED_DIR, RAW_DIR, APIFY_API_TOKEN
 
ACTOR_ID = "beatanalytics/google-maps-place-details-scraper"
CHUNK_SIZE = 200
OUT_PATH = Path(RAW_DIR) / "popular_times_raw.json"
 
 
def load_places():
    places_path = Path(PROCESSED_DIR) / "places.csv"
    if not places_path.exists():
        print("places.csv NOT FOUND")
        raise SystemExit(f"{places_path} not found")
    df = pd.read_csv(places_path)
    return df
 
 
def load_saved_results():
    if not OUT_PATH.exists():
        return {}
 
    f = open(OUT_PATH, "r", encoding="utf-8")
    saved_list = json.load(f)
    f.close()
 
    results = {}
    for item in saved_list:
        results[item["place_id"]] = item
 
    return results
 
 
def save_results(results):
    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
 
    all_items = []
    for key in results:
        all_items.append(results[key])
 
    tmp_path = OUT_PATH.with_suffix(".json.tmp")
    f = open(tmp_path, "w", encoding="utf-8")
    json.dump(all_items, f, ensure_ascii=False, indent=2)
    f.close()
 
    tmp_path.replace(OUT_PATH)
 
def main():
    if APIFY_API_TOKEN == "":
        print("APIFY_API_TOKEN NOT SET")
        raise SystemExit("APIFY_API_TOKEN not set")
 
    places_df = load_places()
 
    name_by_id = {}
    for i in range(len(places_df)):
        row = places_df.iloc[i]
        name_by_id[row["Place ID"]] = row["Place Name"]
 
    results = load_saved_results()
 
    todo_ids = []
    for pid in name_by_id:
        if pid not in results:
            todo_ids.append(pid)
 
    print("Total places:", len(name_by_id), "| already saved:", len(results), "| to fetch:", len(todo_ids))
 
    client = ApifyClient(APIFY_API_TOKEN)
 
    batch_num = 0
    i = 0
    while i < len(todo_ids):
        batch_ids = todo_ids[i:i + CHUNK_SIZE]
        batch_num = batch_num + 1
 
        print(f"Batch {batch_num}: {len(batch_ids)} places")
 
        try:
            run = client.actor(ACTOR_ID).call(run_input={"placeIds": batch_ids})
        except Exception as e:
            print("  stopped:", e)
            print("  progress saved so far:", len(results), "places")
            break
 
        if run is None or run.status != "SUCCEEDED":
            if run:
                status = run.status
            else:
                status = "no run returned"
            print("  batch failed (status:", status, "), skipping")
            i = i + CHUNK_SIZE
            continue
 
        found = 0
        dataset_items = client.dataset(run.default_dataset_id).iterate_items()
        for item in dataset_items:
            place_id = item.get("placeId")
 
            if not place_id:
                continue
            if not item.get("popularTimes"):
                continue
 
            new_record = {}
            new_record["place_id"] = place_id
            new_record["place_name"] = name_by_id.get(place_id, "")
            new_record["matched_name"] = item.get("name")
            new_record["rating"] = item.get("rating")
            new_record["rating_n"] = item.get("reviewCount")
            new_record["populartimes"] = item.get("popularTimes")
 
            results[place_id] = new_record
            found = found + 1
 
        print("  ok:", found, "/", len(batch_ids))
        save_results(results)
 
        i = i + CHUNK_SIZE
 
    print("Done. Total saved:", len(results), "->", OUT_PATH)
 
 
if __name__ == "__main__":
    main()