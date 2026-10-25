import 'device_adapter.dart';

/// 蓝牙设备适配器（预留）
///
/// 功能说明: 为后续接入心率带、血氧仪等标准 GATT 设备预留统一入口，当前版本不启用
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class BleAdapter implements DeviceAdapter
{
  /// 设备名称
  @override
  String get name => 'ble';

  /// 当前版本不支持蓝牙采集
  @override
  bool get isSupported => false;

  /// 启动采集
  ///
  /// [onSample] 每帧回调
  /// 当前版本直接抛出未支持异常
  @override
  Future<void> start(DeviceAdapter.SampleCallback onSample) async
  {
    throw UnsupportedError('BLE adapter is reserved for v1.1');
  }

  /// 停止采集
  @override
  Future<void> stop() async
  {
    return;
  }
}
