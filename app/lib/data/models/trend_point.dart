/// 趋势数据点模型
///
/// 功能说明: 承接后端统计接口返回的聚合点，用于趋势折线绘制
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class TrendPoint
{
  /// 聚合时间点
  final DateTime time;

  /// 聚合平均值
  final double value;

  /// 区间最小值
  final double? minValue;

  /// 区间最大值
  final double? maxValue;

  /// 构造函数
  const TrendPoint({
    required this.time,
    required this.value,
    this.minValue,
    this.maxValue,
  });

  /// 从 JSON 构建
  ///
  /// [json] 服务端返回的聚合点对象
  factory TrendPoint.fromJson(Map<String, dynamic> json)
  {
    return TrendPoint(
      time: _asDateTime(json['time']),
      value: _asDouble(json['value']),
      minValue: json['minValue'] == null ? null : _asDouble(json['minValue']),
      maxValue: json['maxValue'] == null ? null : _asDouble(json['maxValue']),
    );
  }

  /// 安全转换时间
  ///
  /// [value] 原始值
  static DateTime _asDateTime(dynamic value)
  {
    final text = value?.toString() ?? '';
    return DateTime.tryParse(text)?.toLocal() ?? DateTime.now();
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
