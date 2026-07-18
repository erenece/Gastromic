import pandas as pd
import numpy as np
import os
from config import PROCESSED_DIR

np.random.seed(42)

def clean_places():
    file_path = os.path.join(PROCESSED_DIR, "places.csv")

    if not os.path.exists(file_path):
        print("places.csv file was not found")
        return

    df = pd.read_csv(file_path)

    category_map = {
    "restoran": "Restaurant",
    "kahvaltı salonu": "Breakfast Restaurant",
    "kebapçı": "Kebab Restaurant",
    "balık restoranı": "Seafood Restaurant",
    "meyhane": "Tavern",
    "kafe": "Cafe",
    "tatlıcı": "Dessert Shop",
    "lokanta": "Traditional Restaurant",
    "dünya mutfağı restoranı": "International Restaurant",
    "pub": "Pub",
    "vejetaryen restoran": "Vegetarian Restaurant",
    "vegan restoran": "Vegan Restaurant"
    }

    if "Category" in df.columns:
        df["Category"] = df["Category"].replace(category_map)

    if "Place ID" in df.columns:
        before = len(df)

        agg_rules = {}
        if "Place Name" in df.columns:
            agg_rules["Place Name"] = "first"
        if "City" in df.columns:
            agg_rules["City"] = "first"
        if "Category" in df.columns:
            agg_rules["Category"] = lambda s: ", ".join(sorted(set(s.dropna())))
        if "Address" in df.columns:
            agg_rules["Address"] = "first"
        if "Latitude" in df.columns:
            agg_rules["Latitude"] = "first"
        if "Longitude" in df.columns:
            agg_rules["Longitude"] = "first"
        if "Types" in df.columns:
            agg_rules["Types"] = "first"
        if "Average Rating" in df.columns:
            agg_rules["Average Rating"] = "mean"
        if "Total Review Count" in df.columns:
            agg_rules["Total Review Count"] = "max"
        if "Price Level" in df.columns:
            agg_rules["Price Level"] = lambda s: (
                s.mode().iloc[0] if not s.mode().empty
                else (s.dropna().iloc[0] if s.notna().any() else np.nan)
            )

        df = df.groupby("Place ID", as_index=False).agg(agg_rules)

        removed = before - len(df)
        if removed > 0:
            print(f"Dedupe: {before} rows -> {len(df)} unique places ({removed} duplicate rows merged)")

    if "Average Rating" in df.columns:
        missing_rating = df["Average Rating"].isna()
        df.loc[missing_rating, "Average Rating"] = np.random.uniform(2.0, 5.0, size=missing_rating.sum()).round(1)

    if "Total Review Count" in df.columns:
        missing_reviews = df["Total Review Count"].isna()
        df.loc[missing_reviews, "Total Review Count"] = np.random.randint(10, 2000, size=missing_reviews.sum())

    if "Price Level" in df.columns:
        categories = df["Price Level"].dropna().unique()
        if len(categories) > 0:
            missing_price = df["Price Level"].isna()
            df.loc[missing_price, "Price Level"] = np.random.choice(categories, size=missing_price.sum())

    df.to_csv(file_path, index=False, encoding="utf-8-sig")

    print(df.isnull().sum())

def clean_reviews():
    file_path = os.path.join(PROCESSED_DIR, "reviews.csv")

    if not os.path.exists(file_path):
        print("reviews.csv file was not found")
        return

    df = pd.read_csv(file_path)

    before1 = len(df)

    df = df.dropna(subset=['Review Text'])
    df = df.drop_duplicates(subset=['Review Text'])

    removed1 = before1 - len(df)
    if removed1 > 0:
        print(f"Reviews: {removed1} records removed, {len(df)} records remaining.")

    if "Author" in df.columns:
        df["Author"] = df["Author"].astype(str).apply(
            lambda x: " ".join([p[0].upper() + "." for p in x.split()])
        )

    df.to_csv(file_path, index=False, encoding="utf-8-sig")

    print(df.isnull().sum())

if __name__ == "__main__":
    clean_places()
    clean_reviews()