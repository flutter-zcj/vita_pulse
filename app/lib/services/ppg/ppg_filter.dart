import 'dart:math' as math;

/// 脉搏波数字滤波器
///
/// 功能说明: 提供去趋势与带通滤波，抑制呼吸漂移与高频噪声
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class PpgFilter
{
  /// 滑动均值去趋势
  ///
  /// [input] 原始信号
  /// [windowSize] 滑动窗口长度，单位为采样点
  /// 返回去除基线后的新序列
  static List<double> detrend(List<double> input, int windowSize)
  {
    if (input.isEmpty || windowSize <= 1)
    {
      return List<double>.from(input);
    }
    final result = List<double>.filled(input.length, 0);
    final half = windowSize ~/ 2;
    for (var index = 0; index < input.length; index++)
    {
      final start = math.max(0, index - half);
      final end = math.min(input.length - 1, index + half);
      var sum = 0.0;
      for (var cursor = start; cursor <= end; cursor++)
      {
        sum = sum + input[cursor];
      }
      final average = sum / (end - start + 1);
      result[index] = input[index] - average;
    }
    return result;
  }

  /// 带通滤波
  ///
  /// [input] 输入信号
  /// [sampleRate] 采样率，单位 Hz
  /// [lowHz] 通带下限
  /// [highHz] 通带上限
  /// 返回滤波后的新序列
  static List<double> bandPass(List<double> input, double sampleRate, double lowHz, double highHz)
  {
    if (input.isEmpty)
    {
      return <double>[];
    }
    final highPassed = _applyBiquad(input, sampleRate, lowHz, isHighPass: true);
    return _applyBiquad(highPassed, sampleRate, highHz, isHighPass: false);
  }

  /// 应用二阶 IIR 滤波
  ///
  /// [input] 输入信号
  /// [sampleRate] 采样率
  /// [cutoffHz] 截止频率
  /// [isHighPass] true 为高通，false 为低通
  static List<double> _applyBiquad(
    List<double> input,
    double sampleRate,
    double cutoffHz, {
    required bool isHighPass,
  })
  {
    final omega = 2 * math.pi * cutoffHz / sampleRate;
    final cosOmega = math.cos(omega);
    final sinOmega = math.sin(omega);
    final quality = math.sqrt(2) / 2;
    final alpha = sinOmega / (2 * quality);

    double b0;
    double b1;
    double b2;
    double a0;
    double a1;
    double a2;
    if (isHighPass)
    {
      b0 = (1 + cosOmega) / 2;
      b1 = -(1 + cosOmega);
      b2 = (1 + cosOmega) / 2;
    }
    else
    {
      b0 = (1 - cosOmega) / 2;
      b1 = 1 - cosOmega;
      b2 = (1 - cosOmega) / 2;
    }
    a0 = 1 + alpha;
    a1 = -2 * cosOmega;
    a2 = 1 - alpha;

    final result = List<double>.filled(input.length, 0);
    var x1 = 0.0;
    var x2 = 0.0;
    var y1 = 0.0;
    var y2 = 0.0;
    for (var index = 0; index < input.length; index++)
    {
      final x0 = input[index];
      final y0 = (b0 / a0) * x0 + (b1 / a0) * x1 + (b2 / a0) * x2 - (a1 / a0) * y1 - (a2 / a0) * y2;
      result[index] = y0;
      x2 = x1;
      x1 = x0;
      y2 = y1;
      y1 = y0;
    }
    return result;
  }
}
