"""ChromaDB kalıcı istemci — RAG vektör deposu."""
from __future__ import annotations

import chromadb

from .config import CHROMA_DB_DIR

CHROMA_DB_DIR.mkdir(parents=True, exist_ok=True)
client = chromadb.PersistentClient(path=str(CHROMA_DB_DIR))
collection = client.get_or_create_collection(name="gastro_collection")
