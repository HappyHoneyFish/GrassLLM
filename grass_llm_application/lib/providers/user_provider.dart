// 文件路径: lib/providers/user_provider.dart

import 'package:flutter/material.dart';
import '../data/models.dart';
import '../data/local_storage.dart';

/// 全局用户档案状态管理
class UserProvider with ChangeNotifier {
  UserProfile? _profile;
  bool _isInitialized = false;

  UserProfile? get profile => _profile;
  /// 是否已经完成本地读取初始化
  bool get isInitialized => _isInitialized;

  // ==========================================
  // 1. App 启动时加载本地档案
  // ==========================================
  Future<void> loadProfile() async {
    // 读取本地 SharedPreferences 中的 JSON 数据
    _profile = await LocalStorage.getUserProfile();
    _isInitialized = true;
    notifyListeners(); // 通知所有监听的 UI 组件刷新
  }

  // ==========================================
  // 2. 更新或新建用户档案
  // ==========================================
  Future<bool> updateProfile(UserProfile newProfile) async {
    // 1. 持久化保存到本地
    final success = await LocalStorage.saveUserProfile(newProfile);

    // 2. 如果保存成功，更新内存状态并刷新 UI
    if (success) {
      _profile = newProfile;
      notifyListeners();
    }
    return success;
  }

  // ==========================================
  // 3. 清除档案 (预留给调试或重置功能)
  // ==========================================
  Future<void> clearProfile() async {
    await LocalStorage.clearUserProfile();
    _profile = null;
    notifyListeners();
  }
}