/// 指标字典模型
///
/// 功能说明: 承接后端 vital_metric 下发的指标配置，驱动首页与结果页的渲染
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class VitalMetric
{
  /// 指标编码
  final String metricCode;

  /// 指标名称
  final String label;

  /// 单位
  final String unit;

  /// 取值类型：single 单值 / dual 双值 / percent 百分比
  final String valueType;

  /// 小数位数
  final int precision;

  /// 显示顺序
  final int dispOrder;

  /// 渲染形态：card 单值卡 / dual 双值卡 / bar 进度卡
  final String disptype;

  /// 图标标识
  final String icon;

  /// 参考下限
  final double? defaultMin;

  /// 参考上限
  final double? defaultMax;

  /// 是否为估算值
  final bool isEstimated;

  /// 是否启用
  final bool enabled;

  /// 构造函数
  const VitalMetric({
    required this.metricCode,
    required this.label,
    required this.unit,
    this.valueType = 'single',
    this.precision = 0,
    this.dispOrder = 0,
    this.disptype = 'card',
    this.icon = '',
    this.defaultMin,
    this.defaultMax,
    this.isEstimated = false,
    this.enabled = true,
  });

  /// 从 JSON 构建
  ///
  /// [json] 服务端返回的指标字典对象
  factory VitalMetric.fromJson(Map<String, dynamic> json)
  {
    return VitalMetric(
      metricCode: json['metricCode']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      valueType: json['valueType']?.toString() ?? 'single',
      precision: _asInt(json['precision']),
      dispOrder: _asInt(json['dispOrder']),
      disptype: json['disptype']?.toString() ?? 'card',
      icon: json['icon']?.toString() ?? '',
      defaultMin: _asDouble(json['defaultMin']),
      defaultMax: _asDouble(json['defaultMax']),
      isEstimated: _asBool(json['isEstimated']),
      enabled: _asBool(json['enabled'], fallback: true),
    );
  }

  /// 是否为双值指标
  bool get isDual => valueType == 'dual';

  /// 转换为 JSON
  Map<String, dynamic> toJson()
  {
    return <String, dynamic>
    {
      'metricCode': metricCode,
      'label': label,
      'unit': unit,
      'valueType': valueType,
      'precision': precision,
      'dispOrder': dispOrder,
      'disptype': disptype,
      'icon': icon,
      'defaultMin': defaultMin,
      'defaultMax': defaultMax,
      'isEstimated': isEstimated,
      'enabled': enabled,
    };
  }

  /// 安全转换整数
  ///
  /// [value] 原始值
  static int _asInt(dynamic value)
  {
    if (value is int)
    {
      return value;
    }
    if (value is num)
    {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  /// 安全转换浮点数
  ///
  /// [value] 原始值
  static double? _asDouble(dynamic value)
  {
    if (value == null)
    {
      return null;
    }
    if (value is num)
    {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }

  /// 安全转换布尔值
  ///
  /// [value] 原始值
  /// [fallback] 解析失败时的默认值
  static bool _asBool(dynamic value, {bool fallback = false})
  {
    if (value is bool)
    {
      return value;
    }
    final text = value?.toString() ?? '';
    if (text == '1' || text == 'true' || text == 'Y')
    {
      return true;
    }
    if (text == '0' || text == 'false' || text == 'N')
    {
      return false;
    }
    return fallback;
  }
}
