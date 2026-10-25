import '../../constant/num_constant.dart';

/// 数值格式化工具
///
/// 功能说明: 按指标精度格式化数值，统一空值占位与压力等级映射
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class FormatUtil
{
  /// 空值占位符
  static const String EMPTY_PLACEHOLDER = '--';

  /// 格式化数值
  ///
  /// [value] 原始数值，为空时返回占位符
  /// [precision] 保留小数位数
  static String formatValue(double? value, int precision)
  {
    if (value == null)
    {
      return EMPTY_PLACEHOLDER;
    }
    return value.toStringAsFixed(precision);
  }

  /// 格式化血压双值
  ///
  /// [systolic] 收缩压
  /// [diastolic] 舒张压
  static String formatBloodPressure(double? systolic, double? diastolic)
  {
    final left = formatValue(systolic, NumberConstants.PRECISION_ZERO);
    final right = formatValue(diastolic, NumberConstants.PRECISION_ZERO);
    if (left == EMPTY_PLACEHOLDER && right == EMPTY_PLACEHOLDER)
    {
      return EMPTY_PLACEHOLDER;
    }
    return '$left/$right';
  }

  /// 格式化区间文本
  ///
  /// [min] 下限
  /// [max] 上限
  /// [unit] 单位
  static String formatRange(double? min, double? max, String unit)
  {
    if (min == null || max == null)
    {
      return EMPTY_PLACEHOLDER;
    }
    return '${formatValue(min, NumberConstants.PRECISION_ZERO)} - '
        '${formatValue(max, NumberConstants.PRECISION_ZERO)} $unit';
  }

  /// 计算舒适度评分
  ///
  /// [heartRate] 心率
  /// [restingHeartRate] 个人静息心率
  /// [rmssd] 心率变异性
  /// 返回 0-100 的整数评分
  static int comfortScore(double heartRate, double restingHeartRate, double rmssd)
  {
    final hrDeviation = (heartRate - restingHeartRate).abs() * NumberConstants.COMFORT_HR_FACTOR;
    final rmssdPenalty =
        (NumberConstants.RESTING_RMSSD_BASE - rmssd).clamp(NumberConstants.ZERO, NumberConstants.HUNDRED) *
        NumberConstants.COMFORT_RMSSD_FACTOR;
    final score = NumberConstants.HUNDRED - (hrDeviation + rmssdPenalty) / NumberConstants.COMFORT_DIVISOR;
    return score.clamp(NumberConstants.COMFORT_MIN, NumberConstants.COMFORT_MAX).round();
  }

  /// 计算压力等级索引
  ///
  /// [rmssd] 心率变异性
  /// 返回 0 很低 / 1 较低 / 2 中等 / 3 较高 / 4 很高
  static int stressLevelIndex(double rmssd)
  {
    if (rmssd > NumberConstants.RMSSD_HIGH)
    {
      return 0;
    }
    if (rmssd > NumberConstants.RMSSD_MIDDLE)
    {
      return 1;
    }
    if (rmssd > NumberConstants.RMSSD_LOW)
    {
      return 2;
    }
    if (rmssd > NumberConstants.RMSSD_VERY_LOW)
    {
      return 3;
    }
    return 4;
  }
}
