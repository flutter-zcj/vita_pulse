import 'package:flutter/material.dart';

import '../constant/ui_constant.dart';

/// 主操作按钮
///
/// 功能说明: 统一主按钮样式与禁用/加载态，避免各页面重复定义
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class PrimaryButton extends StatelessWidget
{
  /// 按钮文案
  final String text;

  /// 点击回调，为空表示禁用
  final VoidCallback? onPressed;

  /// 是否展示加载中
  final bool loading;

  /// 是否使用描边样式
  final bool outlined;

  /// 是否使用深色场景配色
  final bool onDark;

  /// 构造函数
  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.loading = false,
    this.outlined = false,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context)
  {
    final accent = onDark ? UIConstants.COLOR_ACCENT : UIConstants.COLOR_ACCENT_LIGHT;
    final foreground = onDark ? UIConstants.COLOR_BG_DEEP : UIConstants.COLOR_RESULT_BG;
    final enabled = onPressed != null && !loading;
    final child = loading
        ? SizedBox(
            width: UIConstants.ICON_DEFAULT,
            height: UIConstants.ICON_DEFAULT,
            child: CircularProgressIndicator(strokeWidth: 2, color: accent),
          )
        : Text(
            text,
            style: TextStyle(
              fontSize: UIConstants.FONT_DEFAULT,
              fontWeight: FontWeight.w600,
              color: outlined ? accent : foreground,
            ),
          );

    if (outlined)
    {
      return SizedBox(
        height: UIConstants.BUTTON_HEIGHT,
        width: double.infinity,
        child: OutlinedButton(
          onPressed: enabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: enabled ? accent : accent.withOpacity(UIConstants.OPACITY_DISABLED)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UIConstants.RADIUS_ROUND),
            ),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      height: UIConstants.BUTTON_HEIGHT,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          disabledBackgroundColor: accent.withOpacity(UIConstants.OPACITY_DISABLED),
          elevation: UIConstants.CARD_ELEVATION,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.RADIUS_DEFAULT),
          ),
        ),
        child: child,
      ),
    );
  }
}
