/// 预警阈值规则模型
///
/// 功能说明: 承接后端 vital_alert_rule 数据，用于阈值配置页读写
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class AlertRule
{
  /// 规则主键
  final String ruleId;

  /// 指标编码
  final String metric;

  /// 指标名称
  final String label;

  /// 下限
  final double? minValue;

  /// 上限
  final double? maxValue;

  /// 是否启用
  final bool enabled;

  /// 构造函数
  const AlertRule({
    required this.ruleId,
    required this.metric,
    required this.label,
    this.minValue,
    this.maxValue,
    this.enabled = true,
  });

  /// 从 JSON 构建
  ///
  /// [json] 服务端返回的规则对象
  factory AlertRule.fromJson(Map<String, dynamic> json)
  {
    return AlertRule(
      ruleId: json['ruleId']?.toString() ?? '',
      metric: json['metric']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      minValue: json['minValue'] == null ? null : _asDouble(json['minValue']),
      maxValue: json['maxValue'] == null ? null : _asDouble(json['maxValue']),
      enabled: json['enabled'] == true || json['enabled']?.toString() == '1',
    );
  }

  /// 转换为提交 JSON
  Map<String, dynamic> toJson()
  {
    return <String, dynamic>
    {
      'ruleId': ruleId,
      'metric': metric,
      'minValue': minValue,
      'maxValue': maxValue,
      'enabled': enabled ? '1' : '0',
    };
  }

  /// 复制并覆盖部分字段
  ///
  /// [minValue] 新下限
  /// [maxValue] 新上限
  /// [enabled] 新启用状态
  AlertRule copyWith({double? minValue, double? maxValue, bool? enabled})
  {
    return AlertRule(
      ruleId: ruleId,
      metric: metric,
      label: label,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      enabled: enabled ?? this.enabled,
    );
  }

  /// 区间展示文本
  String get rangeText
  {
    final left = minValue?.toStringAsFixed(0) ?? '--';
    final right = maxValue?.toStringAsFixed(0) ?? '--';
    return '$left - $right';
  }

  /// 安全转换浮点数
  ///
  /// [value] 原始值
  static double _asDouble(dynamic value)
  {
    if (value is num)
    {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
