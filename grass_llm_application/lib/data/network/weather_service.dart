// 文件路径: lib/data/network/weather_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// 简易天气服务 (基于免鉴权的 Open-Meteo 免费 API)
class WeatherService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  /// 根据经纬度获取当天的天气概况字符串，用于注入给大模型
  /// 如果没有开启定位或传入空，默认返回一个通用的空字符串，不影响主流程
  static Future<String> getTodayWeatherOverview({double? lat, double? lng}) async {
    // 如果没有经纬度（比如用户拒绝了定位或尚未实现定位功能），则直接返回空字符串
    if (lat == null || lng == null) {
      return "";
    }

    try {
      // 调用 Open-Meteo 免费气象接口 (获取当天的最高温、最低温和天气代码)
      final String url =
          "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng&daily=weathercode,temperature_2m_max,temperature_2m_min,precipitation_probability_max&timezone=auto&forecast_days=1";

      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        final daily = response.data['daily'];
        if (daily != null) {
          final maxTemp = daily['temperature_2m_max'][0];
          final minTemp = daily['temperature_2m_min'][0];
          final weatherCode = daily['weathercode'][0];
          final precipProb = daily['precipitation_probability_max'][0];

          final String condition = _decodeWeather(weatherCode);

          return "今日天气：$condition，气温 $minTemp°C ~ $maxTemp°C，降水概率 $precipProb%。";
        }
      }
    } catch (e) {
      debugPrint("获取天气数据失败: $e");
    }

    // 失败时优雅降级，不阻塞主流程
    return "";
  }

  /// WMO Weather interpretation codes (Open-Meteo 规范)
  static String _decodeWeather(int code) {
    if (code == 0) return "晴朗";
    if (code >= 1 && code <= 3) return "多云";
    if (code >= 45 && code <= 48) return "有雾";
    if (code >= 51 && code <= 67) return "有雨";
    if (code >= 71 && code <= 77) return "有雪";
    if (code >= 80 && code <= 82) return "阵雨";
    if (code >= 95 && code <= 99) return "雷暴";
    return "未知天气";
  }
}