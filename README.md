<details open>
<summary><b>🇬🇧 English (Click to toggle / 点击切换)</b></summary>

# 🌾 GrassLLM

**Grassland LLM: Sinong-8B + Flutter RAG agent for voice & photo-based pasture management.**

### 📖 Overview
GrassLLM is an intelligent pasture manager tailored for herdsmen and agricultural practitioners. Developed for the 2026 (19th) Chinese Collegiate Computing Competition (4C), it breaks away from traditional chatbot interfaces by using a dynamic timeline to proactively push full-lifecycle suggestions from planting to harvesting.

### ✨ Key Features
* **Zero-Threshold Experience**: No login required; user planting profiles are securely stored locally in JSON format for an instant cold start.
* **Dynamic Timeline**: A waterfall-style dynamic timeline tracks the pasture's life cycle, combining built-in agricultural formulas and real-time weather data to highlight current growth stages and push proactive advice.
* **Multi-Modal Interaction**: Optimized for outdoor scenarios with floating "Voice" and "Photo" inputs. It utilizes the Baidu Short Speech API to maintain high accuracy even in noisy, weak-network environments.
* **Hallucination-Free Math**: Employs a local lightweight deduction engine (`GrassCalculator`) to handle strict mathematical calculations like estimating dry grass yield and livestock carrying capacity, bypassing LLM math hallucinations.

### 🏗️ Architecture
The system adopts a "Fat Frontend, Thin Backend" architecture:
* **Fat Frontend (Flutter)**: Handles local state management, fetches weather data, runs formula calculations, and assembles multi-source data into a highly structured "Super Prompt".
* **Thin Backend (FastAPI)**: Operates purely as an inference engine, executing Retrieval-Augmented Generation (RAG) against a ChromaDB vector database and generating natural language via the Sinong1.0-8B model.

### 💻 Tech Stack
* **Frontend**: Flutter, SharedPreferences (Local JSON).
* **Backend**: Python, FastAPI.
* **AI & RAG**: Sinong1.0-8B (LLM Base), LangChain, ChromaDB (Vector Search), BGE-m3.
* **APIs**: Baidu ASR API, Open-Meteo API.

---
</details>

<details>
<summary><b>🇨🇳 中文 (Click to toggle / 点击切换)</b></summary>

# 🌾 GrassLLM (智牧草业大模型)

**草业大模型——垂直领域RAG智能体，司农8B+Flutter，牧民种草全周期的语音+拍照手机助手。4C参赛作品。**

### 📖 项目简介
GrassLLM 是一款专为牧民打造的草场智能管家。本项目为2026年（第19届）中国大学生计算机设计大赛人工智能实践赛参赛作品。它打破了传统通用大模型单一的对话框模式，以动态时间轴主动推送“从种到收”的全生命周期建议，让科学种草触手可及。

### ✨ 核心功能
* **零门槛的“即用即走”体验**：摒弃繁琐的注册登录流程，用户的种植档案以 JSON 格式存储于本地，充分保护隐私并实现极速冷启动。
* **全生命周期的动态时间轴管理**：以瀑布流形态的动态卡片为核心视觉，结合内置草业公式与实时气象数据，自动推演当前所处阶段并主动推送实操建议。
* **极简的多模态快捷交互**：针对户外劳作场景，首页面板仅悬浮“语音”与“拍照”两大入口，通过接入百度短语音识别API，在户外弱网环境下也能实现极速精准的短句识别。
* **告别大模型计算幻觉**：采用本地轻量推演引擎（`GrassCalculator`），在手机端实时计算预估干草产量与载畜量，弥补了大模型在数学精准计算上的短板。

### 🏗️ 系统架构
本系统采用“胖前端、瘦后端”的大模型落地架构：
* **胖前端 (Flutter)**：承担状态管理、天气拉取与本地公式计算，并能在毫秒级内自动组装包含档案、阶段、天气与问题的“超级富文本 Prompt”。
* **瘦后端 (FastAPI)**：作为纯粹的推理服务节点，执行基于 ChromaDB 的 RAG 专业知识检索，并将拼接好的数据交由司农大模型（Sinong1.0-8B）进行自然语言生成。

### 💻 技术栈
* **移动端**：Flutter, SharedPreferences。
* **服务端**：Python, FastAPI。
* **AI 与大模型**：司农1.0-8B 农业大模型, LangChain, ChromaDB 向量数据库, BGE-m3。
* **外部服务**：百度短语音识别标准版 API, Open-Meteo 气象接口。

</details>