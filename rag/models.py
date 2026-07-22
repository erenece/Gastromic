from pydantic import BaseModel
from typing import Dict, Any, Optional

class GastroData(BaseModel):
    id: str
    content: str
    metadata: Optional[Dict[str, Any]] = None