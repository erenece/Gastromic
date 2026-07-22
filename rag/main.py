from fastapi import FastAPI
from fastapi import Query
from models import GastroData
from database import collection
import pandas as pd
import os
import requests
import xml.etree.ElementTree as ET
from pydantic import BaseModel
from typing import List

app = FastAPI(title="GastroLogic API")
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
@app.get("/health")
async def health_check():
    return {"status": "online", "message": "GastroLogic is ready"}

from fastapi import Query

@app.get("/search")
async def search_places(query: str = Query(..., description="Aranacak kelime veya kriter")):
    # ChromaDB koleksiyonumuzda kullanıcının gönderdiği sorgu ile arama yapıyoruz
    results = collection.query(
        query_texts=[query],
        n_results=5  # En iyi 5 sonucu getirir
    )
    
    return {
        "status": "success",
        "query": query,
        "results": results
    }


@app.get("/")
def read_root():
    return {"message": "GastroLogic API Çalışıyor!"}

@app.post("/add-data")
async def add_data(item: GastroData):
    collection.add(
        documents=[item.content],
        ids=[item.id],
        metadatas=[item.metadata] if item.metadata else None
    )
    return {"status": "success", "id": item.id}

@app.post("/load-csv-to-rag")
async def load_csv_to_rag():
    file_path = os.path.join(BASE_DIR, "data", "processed", "places.csv")
    if not os.path.exists(file_path):
        return {"error": "CSV dosyası bulunamadı. Önce scraper ve cleaner çalışmalı."}
    
    df = pd.read_csv(file_path)
    
    # Aynı Place ID'ye sahip satırların kategorilerini birleştiriyoruz (Veri kaybı sıfır!)
    df['Category'] = df.groupby('Place ID')['Category'].transform(lambda x: ", ".join(x.dropna().unique()))
    
    # Şimdi güvenle tekilleştirebiliriz
    df = df.drop_duplicates(subset=["Place ID"])
    
    documents = []
    ids = []
    metadatas = []
    
    for _, row in df.iterrows():
        content = f"Mekan: {row['Place Name']}, Kategori: {row['Category']}, Adres: {row['Address']}, Puan: {row['Average Rating']}"
        documents.append(content)
        ids.append(str(row['Place ID']))
        metadatas.append({"city": str(row['City']), "category": str(row['Category'])})
    
    collection.add(
        documents=documents,
        ids=ids,
        metadatas=metadatas
    )
    
    return {"status": f"{len(df)} mekan kategorileri birleştirilerek RAG sistemine yüklendi!"}


import requests
import xml.etree.ElementTree as ET

import requests
import xml.etree.ElementTree as ET

@app.get("/get-fx-rates")
async def get_fx_rates():
    tcmb_url = "https://www.tcmb.gov.tr/kurlar/today.xml"
    try:
        response = requests.get(tcmb_url, timeout=10)
        if response.status_code != 200:
            return {"error": "TCMB sunucusuna ulaşılamadı."}
        
        # XML verisini parse etme
        root = ET.fromstring(response.content)
        rates = {}
        
        for currency in root.findall('Currency'):
            code = currency.get('CurrencyCode')
            if code in ['USD', 'EUR', 'GBP']:  # Projede en çok işimize yarayacak ana kurlar
                forex_buying = currency.find('ForexBuying')
                forex_selling = currency.find('ForexSelling')
                
                rates[code] = {
                    "buying": forex_buying.text if forex_buying is not None else None,
                    "selling": forex_selling.text if forex_selling is not None else None
                }
                
        return {
            "status": "success",
            "source": "TCMB",
            "rates": rates
        }
    except Exception as e:
        return {"error": f"Kur çekilirken hata oluştu: {str(e)}"}
    
    @app.get("/predict-density/{place_id}")
    async def predict_density(place_id: str, day: str, hour: int):

    # İleride Üye 1'in ML modeli buraya entegre edilecek:
    # prediction = ml_model.predict(place_id, day, hour)
    
    # Şimdilik örnek/simüle edilmiş bir tahmin döndürüyoruz

        return {
            "status": "success",
            "place_id": place_id,
            "day": day,
            "hour": hour,
            "predicted_busyness": 65,  # Örnek yoğunluk yüzdesi (%)
            "note": "ML model entegrasyonu için hazırlanan iskelet endpoint"
        }


class RouteRequest(BaseModel):
    place_ids: List[str]

@app.post("/optimize-route")
async def optimize_route(data: RouteRequest):
    # İleride Üye 1'in TSP algoritması buraya bağlanacak:
    # optimized_order = tsp_algorithm(data.place_ids)
    
    # Şimdilik gelen listeyi olduğu gibi (veya ters çevirerek) simüle ediyoruz
    ordered_places = data.place_ids[::-1] # Örnek sıralama
    
    return {
        "status": "success",
        "optimized_route": ordered_places,
        "total_estimated_time_mins": len(data.place_ids) * 25,
        "note": "TSP rota optimizasyon modülü için hazırlanan iskelet endpoint"
    }