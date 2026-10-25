import 'package:flutter/material.dart';

import '../constant/str_constant.dart';
import '../constant/ui_constant.dart';
import '../core/utils/date_util.dart';
import '../core/utils/format_util.dart';
import '../data/models/vital_metric.dart';
import '../data/models/vital_record.dart';

/// 指标卡片
///
/// 功能说明: 展示单个指标的当前值、来源角标与参考区间，供首页复用
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class MetricCard extends StatelessWidget
{
  /// 指标配置
  final VitalMetric metric;

  /// 最新记录，为空表示无数据
  final VitalRecord? record;

  /// 点击回调
  final VoidCallback? onTap;

  /// 是否使用深色配色
  final bool onDark;

  /// 构造函数
  const MetricCard({
    super.key,
    required this.metric,
    this.record,
    this.onTap,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context)
  {
    final titleColor = onDark ? UIConstants.COLOR_TEXT_ON_DARK : UIConstants.COLOR_TEXT_ON_LIGHT;
    final subColor = onDark ? UIConstants.COLOR_TEXT_ON_DARK_SUB : UIConstants.COLOR_TEXT_ON_LIGHT_SUB;
    final accent = onDark ? UIConstants.COLOR_ACCENT : UIConstants.COLOR_ACCENT_LIGHT;
    final surface = onDark ? UIConstants.COLOR_SURFACE_DARK : UIConstants.COLOR_RESULT_BG;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(UIConstants.RADIUS_MD),
      child: Container(
        padding: const EdgeInsets.all(UIConstants.PADDING_DEFAULT),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(UIConstants.RADIUS_MD),
          border: Border.all(
            color: onDark ? UIConstants.COLOR_ACCENT_DIM.withOpacity(UIConstants.OPACITY_SUB) : UIConstants.COLOR_DIVIDER,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>
          [
            Row(
              children: <Widget>
              [
                Expanded(
                  child: Text(
                    metric.label,
                    style: TextStyle(fontSize: UIConstants.FONT_SM, color: subColor),
                  ),
                ),
                _buildBadge(),
              ],
            ),
            const SizedBox(height: UIConstants.PADDING_SM),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>
              [
                Text(
                  FormatUtil.formatValue(record?.value, metric.precision),
                  style: TextStyle(
                    fontSize: UIConstants.FONT_XL,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
                const SizedBox(width: UIConstants.PADDING_XS),
                Text(
                  metric.unit,
                  style: TextStyle(fontSize: UIConstants.FONT_XS, color: subColor),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.PADDING_XS),
            Text(
              _rangeText(),
              style: TextStyle(fontSize: UIConstants.FONT_XS, color: subColor),
            ),
            if (_needStaleHint())
              Padding(
                padding: const EdgeInsets.only(top: UIConstants.PADDING_XS),
                child: Text(
                  StringConstants.HOME_NOT_MEASURED_LONG,
                  style: TextStyle(fontSize: UIConstants.FONT_XS, color: accent),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建来源角标
  Widget _buildBadge()
  {
    final text = _badgeText();
    if (text.isEmpty)
    {
      return const SizedBox.shrink();
    }
    final accent = onDark ? UIConstants.COLOR_ACCENT : UIConstants.COLOR_ACCENT_LIGHT;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.PADDING_SM,
        vertical: UIConstants.PADDING_XS / 2,
      ),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(UIConstants.RADIUS_SM),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: UIConstants.FONT_XS - 2, color: accent),
      ),
    );
  }

  /// 角标文案
  String _badgeText()
  {
    if (metric.isEstimated)
    {
      return StringConstants.RESULT_SOURCE_ESTIMATE;
    }
    final source = record?.source ?? '';
    if (source == 'camera')
    {
      return StringConstants.RESULT_SOURCE_CAMERA;
    }
    if (source == 'manual')
    {
      return StringConstants.RESULT_SOURCE_MANUAL;
    }
    return '';
  }

  /// 参考区间文本
  String _rangeText()
  {
    final minValue = metric.defaultMin;
    final maxValue = metric.defaultMax;
    if (minValue == null || maxValue == null)
    {
      return '';
    }
    return '${StringConstants.HOME_REFERENCE_RANGE} ${FormatUtil.formatRange(minValue, maxValue, metric.unit)}';
  }

  /// 是否需要提示较久未测
  bool _needStaleHint()
  {
    final time = record?.measuredAt;
    if (time == null)
    {
      return false;
    }
    if (record?.source != 'manual')
    {
      return false;
    }
    return DateUtil.isStale(time, 1);
  }
}
