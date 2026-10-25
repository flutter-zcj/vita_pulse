import '../../constant/str_constant.dart';
import 'vital_record.dart';

/// 测量会话结果模型
///
/// 功能说明: 承载一次摄像头测量的全部产出，在检测页与结果页之间传递
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class MeasureResult
{
  /// 心率，单位 bpm
  final double heartRate;

  /// HRV 的 SDNN，单位毫秒
  final double sdnn;

  /// HRV 的 RMSSD，单位毫秒
  final double rmssd;

  /// 舒适度评分，0-100
  final int comfort;

  /// 压力等级索引，0 很低至 4 很高
  final int stressIndex;

  /// 信号质量分，0-1
  final double quality;

  /// 测量时间
  final DateTime measuredAt;

  /// 测量会话编号
  final String sessionId;

  /// 构造函数
  const MeasureResult({
    required this.heartRate,
    required this.sdnn,
    required this.rmssd,
    required this.comfort,
    required this.stressIndex,
    required this.quality,
    required this.measuredAt,
    required this.sessionId,
  });

  /// 是否信号质量不足
  bool get isWeak => quality < 0.35;

  /// 压力等级文案
  String get stressLabel
  {
    switch (stressIndex)
    {
      case 0:
        return StringConstants.STRESS_VERY_LOW;
      case 1:
        return StringConstants.STRESS_LOW;
      case 2:
        return StringConstants.STRESS_MIDDLE;
      case 3:
        return StringConstants.STRESS_HIGH;
      default:
        return StringConstants.STRESS_VERY_HIGH;
    }
  }

  /// 转换为待提交的记录集合
  ///
  /// 一次会话写入多条记录，共享同一 sessionId 便于回溯
  List<VitalRecord> toRecords()
  {
    return <VitalRecord>
    [
      _build(StringConstants.METRIC_HEART_RATE, heartRate, 'bpm', 0),
      _build(StringConstants.METRIC_HRV_SDNN, sdnn, 'ms', 0),
      _build(StringConstants.METRIC_HRV_RMSSD, rmssd, 'ms', 0),
      _build(StringConstants.METRIC_COMFORT, comfort.toDouble(), '', 0),
      _build(StringConstants.METRIC_STRESS, stressIndex.toDouble(), '', 0),
    ];
  }

  /// 构建单条记录
  ///
  /// [metric] 指标编码
  /// [value] 数值
  /// [unit] 单位
  /// [precision] 小数位数，仅用于展示，不影响存储
  VitalRecord _build(String metric, double value, String unit, int precision)
  {
    return VitalRecord(
      recordId: '$sessionId-$metric',
      metric: metric,
      value: value,
      unit: unit,
      measuredAt: measuredAt,
      source: 'camera',
      quality: quality,
      sessionId: sessionId,
      isEstimated: metric == StringConstants.METRIC_RESP_RATE,
    );
  }
}
