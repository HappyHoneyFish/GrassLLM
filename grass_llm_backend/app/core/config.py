# 文件路径: app/core/config.py

import os
import torch


class Settings:

    PROJECT_NAME: str = "Grassland AI Agent API"
    VERSION: str = "1.0.0"
    API_PREFIX: str = "/api"
    BASE_DIR: str = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    DATA_DIR: str = os.path.join(BASE_DIR, "data")
    DOCS_DIR: str = os.path.join(BASE_DIR, "docs")
    MODEL_DIR: str = os.path.join(BASE_DIR, "models")
    LLM_LOCAL_DIR: str = os.path.join(MODEL_DIR, "Sinong1.0-8B")
    VECTOR_STORE_DIR: str = os.path.join(DATA_DIR, "vector_store")
    UPLOAD_DIR: str = os.path.join(DATA_DIR, "uploads")
    LLM_MODEL_ID: str = "NAULLM/Sinong1.0-8B"
    TORCH_DTYPE = torch.float16
    DEVICE_MAP: str = "auto"
    MAX_NEW_TOKENS: int = 512
    TEMPERATURE: float = 0.2
    EMBEDDING_MODEL_ID: str = "shibing624/text2vec-base-chinese"
    CHUNK_SIZE: int = 500
    CHUNK_OVERLAP: int = 50
    RETRIEVER_TOP_K: int = 3

settings = Settings()

def ensure_directories():
    directories = [
        settings.DATA_DIR,
        settings.DOCS_DIR,
        settings.MODEL_DIR,
        settings.VECTOR_STORE_DIR,
        settings.UPLOAD_DIR
    ]
    for directory in directories:
        os.makedirs(directory, exist_ok=True)

ensure_directories()