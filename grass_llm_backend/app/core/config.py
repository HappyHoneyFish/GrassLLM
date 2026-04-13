# 文件路径: app/core/config.py

import os
import torch


class Settings:
    # ==========================================
    # 1. 基础项目信息
    # ==========================================
    PROJECT_NAME: str = "Grassland AI Agent API"
    VERSION: str = "1.0.0"
    API_PREFIX: str = "/api"

    # ==========================================
    # 2. 核心路径配置 (基于当前文件的绝对路径自动推导)
    # ==========================================
    # 获取项目根目录 (grassland_backend)
    BASE_DIR: str = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

    # 数据与文档目录
    DATA_DIR: str = os.path.join(BASE_DIR, "data")
    DOCS_DIR: str = os.path.join(BASE_DIR, "docs")

    # 模型、向量库、图片上传的具体子目录
    MODEL_DIR: str = os.path.join(BASE_DIR, "models")
    LLM_LOCAL_DIR: str = os.path.join(MODEL_DIR, "Sinong1.0-8B")
    VECTOR_STORE_DIR: str = os.path.join(DATA_DIR, "vector_store")
    UPLOAD_DIR: str = os.path.join(DATA_DIR, "uploads")

    # ==========================================
    # 3. 司农大模型 (LLM) 推理配置
    # ==========================================
    # 针对您的 RTX 4090 (24GB显存)，FP16精度完全够用且速度极快
    LLM_MODEL_ID: str = "NAULLM/Sinong1.0-8B"
    TORCH_DTYPE = torch.float16
    DEVICE_MAP: str = "auto"
    MAX_NEW_TOKENS: int = 512
    TEMPERATURE: float = 0.2  # 农业建议需要严谨，温度设低一点，避免模型"幻觉"胡编乱造

    # ==========================================
    # 4. RAG 知识库与 Embedding 模型配置
    # ==========================================
    # 采用轻量级中文 Embedding 模型，速度快且占用显存极小
    EMBEDDING_MODEL_ID: str = "shibing624/text2vec-base-chinese"

    # 文档切分策略
    CHUNK_SIZE: int = 500  # 每一段知识的长度 (字符)
    CHUNK_OVERLAP: int = 50  # 段落之间的重叠字数，防止上下文被生硬截断
    RETRIEVER_TOP_K: int = 3  # 每次前端发来问题，从知识库检索出最相关的 3 段文献给大模型参考


settings = Settings()


# ==========================================
# 自动化：确保所有必须的目录存在
# ==========================================
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


# 只要引入这个 config，就自动检查并创建文件夹
ensure_directories()