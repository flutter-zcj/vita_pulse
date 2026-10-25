import 'dart:async';
import 'dart:math' as math;

import 'device_adapter.dart';

/// 模拟采集适配器
///
/// 功能说明: 无摄像头或桌面调试时，生成带基线漂移与噪声的脉搏波，保证链路可跑通
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class MockAdapter implements DeviceAdapter
{
  /// 定时器
  Timer? _timer;

  /// 采样计数
  int _index = 0;

  /// 随机源
  final math.Random _random = math.Random(7);

  /// 模拟心率，单位 bpm
  final double _heartRate;

  /// 设备名称
  @override
  String get name => 'mock';

  /// 模拟设备始终可用
  @override
  bool get isSupported => true;

  /// 构造函数
  ///
  /// [heartRate] 模拟心率，默认 72 bpm
  MockAdapter({double heartRate = 72}) : _heartRate = heartRate;

  /// 启动模拟采样
  ///
  /// [onSample] 每帧回调
  @override
  Future<void> start(DeviceAdapter.SampleCallback onSample) async
  {
    await stop();
    _index = 0;
    _timer = Timer.periodic(
      const Duration(milliseconds: 33),
      (timer)
      {
        final timeSec = _index / 30.0;
        final frequency = _heartRate / 60.0;
        final pulse = math.sin(2 * math.pi * frequency * timeSec);
        final drift = 0.6 * math.sin(2 * math.pi * 0.12 * timeSec);
        final noise = (_random.nextDouble() - 0.5) * 0.08;
        final value = 128 + 12 * pulse + 6 * drift + 20 * noise;
        onSample(value, timeSec);
        _index++;
      },
    );
  }

  /// 停止模拟采样
  @override
  Future<void> stop() async
  {
    _timer?.cancel();
    _timer = null;
  }
}
