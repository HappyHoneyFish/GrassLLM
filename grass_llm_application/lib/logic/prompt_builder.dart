// 文件路径: lib/logic/prompt_builder.dart

import '../data/models.dart';
import 'grass_calculator.dart';

/// 大模型 Prompt 组装车间
class PromptBuilder {

  /// 构建给后端的超级富文本 Prompt
  static String buildExpertPrompt({
    required UserProfile profile,
    required String weatherInfo,
    required String userQuestion,
  }) {
    // 1. 基础档案解析
    final String location = profile.location ?? "未知地区";
    final String grassType = profile.grassType ?? "未知草种";
    final String area = profile.area != null ? "${profile.area}亩" : "未知面积";
    final int days = profile.plantedDays;

    // 2. 调用轻量级公式，推演动态生长阶段
    final String currentStage = GrassCalculator.getCurrentStage(profile);

    // 3. 开始组装超级 Prompt
    final StringBuffer promptBuffer = StringBuffer();

    // a. 强制角色设定与输出规范约束
    promptBuffer.writeln("你是一个专业的草业智能体助手，请基于以下用户的真实种植情况，直接回答他的问题。");
    promptBuffer.writeln("回答要求：专业、简明扼要、具有实操性，不要说废话，不要输出 Markdown 格式的加粗符号。");
    promptBuffer.writeln("---");

    // b. 注入本地状态与环境上下文
    if (profile.hasPlanted) {
      promptBuffer.writeln("【用户当前的真实种植档案】");
      promptBuffer.writeln("- 地点：$location");
      promptBuffer.writeln("- 种植品种：$grassType");
      promptBuffer.writeln("- 种植面积：$area");
      promptBuffer.writeln("- 已经生长天数：$days 天");
      promptBuffer.writeln("- 当前推断所处阶段：$currentStage");
    } else {
      promptBuffer.writeln("【用户当前的真实种植档案】");
      promptBuffer.writeln("用户当前尚未开始种草，正在进行前期的选种或规划咨询。");
      if (profile.location != null) promptBuffer.writeln("- 所在地：$location");
      if (profile.area != null) promptBuffer.writeln("- 意向面积：$area");
    }

    // c. 注入动态天气信息（如果获取成功）
    if (weatherInfo.isNotEmpty) {
      promptBuffer.writeln("- 实时气象环境：$weatherInfo");
    }

    promptBuffer.writeln("---");

    // d. 注入用户当前的核心提问
    promptBuffer.writeln("【用户问题】");
    promptBuffer.writeln(userQuestion);

    return promptBuffer.toString();
  }
}