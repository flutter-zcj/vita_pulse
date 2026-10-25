/// 体征记录模型
///
/// 功能说明: 承接后端 vital_record 数据，用于列表展示、趋势查询与新增提交
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class VitalRecord
{
  /// 记录主键，新增时由客户端生成
  final String recordId;

  /// 指标编码
  final String metric;

  /// 指标数值
  final double value;

  /// 单位
  final String unit;

  /// 测量时间
  final DateTime measuredAt;

  /// 数据来源：camera / manual / ble
  final String source;

  /// 信号质量分，手动录入为空
  final double? quality;

  /// 测量会话编号
  final String sessionId;

  /// 是否为估算值
  final bool isEstimated;

  /// 备注
  final String remark;

  /// 构造函数
  const VitalRecord({
    required this.recordId,
    required this.metric,
    required this.value,
    required this.unit,
    required this.measuredAt,
    this.source = 'manual',
    this.quality,
    this.sessionId = '',
    this.isEstimated = false,
    this.remark = '',
  });

  /// 从 JSON 构建
  ///
  /// [json] 服务端返回的记录对象
  factory VitalRecord.fromJson(Map<String, dynamic> json)
  {
    return VitalRecord(
      recordId: json['recordId']?.toString() ?? '',
      metric: json['metric']?.toString() ?? '',
      value: _asDouble(json['value']),
      unit: json['unit']?.toString() ?? '',
      measuredAt: _asDateTime(json['measuredAt']),
      source: json['source']?.toString() ?? 'manual',
      quality: json['quality'] == null ? null : _asDouble(json['quality']),
      sessionId: json['sessionId']?.toString() ?? '',
      isEstimated: json['isEstimated'] == true || json['isEstimated']?.toString() == '1',
      remark: json['remark']?.toString() ?? '',
    );
  }

  /// 转换为提交 JSON
  Map<String, dynamic> toJson()
  {
    return <String, dynamic>
    {
      'recordId': recordId,
      'metric': metric,
      'value': value,
      'unit': unit,
      'measuredAt': measuredAt.toUtc().toIso8601String(),
      'source': source,
      'quality': quality,
      'sessionId': sessionId,
      'isEstimated': isEstimated,
      'remark': remark,
    };
  }

  /// 复制并覆盖部分字段
  ///
  /// [metric] 新指标编码
  /// [value] 新数值
  VitalRecord copyWith({String? metric, double? value})
  {
    return VitalRecord(
      recordId: recordId,
      metric: metric ?? this.metric,
      value: value ?? this.value,
      unit: unit,
      measuredAt: measuredAt,
      source: source,
      quality: quality,
      sessionId: sessionId,
      isEstimated: isEstimated,
      remark: remark,
    );
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

  /// 安全转换时间
  ///
  /// [value] 原始值，支持 ISO 字符串与毫秒时间戳
  static DateTime _asDateTime(dynamic value)
  {
    if (value is DateTime)
    {
      return value;
    }
    if (value is int)
    {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    final text = value?.toString() ?? '';
    return DateTime.tryParse(text)?.toLocal() ?? DateTime.now();
  }
}
