// 文件路径: lib/data/local_storage.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

/// 本地存储服务类 (封装 SharedPreferences)
class LocalStorage {
  // 存储用户档案的键名
  static const String _userProfileKey = 'grassland_user_profile';

  // ==========================================
  // 1. 保存用户档案到本地
  // ==========================================
  static Future<bool> saveUserProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = profile.toJson();
      return await prefs.setString(_userProfileKey, jsonString);
    } catch (e) {
      debugPrint("保存用户档案失败: $e");
      return false;
    }
  }

  // ==========================================
  // 2. 从本地读取用户档案
  // ==========================================
  static Future<UserProfile?> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_userProfileKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        return UserProfile.fromJson(jsonString);
      }
    } catch (e) {
      debugPrint("读取用户档案失败: $e");
    }
    return null; // 如果没有数据或解析失败，返回 null，代表用户首次打开 App
  }

  // ==========================================
  // 3. 清除用户档案 (预留给可能需要的"重置"功能)
  // ==========================================
  static Future<bool> clearUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_userProfileKey);
    } catch (e) {
      debugPrint("清除用户档案失败: $e");
      return false;
    }
  }
}