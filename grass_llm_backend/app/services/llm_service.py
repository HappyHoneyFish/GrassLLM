# 文件路径: app/services/llm_service.py

import torch
from transformers import AutoModelForCausalLM, AutoTokenizer
from app.core.config import settings


class LLMService:
    def __init__(self):
        self.model = None
        self.tokenizer = None
        self._load_model()

    def _load_model(self):
        print("==================================================")
        print(f" 正在将司农大模型载入 RTX 4090 显存...")
        print(f" 模型路径: {settings.LLM_LOCAL_DIR}")
        print("==================================================")

        try:
            # 加载 Tokenizer
            self.tokenizer = AutoTokenizer.from_pretrained(
                settings.LLM_LOCAL_DIR,
                trust_remote_code=True
            )

            # 加载模型主体 (采用 FP16 半精度，大幅节省显存并提速)
            self.model = AutoModelForCausalLM.from_pretrained(
                settings.LLM_LOCAL_DIR,
                device_map=settings.DEVICE_MAP,
                torch_dtype=settings.TORCH_DTYPE,
                trust_remote_code=True
            ).eval()  # 设置为推理模式

            print("✅ 司农大模型加载成功！算力已就绪。")
        except Exception as e:
            print(f"❌ 模型加载失败！请确认是否已运行 download_model.py 下载了模型。")
            print(f"详细错误: {e}")

    def generate_response(self, prompt: str) -> str:
        """
        接收组装好的 Prompt，交由大模型进行推理并返回答案
        """
        if not self.model or not self.tokenizer:
            return "【系统提示】对不起，服务器底座模型尚未成功加载，请联系管理员。"

        try:
            # 1. 对文本进行 Token 化，并转移到 GPU 上
            inputs = self.tokenizer(prompt, return_tensors='pt').to(self.model.device)

            # 2. 开启推理 (关闭梯度计算以节省显存)
            with torch.no_grad():
                outputs = self.model.generate(
                    **inputs,
                    max_new_tokens=settings.MAX_NEW_TOKENS,
                    temperature=settings.TEMPERATURE,
                    do_sample=True,  # 允许一定的随机性
                    top_p=0.8,  # 核采样，保证回答的连贯性
                    pad_token_id=self.tokenizer.eos_token_id  # 避免某些底座模型报 pad_token 警告
                )

            # 3. 截断上下文，只保留模型最新生成的部分
            input_length = inputs.input_ids.shape[1]
            generated_tokens = outputs[0][input_length:]
            answer = self.tokenizer.decode(generated_tokens, skip_special_tokens=True)

            return answer.strip()

        except Exception as e:
            print(f"模型推理时发生异常: {e}")
            return "抱歉，模型推演过程中出现了异常，请稍后再试。"


# 采用单例模式：启动时加载一次，后续请求复用
llm_service = LLMService()