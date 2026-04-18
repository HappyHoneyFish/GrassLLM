# 文件路径: download_model.py

import os
from modelscope.hub.snapshot_download import snapshot_download

from app.core.config import settings


def main():
    print(f" 开始下载司农大模型: {settings.LLM_MODEL_ID}")
    print(f" 目标保存路径: {settings.LLM_LOCAL_DIR}")

    try:
        model_dir = snapshot_download(
            settings.LLM_MODEL_ID,
            local_dir=settings.LLM_LOCAL_DIR,
            revision='master'
        )
        print(f"\n模型下载成功！全部文件已保存在: {model_dir}")
    except Exception as e:
        print(f"\n模型下载失败: {str(e)}")


if __name__ == "__main__":
    os.makedirs(settings.MODEL_DIR, exist_ok=True)
    main()