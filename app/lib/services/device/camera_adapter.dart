import 'package:camera/camera.dart';

import '../../constant/num_constant.dart';
import 'device_adapter.dart';

/// 摄像头采集适配器
///
/// 功能说明: 读取后置摄像头 YUV 帧，提取中心区域红色通道均值作为脉搏波原始信号
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class CameraAdapter implements DeviceAdapter
{
  /// 相机控制器
  CameraController? _controller;

  /// 采集起始时刻
  DateTime? _startTime;

  /// 是否正在推流
  bool _streaming = false;

  /// 像素采样步长，用于降低单帧计算量
  static const int _sampleStep = 8;

  /// 设备名称
  @override
  String get name => 'camera';

  /// 采集能力是否可用
  @override
  bool get isSupported => _controller?.value.isInitialized ?? false;

  /// 启动采集
  ///
  /// [onSample] 每帧回调，参数为红色通道均值与相对时间
  @override
  Future<void> start(DeviceAdapter.SampleCallback onSample) async
  {
    await stop();
    final cameras = await availableCameras();
    if (cameras.isEmpty)
    {
      throw CameraException('no_camera', '当前设备没有可用摄像头');
    }
    final target = cameras.firstWhere(
      (item) => item.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    final controller = CameraController(
      target,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await controller.initialize();
    await controller.setFlashMode(FlashMode.torch);
    _controller = controller;
    _startTime = DateTime.now();
    _streaming = true;

    await controller.startImageStream(
      (image)
      {
        if (!_streaming || _startTime == null)
        {
          return;
        }
        final meanRed = _meanRed(image);
        if (meanRed == null)
        {
          return;
        }
        final timeSec = DateTime.now().difference(_startTime!).inMilliseconds / 1000.0;
        onSample(meanRed, timeSec);
      },
    );
  }

  /// 停止采集并释放相机
  @override
  Future<void> stop() async
  {
    _streaming = false;
    final controller = _controller;
    _controller = null;
    if (controller == null)
    {
      return;
    }
    try
    {
      if (controller.value.isStreamingImages)
      {
        await controller.stopImageStream();
      }
    }
    catch (error)
    {
      // 推流可能已由系统回收，此处忽略异常
    }
    try
    {
      await controller.dispose();
    }
    catch (error)
    {
      // 相机释放失败不阻塞页面退出
    }
  }

  /// 计算画面中心区域红色通道均值
  ///
  /// [image] 相机帧
  /// 返回 null 表示该帧亮度异常，应丢弃
  double? _meanRed(CameraImage image)
  {
    if (image.planes.length < 3 || image.width <= 0 || image.height <= 0)
    {
      return null;
    }
    final yPlane = image.planes[0];
    final vPlane = image.planes[2];
    final width = image.width;
    final height = image.height;
    final halfWidth = width / 2;
    final halfHeight = height / 2;
    final spanX = (width * NumberConstants.ROI_SCALE) / 2;
    final spanY = (height * NumberConstants.ROI_SCALE) / 2;
    final left = (halfWidth - spanX).round();
    final right = (halfWidth + spanX).round();
    final top = (halfHeight - spanY).round();
    final bottom = (halfHeight + spanY).round();

    var sum = 0.0;
    var count = 0;
    for (var row = top; row < bottom; row = row + _sampleStep)
    {
      for (var column = left; column < right; column = column + _sampleStep)
      {
        final yIndex = row * yPlane.bytesPerRow + column * yPlane.bytesPerPixel!;
        final vIndex = (row ~/ 2) * vPlane.bytesPerRow + (column ~/ 2) * vPlane.bytesPerPixel!;
        if (yIndex < 0 || yIndex >= yPlane.bytes.length || vIndex < 0 || vIndex >= vPlane.bytes.length)
        {
          continue;
        }
        final luma = yPlane.bytes[yIndex].toDouble();
        final chromaV = vPlane.bytes[vIndex].toDouble();
        final red = luma + 1.402 * (chromaV - 128);
        sum = sum + red;
        count++;
      }
    }
    if (count == 0)
    {
      return null;
    }
    final mean = sum / count;
    if (mean < NumberConstants.MIN_BRIGHTNESS || mean > NumberConstants.MAX_BRIGHTNESS)
    {
      return null;
    }
    return mean;
  }
}
