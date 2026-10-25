import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:vita_pulse/services/ppg/ppg_engine.dart';

/// 脉搏引擎单元测试
///
/// 功能说明: 用合成正弦波验证心率估算精度，无需真机即可回归算法
/// 时间: 2026-10-25
/// 作者: zhengchaojun
void main()
{
  /// 采样率，与引擎保持一致
  const double sampleRate = 30.0;

  /// 生成合成脉搏波
  ///
  /// [heartRate] 目标心率
  /// [seconds] 信号时长
  List<double> buildSignal(double heartRate, int seconds)
  {
    final total = (sampleRate * seconds).round();
    final frequency = heartRate / 60.0;
    final values = <double>[];
    for (var index = 0; index < total; index++)
    {
      final time = index / sampleRate;
      final pulse = math.sin(2 * math.pi * frequency * time);
      final drift = 0.5 * math.sin(2 * math.pi * 0.15 * time);
      values.add(128 + 10 * pulse + 4 * drift);
    }
    return values;
  }

  test('合成 72bpm 信号，心率误差不超过 3bpm', ()
  {
    final engine = PpgEngine();
    final values = buildSignal(72, 30);
    for (var index = 0; index < values.length; index++)
    {
      engine.addSample(values[index], index / sampleRate);
    }
    final analysis = engine.analyze();
    expect(analysis, isNotNull);
    expect((analysis!.heartRate - 72).abs(), lessThan(3));
    expect(analysis.quality, greaterThan(0.2));
  });

  test('合成 96bpm 信号，心率误差不超过 3bpm', ()
  {
    final engine = PpgEngine();
    final values = buildSignal(96, 30);
    for (var index = 0; index < values.length; index++)
    {
      engine.addSample(values[index], index / sampleRate);
    }
    final analysis = engine.analyze();
    expect(analysis, isNotNull);
    expect((analysis!.heartRate - 96).abs(), lessThan(3));
  });

  test('数据不足时不返回结果', ()
  {
    final engine = PpgEngine();
    for (var index = 0; index < 30; index++)
    {
      engine.addSample(128, index / sampleRate);
    }
    expect(engine.analyze(), isNull);
  });
}
