/// 脉搏分析结果
///
/// 功能说明: 承载一次频谱分析输出的生理指标，供测量结果页消费
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class PpgAnalysis
{
  /// 心率，单位 bpm
  final double heartRate;

  /// SDNN，单位毫秒
  final double sdnn;

  /// RMSSD，单位毫秒
  final double rmssd;

  /// 信号质量分，0-1
  final double quality;

  /// 构造函数
  const PpgAnalysis({
    required this.heartRate,
    required this.sdnn,
    required this.rmssd,
    required this.quality,
  });

  /// 信号是否可信
  bool get isReliable => quality >= 0.35;
}
