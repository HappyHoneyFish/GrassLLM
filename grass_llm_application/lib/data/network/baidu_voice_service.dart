// 文件路径: lib/data/network/baidu_voice_service.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';

/// 百度短语音识别服务类 ，JSON上报
class BaiduVoiceService {
  static String? _cachedToken;
  static final Dio _dio = Dio();


  static Future<String?> _getAccessToken() async {
    if (_cachedToken != null) return _cachedToken;

    try {
      final response = await _dio.post(
        AppConstants.baiduTokenUrl,
        queryParameters: {
          'grant_type': 'client_credentials',
          'client_id': AppConstants.baiduApiKey,
          'client_secret': AppConstants.baiduSecretKey,
        },
      );

      if (response.statusCode == 200 && response.data['access_token'] != null) {
        _cachedToken = response.data['access_token'];
        return _cachedToken;
      }
    } catch (e) {
      debugPrint("获取百度语音 Token 失败: $e");
    }
    return null;
  }


  //传音频并获取识别文本
  /// [filePath] 录音文件的本地路径
  /// [format] 音频格式，Flutter 移动端使用 record 插件默认产出 m4a(aac)
  static Future<String?> recognizeSpeech(String filePath, {String format = 'm4a'}) async {

    final token = await _getAccessToken();
    if (token == null) {
      debugPrint("语音识别中断：Token 获取失败");
      return null;
    }

    //读取文件并转换为 Base64
    final file = File(filePath);
    if (!await file.exists()) {
      debugPrint("语音识别中断：录音文件不存在");
      return null;
    }

    // 百度 API 要求的 len 是原始音频流的大小(字节数)，而非 Base64 后的长度
    final int fileLen = await file.length();
    final String? base64Speech = await AppUtils.encodeFileToBase64(filePath);

    if (base64Speech == null) return null;

    try {
      final response = await _dio.post(
        AppConstants.baiduVoiceApiUrl,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
        data: {
          "format": format,
          "rate": 16000,
          "dev_pid": AppConstants.baiduDevPid,
          "channel": 1,
          "token": token,
          "cuid": "grassland_ai_mobile_client",
          "len": fileLen,
          "speech": base64Speech,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['err_no'] == 0 && data['result'] != null) {
          List results = data['result'];
          if (results.isNotEmpty) {
            return results.first.toString();
          }
        } else {
          debugPrint("百度语音识别业务错误: [${data['err_no']}] ${data['err_msg']}");
        }
      }
    } on DioException catch (e) {
      debugPrint("百度语音识别网络异常: ${e.message}");
    } catch (e) {
      debugPrint("百度语音识别未知错误: $e");
    }

    return null;
  }
}