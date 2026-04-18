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
        print(f" 正在将大模型载入显存...")
        print(f" 模型路径: {settings.LLM_LOCAL_DIR}")

        try:
            self.tokenizer = AutoTokenizer.from_pretrained(
                settings.LLM_LOCAL_DIR,
                trust_remote_code=True
            )

            self.model = AutoModelForCausalLM.from_pretrained(
                settings.LLM_LOCAL_DIR,
                device_map=settings.DEVICE_MAP,
                torch_dtype=settings.TORCH_DTYPE,
                trust_remote_code=True
            ).eval()

            print("大模型加载成功！")
        except Exception as e:
            print(f"模型加载失败！请确认是否已运行 download_model.py 下载了模型。")
            print(f"详细错误: {e}")

    def generate_response(self, prompt: str) -> str:
        """
        接收组装好的 Prompt，交由大模型进行推理并返回答案
        """
        if not self.model or not self.tokenizer:
            return "对不起，服务器底座模型尚未成功加载，请联系管理员。"

        try:
            inputs = self.tokenizer(prompt, return_tensors='pt').to(self.model.device)

            with torch.no_grad():
                outputs = self.model.generate(
                    **inputs,
                    max_new_tokens=settings.MAX_NEW_TOKENS,
                    temperature=settings.TEMPERATURE,
                    do_sample=True,
                    top_p=0.8,
                    pad_token_id=self.tokenizer.eos_token_id
                )

            input_length = inputs.input_ids.shape[1]
            generated_tokens = outputs[0][input_length:]
            answer = self.tokenizer.decode(generated_tokens, skip_special_tokens=True)

            return answer.strip()

        except Exception as e:
            print(f"模型推理时发生异常: {e}")
            return "抱歉，模型推演过程中出现了异常，请稍后再试。"


llm_service = LLMService()