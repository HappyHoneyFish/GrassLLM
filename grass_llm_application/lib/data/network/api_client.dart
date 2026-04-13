// 文件路径: lib/data/network/api_client.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';

/// 大模型后端接口客户端
class ApiClient {
  // 配置 Dio 实例，大模型推理时间较长，必须设置较长的接收超时时间
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15), // 连接超时：15秒
      receiveTimeout: const Duration(seconds: 60), // 接收超时：60秒
    ),
  );

  // ==========================================
  // 1. 请求草业大模型推理接口
  // ==========================================
  /// [prompt] 前端组装好的富文本 Prompt (包含本地状态、天气、用户问题)
  /// [imagePath] 用户拍摄的照片本地路径 (可选)
  static Future<String?> askAgent(String prompt, {String? imagePath}) async {
    try {
      // 1. 构建 multipart/form-data 表单数据
      final Map<String, dynamic> dataMap = {
        "prompt": prompt,
      };

      // 2. 如果存在图片，将其转换为流文件加入表单
      if (imagePath != null && imagePath.isNotEmpty) {
        final file = File(imagePath);
        if (await file.exists()) {
          dataMap["image"] = await MultipartFile.fromFile(
            imagePath,
            filename: imagePath.split('/').last, // 提取文件名
          );
        }
      }

      final formData = FormData.fromMap(dataMap);

      // 3. 发送 POST 请求到后端的 /ask 接口
      final response = await _dio.post(
        AppConstants.askApiUrl,
        data: formData,
      );

      // 4. 解析后端返回结果
      if (response.statusCode == 200) {
        final responseData = response.data;
        // 对应您设计的 FastAPI 返回格式: {"status": "success", "answer": "..."}
        if (responseData['status'] == 'success') {
          return responseData['answer'];
        } else {
          debugPrint("大模型业务逻辑报错: ${responseData['message']}");
        }
      } else {
        debugPrint("后端服务异常，状态码: ${response.statusCode}");
      }
    } on DioException catch (e) {
      debugPrint("请求大模型网络异常: ${e.message}");
      if (e.type == DioExceptionType.connectionTimeout) {
        debugPrint("【网络排查提示】: 连接超时。请检查手机是否与 Linux 服务器在同一局域网(或公网可达)，且 AppConstants 中的 IP 地址配置正确。");
      }
    } catch (e) {
      debugPrint("请求大模型未知错误: $e");
    }

    return null; // 请求失败返回 null
  }
}