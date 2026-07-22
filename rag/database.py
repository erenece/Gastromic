import chromadb
import os

# Verilerin kaydedileceği klasör
db_path = os.path.join(os.getcwd(), "chroma_db")
client = chromadb.PersistentClient(path=db_path)

# Veriyi saklayacağımız koleksiyon
collection = client.get_or_create_collection(name="gastro_collection")