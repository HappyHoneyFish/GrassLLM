// 文件路径: lib/core/theme.dart

import 'package:flutter/material.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppConstants.primaryColor,
      scaffoldBackgroundColor: AppConstants.backgroundColor,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        primary: AppConstants.primaryColor,
        surface: AppConstants.backgroundColor,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppConstants.textMainColor),
        titleTextStyle: TextStyle(
          color: AppConstants.textMainColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        centerTitle: true,
      ),

      cardTheme: CardThemeData(
        color: AppConstants.cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          side: BorderSide(color: Colors.grey.withOpacity(0.15), width: 1),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppConstants.cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.defaultBorderRadius * 1.5),
          ),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: CircleBorder(),
      ),

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