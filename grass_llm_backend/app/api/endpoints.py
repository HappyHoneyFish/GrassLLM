# 文件路径: app/api/endpoints.py

import os
import shutil
from fastapi import APIRouter, Form, UploadFile, File
from typing import Optional

from app.core.config import settings
from app.services.rag_service import rag_service
from app.services.llm_service import llm_service

router = APIRouter()


@router.post("/ask")
async def ask_agent(
        prompt: str = Form(...),
        image: Optional[UploadFile] = File(None)
):
    try:
        # ==========================================
        # 1. 处理前端传来的图片 (为多模态底座预留扩展空间)
        # ==========================================
        image_path = None
        if image and image.filename:
            image_path = os.path.join(settings.UPLOAD_DIR, image.filename)
            # 保存图片到服务器本地
            with open(image_path, "wb") as buffer:
                shutil.copyfileobj(image.file, buffer)
            print(f"📸 收到前端图片并保存至: {image_path}")

        # ==========================================
        # 2. 提取核心问题，触发 RAG 检索
        # ==========================================
        # 前端 PromptBuilder 将用户问题放在了 "【用户问题】" 之后
        core_question = prompt
        if "【用户问题】" in prompt:
            core_question = prompt.split("【用户问题】")[-1].strip()

        print(f"🔍 正在为问题检索知识库: {core_question[:30]}...")
        rag_context = rag_service.retrieve_context(core_question)

        # ==========================================
        # 3. 组装终极 Prompt
        # ==========================================
        final_prompt = prompt
        if rag_context:
            final_prompt = f"【系统检出的权威草业文献作为参考】\n{rag_context}\n\n{prompt}"

        # 针对当前纯文本模型的柔性处理
        if image_path:
            final_prompt += "\n[注：用户上传了一张现场照片，当前版本请基于用户的文字描述进行专业推演解答。]"

        # ==========================================
        # 4. 召唤大模型进行推理
        # ==========================================
        print("🧠 司农大模型开始推理...")
        answer = llm_service.generate_response(final_prompt)
        print("✅ 推理完成。")

        # ==========================================
        # 5. 返回结果 (严格适配 Flutter 端 ApiClient 的解析逻辑)
        # ==========================================
        return {
            "status": "success",
            "answer": answer
        }

    except Exception as e:
        print(f"❌ 接口处理异常: {e}")
        return {
            "status": "error",
            "message": str(e),
            "answer": "抱歉，服务器在处理您的请求时遇到了异常，请稍后再试。"
        }