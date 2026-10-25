import 'package:flutter/material.dart';

import '../constant/ui_constant.dart';

/// 应用主题
///
/// 功能说明: 提供浅色与深色两套主题，色值统一取自 UIConstants
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class AppTheme
{
  /// 浅色主题
  ///
  /// 返回结果为浅色模式下的 ThemeData，用于结果页、列表页等场景
  static ThemeData get light
  {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: UIConstants.COLOR_RESULT_BG,
      colorScheme: const ColorScheme.light(
        primary: UIConstants.COLOR_ACCENT_LIGHT,
        surface: UIConstants.COLOR_RESULT_BG,
        error: UIConstants.COLOR_DANGER,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: UIConstants.COLOR_RESULT_BG,
        foregroundColor: UIConstants.COLOR_TEXT_ON_LIGHT,
        elevation: UIConstants.CARD_ELEVATION,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: UIConstants.FONT_SM, color: UIConstants.COLOR_TEXT_ON_LIGHT),
        bodySmall: TextStyle(fontSize: UIConstants.FONT_XS, color: UIConstants.COLOR_TEXT_ON_LIGHT_SUB),
      ),
    );
  }

  /// 深色主题
  ///
  /// 返回结果为深色模式下的 ThemeData，用于测量流程页面
  static ThemeData get dark
  {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: UIConstants.COLOR_BG_DEEP,
      colorScheme: const ColorScheme.dark(
        primary: UIConstants.COLOR_ACCENT,
        surface: UIConstants.COLOR_SURFACE_DARK,
        error: UIConstants.COLOR_DANGER,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: UIConstants.COLOR_BG_DEEP,
        foregroundColor: UIConstants.COLOR_TEXT_ON_DARK,
        elevation: UIConstants.CARD_ELEVATION,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: UIConstants.FONT_SM, color: UIConstants.COLOR_TEXT_ON_DARK),
        bodySmall: TextStyle(fontSize: UIConstants.FONT_XS, color: UIConstants.COLOR_TEXT_ON_DARK_SUB),
      ),
    );
  }
}
