# 文件路径: app/main.py

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api.endpoints import router as api_router

# 1. 初始化 FastAPI 实例
app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="草业智能体大模型后端服务"
)

# 2. 配置跨域资源共享 (CORS)
# 允许来自任何源的请求（在真机调试时非常重要）
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 3. 挂载 API 路由
app.include_router(api_router, prefix=settings.API_PREFIX)

@app.get("/")
async def root():
    return {
        "message": "Welcome to Grassland AI Agent API!",
        "status": "Running",
        "model": settings.LLM_MODEL_ID
    }

if __name__ == "__main__":
    import uvicorn
    # 启动服务，默认监听 0.0.0.0 的 8000 端口
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=False)