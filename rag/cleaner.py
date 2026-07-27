import pandas as pd
import numpy as np
import os
from config import PROCESSED_DIR, RAW_DIR

np.random.seed(42)

def clean_places():
   
         
    file_path = os.path.join(PROCESSED_DIR, "places.csv")
    file_path_json = os.path.join(RAW_DIR, "google_places_raw.json")

    if not os.path.exists(file_path):
        print("File was not found")
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
#WLKFM





    if "Category" in df.columns:
        df["Category"] = df["Category"].replace(category_map)

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
    file_path = os.path.join(PROCESSED_DIR, "places.csv")
    file_path_json = os.path.join(RAW_DIR, "google_places_raw.json")

    if not os.path.exists(file_path):
        print("Reviews file was not found")
        return

    df = pd.read_csv(file_path)

    if "Author" in df.columns:
        df["Author"] = df["Author"].astype(str).apply(
            lambda x: " ".join([p[0].upper() + "." for p in x.split()])
        )

    df.to_csv(file_path, index=False, encoding="utf-8-sig")

if __name__ == "__main__":
    clean_places()
    clean_reviews()