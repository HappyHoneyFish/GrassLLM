// 文件路径: lib/core/theme.dart

import 'package:flutter/material.dart';
import 'constants.dart';

/// 全局 UI 主题配置 (极简清爽风)
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true, // 启用 Material 3 设计规范
      primaryColor: AppConstants.primaryColor,
      scaffoldBackgroundColor: AppConstants.backgroundColor,

      // 颜色种子配置
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        primary: AppConstants.primaryColor,
        surface: AppConstants.backgroundColor,
      ),

      // ==========================================
      // 1. 顶部导航栏主题：极简纯白，无阴影
      // ==========================================
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.backgroundColor, // 与页面背景同色，视觉更开阔
        elevation: 0,
        scrolledUnderElevation: 0, // 滑动时不产生阴影叠加
        iconTheme: IconThemeData(color: AppConstants.textMainColor),
        titleTextStyle: TextStyle(
          color: AppConstants.textMainColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        centerTitle: true,
      ),

      // ==========================================
      // 2. 卡片主题：纯白大圆角，极弱边框代替阴影
      // ==========================================
      cardTheme: CardThemeData(
        color: AppConstants.cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          side: BorderSide(color: Colors.grey.withOpacity(0.15), width: 1),
        ),
      ),

      // ==========================================
      // 3. 底部弹窗主题：大圆角，用于即用即走问答
      // ==========================================
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppConstants.cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.defaultBorderRadius * 1.5),
          ),
        ),
      ),

      // ==========================================
      // 4. 悬浮按钮主题
      // ==========================================
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: CircleBorder(), // 确保是正圆形
      ),

      // ==========================================
      // 5. 全局排版文本主题
      // ==========================================
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: AppConstants.textMainColor, fontSize: 22, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: AppConstants.textMainColor, fontSize: 18, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: AppConstants.textMainColor, fontSize: 16),
        bodyMedium: TextStyle(color: AppConstants.textSecondaryColor, fontSize: 14),
        labelSmall: TextStyle(color: AppConstants.textHintColor, fontSize: 12),
      ),
    );
  }
}