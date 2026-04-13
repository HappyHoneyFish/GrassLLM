# 文件路径: download_model.py

import os
from modelscope.hub.snapshot_download import snapshot_download

# 引入我们的全局配置，确保模型下载到我们预设的路径中
from app.core.config import settings


def main():
    print(f"==================================================")
    print(f" 开始下载司农大模型: {settings.LLM_MODEL_ID}")
    print(f" 目标保存路径: {settings.LLM_LOCAL_DIR}")
    print(f"==================================================")

    try:
        # 使用 modelscope 自动下载模型并保存到指定本地目录
        # 如果网络中断，再次运行此脚本会自动断点续传
        model_dir = snapshot_download(
            settings.LLM_MODEL_ID,
            local_dir=settings.LLM_LOCAL_DIR,
            revision='master'  # 默认拉取主分支
        )
        print(f"\n✅ 模型下载成功！全部文件已保存在: {model_dir}")
        print(f"现在您可以开始构建向量知识库或启动 FastAPI 服务了。")
    except Exception as e:
        print(f"\n❌ 模型下载失败: {str(e)}")
        print("请检查网络连接，或稍后重试。")


if __name__ == "__main__":
    # 确保保存模型的父文件夹存在
    os.makedirs(settings.MODEL_DIR, exist_ok=True)
    main()