import 'package:flutter/material.dart';

import '../constant/str_constant.dart';
import '../constant/ui_constant.dart';

/// 通用状态视图
///
/// 功能说明: 统一加载中、空数据与错误三种页面状态，避免各页面重复实现
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class StateView extends StatelessWidget
{
  /// 展示类型
  final _StateType type;

  /// 提示文案
  final String message;

  /// 重试回调，为空时不展示按钮
  final VoidCallback? onRetry;

  /// 是否为深色背景场景
  final bool onDark;

  /// 加载中
  ///
  /// [onDark] 是否用于深色背景
  const StateView.loading({bool onDark = false})
      : type = _StateType.loading,
        message = StringConstants.TIP_LOADING,
        onRetry = null,
        onDark = onDark;

  /// 空数据
  ///
  /// [message] 空态文案
  /// [onRetry] 可选的重试回调
  /// [onDark] 是否用于深色背景
  const StateView.empty(this.message, {this.onRetry, this.onDark = false}) : type = _StateType.empty;

  /// 错误
  ///
  /// [message] 错误文案
  /// [onRetry] 重试回调
  /// [onDark] 是否用于深色背景
  const StateView.error(this.message, {this.onRetry, this.onDark = false}) : type = _StateType.error;

  @override
  Widget build(BuildContext context)
  {
    final textColor = onDark ? UIConstants.COLOR_TEXT_ON_DARK_SUB : UIConstants.COLOR_TEXT_ON_LIGHT_SUB;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.PADDING_XL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>
          [
            if (type == _StateType.loading)
              const SizedBox(
                width: UIConstants.ICON_LG,
                height: UIConstants.ICON_LG,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            if (type == _StateType.empty)
              Icon(
                Icons.inbox_outlined,
                size: UIConstants.ICON_XL,
                color: textColor,
              ),
            if (type == _StateType.error)
              Icon(
                Icons.cloud_off_outlined,
                size: UIConstants.ICON_XL,
                color: textColor,
              ),
            const SizedBox(height: UIConstants.PADDING_MD),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: UIConstants.FONT_SM, color: textColor),
            ),
            if (onRetry != null)
              Padding(
                padding: const EdgeInsets.only(top: UIConstants.PADDING_MD),
                child: TextButton(
                  onPressed: onRetry,
                  child: const Text(StringConstants.BTN_RETRY),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 状态类型
enum _StateType
{
  loading,
  empty,
  error,
}
