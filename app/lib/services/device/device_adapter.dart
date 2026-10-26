/// 采样回调
///
/// value 为红色通道均值，timeSec 为相对开始时刻的秒数
typedef SampleCallback = void Function(double value, double timeSec);

/// 采集设备抽象
///
/// 功能说明: 统一摄像头、Mock 与蓝牙三种数据源的接入方式，便于替换
/// 时间: 2026-10-25
/// 作者: zhengchaojun
abstract class DeviceAdapter
{
  /// 设备名称
  String get name;

  /// 当前环境是否支持
  bool get isSupported;

  /// 启动采集
  ///
  /// [onSample] 每帧回调
  Future<void> start(SampleCallback onSample);

  /// 停止采集并释放资源
  Future<void> stop();
}
