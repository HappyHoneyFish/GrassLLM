# 文件路径: build_knowledge_db.py

import os
import glob
from tqdm import tqdm

# 解析 PDF 和 Word
import pdfplumber
import docx

# LangChain 组件
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import Chroma
from langchain_community.embeddings import HuggingFaceEmbeddings

# 引入全局配置
from app.core.config import settings


def extract_text_from_pdf(file_path):
    text = ""
    try:
        with pdfplumber.open(file_path) as pdf:
            for page in pdf.pages:
                page_text = page.extract_text()
                if page_text:
                    text += page_text + "\n"
    except Exception as e:
        print(f"读取 PDF 失败 {file_path}: {e}")
    return text


def extract_text_from_docx(file_path):
    text = ""
    try:
        doc = docx.Document(file_path)
        for para in doc.paragraphs:
            text += para.text + "\n"
    except Exception as e:
        print(f"读取 Word 失败 {file_path}: {e}")
    return text


def main():
    print("==================================================")
    print(" 开始构建草业 RAG 本地知识库...")
    print(f" 读取目录: {settings.DOCS_DIR}")
    print("==================================================")

    # 1. 获取所有的文档文件
    pdf_files = glob.glob(os.path.join(settings.DOCS_DIR, "*.pdf"))
    docx_files = glob.glob(os.path.join(settings.DOCS_DIR, "*.docx"))
    all_files = pdf_files + docx_files

    if not all_files:
        print("❌ 警告：在 docs/ 目录下没有找到任何 PDF 或 Word 文档！")
        print("请先把您的专业草业资料放进去，再运行此脚本。")
        return

    # 2. 提取文本
    print(f"找到 {len(all_files)} 个文档，开始提取文本...")
    raw_text = ""
    for file in tqdm(all_files, desc="解析文档"):
        if file.endswith('.pdf'):
            raw_text += extract_text_from_pdf(file)
        elif file.endswith('.docx'):
            raw_text += extract_text_from_docx(file)

    if not raw_text.strip():
        print("❌ 提取文本为空，请检查文档内容是否全是无法解析的图片。")
        return

    # 3. 文本切分 (Chunking)
    print(f"\n文本总长度: {len(raw_text)} 字符，开始进行语义切分...")
    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=settings.CHUNK_SIZE,
        chunk_overlap=settings.CHUNK_OVERLAP,
        separators=["\n\n", "\n", "。", "！", "？", "，", " ", ""]
    )
    texts = text_splitter.split_text(raw_text)
    print(f"✅ 共切分为 {len(texts)} 个文本块。")

    # 4. 加载 Embedding 模型并存入 Chroma 向量数据库
    print(f"\n正在加载 Embedding 模型 ({settings.EMBEDDING_MODEL_ID})... 初次下载可能需要一两分钟。")
    embeddings = HuggingFaceEmbeddings(
        model_name=settings.EMBEDDING_MODEL_ID,
        model_kwargs={'device': 'cuda'},  # 使用您的 RTX 4090 极速编码
        encode_kwargs={'normalize_embeddings': True}
    )

    print("正在生成向量并写入 Chroma 数据库...")
    # 持久化存储到本地目录
    vector_store = Chroma.from_texts(
        texts=texts,
        embedding=embeddings,
        persist_directory=settings.VECTOR_STORE_DIR
    )
    vector_store.persist()

    print(f"\n🎉 知识库构建成功！向量数据已保存在: {settings.VECTOR_STORE_DIR}")


if __name__ == "__main__":
    main()