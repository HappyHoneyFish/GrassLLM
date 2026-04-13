// 文件路径: lib/core/constants.dart

import 'package:flutter/material.dart';

/// 全局配置与常量定义
class AppConstants {
  // ==========================================
  // 1. 网络请求与后端服务配置
  // ==========================================
  // 请在真机调试前，将此处的 IP 替换为您部署大模型的 Linux 服务器的真实局域网/公网 IP
  static const String backendBaseUrl = "http://140.210.92.250:17193";
  static const String askApiUrl = "$backendBaseUrl/api/ask";

  // ==========================================
  // 2. 第三方 API 配置 (百度短语音 API)
  // ==========================================
  // 请替换为您在百度智能云控制台申请的真实 API Key 和 Secret Key
  static const String baiduApiKey = "IiMN1SBwanN0yQpINOr6kSJM";
  static const String baiduSecretKey = "UQHHbXl2H4Ca0TZvzfKK024GFa4FaltP";

  // 百度鉴权与短语音识别接口地址
  static const String baiduTokenUrl = "https://aip.baidubce.com/oauth/2.0/token";
  static const String baiduVoiceApiUrl = "http://vop.baidu.com/server_api";

  // 百度语音识别普通话模型 PID (1537 为纯中文语音近场识别模型)
  static const int baiduDevPid = 1537;

  // ==========================================
  // 3. UI 视觉与主题配置 (极简清爽风)
  // ==========================================
  static const Color primaryColor = Color(0xFF2E7D32); // 主色调：生机绿
  static const Color primaryLightColor = Color(0xFFE8F5E9); // 浅绿背景/高亮
  static const Color backgroundColor = Color(0xFFF8F9FA); // 极简灰白背景
  static const Color cardColor = Colors.white; // 卡片纯白

  static const Color textMainColor = Color(0xFF212121); // 主标题文本色
  static const Color textSecondaryColor = Color(0xFF757575); // 次要描述文本色
  static const Color textHintColor = Color(0xFFBDBDBD); // 提示文本色

  // 全局通用尺寸与圆角
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 16.0; // 偏圆润的卡片设计
}