# 文件路径: app/services/rag_service.py

import os
from langchain_community.vectorstores import Chroma
from langchain_community.embeddings import HuggingFaceEmbeddings
from app.core.config import settings


class RAGService:
    def __init__(self):
        print("正在初始化 RAG 检索服务与 Embedding 模型...")
        self.embeddings = HuggingFaceEmbeddings(
            model_name=settings.EMBEDDING_MODEL_ID,
            model_kwargs={'device': 'cuda'},
            encode_kwargs={'normalize_embeddings': True}
        )
        self.vector_store = None
        self._load_db()

    def _load_db(self):
        """尝试加载本地的 ChromaDB 向量数据库"""
        if os.path.exists(settings.VECTOR_STORE_DIR) and os.listdir(settings.VECTOR_STORE_DIR):
            try:
                self.vector_store = Chroma(
                    persist_directory=settings.VECTOR_STORE_DIR,
                    embedding_function=self.embeddings
                )
                print(f"RAG 本地知识库加载成功！")
            except Exception as e:
                print(f"RAG 知识库加载失败: {e}")
        else:
            print("⚠警告: 尚未找到 Chroma 向量数据库数据！")
            print("如果这是首次部署，请记得随后运行 python build_knowledge_db.py。")
            print("当前状态下，大模型将退化为仅依赖自身基础权重回答问题（不影响服务启动）。")

    def retrieve_context(self, query: str) -> str:
        """
        根据用户问题，检索最相关的文档切片
        """
        if not self.vector_store:
            return ""

        try:
            docs = self.vector_store.similarity_search(query, k=settings.RETRIEVER_TOP_K)

            if not docs:
                return ""

            context_pieces = []
            for i, doc in enumerate(docs):
                clean_content = doc.page_content.replace('\n', ' ').strip()
                context_pieces.append(f"【参考知识 {i + 1}】: {clean_content}")

            return "\n\n".join(context_pieces)

        except Exception as e:
            print(f"检索知识库时发生异常: {e}")
            return ""

rag_service = RAGService()