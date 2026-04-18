// 文件路径: lib/data/local_storage.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

/// 本地存储服务类 (封装 SharedPreferences)
class LocalStorage {
  static const String _userProfileKey = 'grassland_user_profile';

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
    return null;
  }

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