import 'package:flutter/material.dart';

/// UI 布局与色值常量
///
/// 功能说明: 统一管理间距、圆角、字号与主题色，确保视觉一致性
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class UIConstants
{
  // ---- 色值 ----
  static const Color COLOR_BG_DEEP = Color(0xFF0B3133);
  static const Color COLOR_SURFACE_DARK = Color(0xFF103C3E);
  static const Color COLOR_ACCENT = Color(0xFF2ED3BE);
  static const Color COLOR_ACCENT_DIM = Color(0xFF1B7F78);
  static const Color COLOR_ACCENT_LIGHT = Color(0xFF17A99A);
  static const Color COLOR_TEXT_ON_DARK = Color(0xFFE8F6F4);
  static const Color COLOR_TEXT_ON_DARK_SUB = Color(0xFF7EA9A4);
  static const Color COLOR_RESULT_BG = Color(0xFFFFFFFF);
  static const Color COLOR_TEXT_ON_LIGHT = Color(0xFF123639);
  static const Color COLOR_TEXT_ON_LIGHT_SUB = Color(0xFF6B8C8C);
  static const Color COLOR_DANGER = Color(0xFFE05C5C);
  static const Color COLOR_WARNING = Color(0xFFE0A33E);
  static const Color COLOR_LOW = Color(0xFF4A90D9);
  static const Color COLOR_DIVIDER = Color(0xFFE3EDEC);

  // ---- 间距 ----
  static const double PADDING_XS = 4.0;
  static const double PADDING_SM = 8.0;
  static const double PADDING_MD = 12.0;
  static const double PADDING_DEFAULT = 16.0;
  static const double PADDING_LG = 20.0;
  static const double PADDING_XL = 24.0;
  static const double PADDING_XXL = 32.0;

  // ---- 圆角 ----
  static const double RADIUS_SM = 4.0;
  static const double RADIUS_DEFAULT = 8.0;
  static const double RADIUS_MD = 12.0;
  static const double RADIUS_LG = 16.0;
  static const double RADIUS_ROUND = 999.0;

  // ---- 字号 ----
  static const double FONT_XS = 12.0;
  static const double FONT_SM = 14.0;
  static const double FONT_DEFAULT = 16.0;
  static const double FONT_MD = 18.0;
  static const double FONT_LG = 24.0;
  static const double FONT_XL = 32.0;
  static const double FONT_XXL = 48.0;
  static const double FONT_DISPLAY = 64.0;

  // ---- 组件尺寸 ----
  static const double BUTTON_HEIGHT = 48.0;
  static const double ICON_SM = 16.0;
  static const double ICON_DEFAULT = 24.0;
  static const double ICON_LG = 32.0;
  static const double ICON_XL = 48.0;
  static const double CIRCLE_SIZE = 220.0;
  static const double WAVE_HEIGHT = 120.0;
  static const double CHART_HEIGHT = 240.0;
  static const double CARD_ELEVATION = 0.0;
  static const double DIVIDER_HEIGHT = 0.5;
  static const double OPACITY_DISABLED = 0.4;
  static const double OPACITY_SUB = 0.7;
  static const double PROGRESS_STROKE = 8.0;
  static const double BOTTOM_BAR_HEIGHT = 64.0;
  static const double SHEET_MAX_RATIO = 0.5;

  // ---- 动画时长 ----
  static const Duration DURATION_FAST = Duration(milliseconds: 200);
  static const Duration DURATION_NORMAL = Duration(milliseconds: 300);
  static const Duration DURATION_SLOW = Duration(milliseconds: 500);
}
