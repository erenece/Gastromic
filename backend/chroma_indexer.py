"""places.csv → ChromaDB indeksleme."""
from __future__ import annotations

import pandas as pd

from .config import PLACES_CSV
from .database import collection


def index_places_from_csv() -> dict:
    if not PLACES_CSV.exists():
        return {"error": f"CSV bulunamadı: {PLACES_CSV}"}

    df = pd.read_csv(PLACES_CSV)
    df["Category"] = df.groupby("Place ID")["Category"].transform(
        lambda x: ", ".join(x.dropna().unique())
    )
    df = df.drop_duplicates(subset=["Place ID"])

    documents: list[str] = []
    ids: list[str] = []
    metadatas: list[dict] = []

    for _, row in df.iterrows():
        content = (
            f"Mekan: {row['Place Name']}, Kategori: {row['Category']}, "
            f"Adres: {row['Address']}, Puan: {row['Average Rating']}"
        )
        documents.append(content)
        ids.append(str(row["Place ID"]))
        metadatas.append({"city": str(row["City"]), "category": str(row["Category"])})

    collection.upsert(documents=documents, ids=ids, metadatas=metadatas)
    return {"status": "success", "indexed": len(df)}


def index_popular_times(json_path) -> dict:
    import json
    from pathlib import Path

    path = Path(json_path)
    if not path.exists():
        return {"error": f"popular_times_raw.json bulunamadı: {path}"}

    with open(path, "r", encoding="utf-8") as f:
        popular_data = json.load(f)

    documents: list[str] = []
    ids: list[str] = []
    metadatas: list[dict] = []

    for item in popular_data:
        place_id = item.get("place_id")
        place_name = item.get("place_name")
        pop_times = item.get("populartimes", [])

        time_summaries = []
        for day_info in pop_times:
            day_name = day_info.get("name", "")
            hours = day_info.get("hours", [])
            busy_hours = [
                f"Saat {h['hour']}: %{h['percentage']}"
                for h in hours
                if h.get("percentage", 0) > 50
            ]
            if busy_hours:
                time_summaries.append(f"{day_name} günü yoğun saatler: {', '.join(busy_hours)}")

        time_text = " | ".join(time_summaries) if time_summaries else "Yoğunluk verisi bulunmuyor."
        content = f"Mekan Yoğunluk Analizi - Adı: {place_name}. {time_text}"
        documents.append(content)
        ids.append(f"pop_{place_id}")
        metadatas.append({"type": "popular_times", "place_id": str(place_id)})

    if documents:
        collection.upsert(documents=documents, ids=ids, metadatas=metadatas)
    return {"status": "success", "indexed": len(documents)}
