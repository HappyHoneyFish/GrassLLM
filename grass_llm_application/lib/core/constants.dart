// 文件路径: lib/core/constants.dart

import 'package:flutter/material.dart';

/// 全局配置与常量定义
class AppConstants {

  // 后台
  static const String backendBaseUrl = "http://140.210.92.250:17193";
  static const String askApiUrl = "$backendBaseUrl/api/ask";

  // 百度APIKey
  static const String baiduApiKey = "IiMN1SBwanN0yQpINOr6kSJM";
  static const String baiduSecretKey = "UQHHbXl2H4Ca0TZvzfKK024GFa4FaltP";

  // 百度鉴权与短语音识别接口地址
  static const String baiduTokenUrl = "https://aip.baidubce.com/oauth/2.0/token";
  static const String baiduVoiceApiUrl = "http://vop.baidu.com/server_api";

  // 百度语音识别普通话模型 PID (1537 为纯中文语音近场识别模型)
  static const int baiduDevPid = 1537;

  //配色
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color primaryLightColor = Color(0xFFE8F5E9);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;

  static const Color textMainColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color textHintColor = Color(0xFFBDBDBD);

  // 全局通用尺寸与圆角
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 16.0;
}