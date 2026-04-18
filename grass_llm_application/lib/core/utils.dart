// 文件路径: lib/core/utils.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'constants.dart';

/// 全局通用工具类
class AppUtils {

  // 硬件权限申请，麦克风与相机
  static Future<bool> requestMediaPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.camera,
    ].request();

    // 只要两个权限都被授予，就返回 true
    return statuses[Permission.microphone] == PermissionStatus.granted &&
        statuses[Permission.camera] == PermissionStatus.granted;
  }

  //文件转Base64编码，用于百度短语音API音频上传及大模型图片上传
  static Future<String?> encodeFileToBase64(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        return base64Encode(bytes);
      }
    } catch (e) {
      debugPrint("文件 Base64 编码失败: $e");
    }
    return null;
  }

  /// 格式化为标准日期 (如：2023-10-01)
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// 友好的相对时间计算 (如：2天前，刚刚)
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  static void showToast(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        backgroundColor: isError ? Colors.redAccent : AppConstants.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius / 2),
        ),
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        duration: const Duration(seconds: 2),
        elevation: 0,
      ),
    );
  }
}