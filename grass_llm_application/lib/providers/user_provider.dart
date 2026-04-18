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

  Future<void> loadProfile() async {
    _profile = await LocalStorage.getUserProfile();
    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> updateProfile(UserProfile newProfile) async {

    final success = await LocalStorage.saveUserProfile(newProfile);

    if (success) {
      _profile = newProfile;
      notifyListeners();
    }
    return success;
  }

  Future<void> clearProfile() async {
    await LocalStorage.clearUserProfile();
    _profile = null;
    notifyListeners();
  }
}