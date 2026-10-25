import 'dart:async';

import 'package:get/get.dart';

import '../../../constant/num_constant.dart';
import '../../../constant/route_constant.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/utils/format_util.dart';
import '../../../data/models/measure_result.dart';
import '../../../services/device/camera_adapter.dart';
import '../../../services/device/device_adapter.dart';
import '../../../services/device/mock_adapter.dart';
import '../../../services/ppg/ppg_analysis.dart';
import '../../../services/ppg/ppg_engine.dart';

/// 检测进行中控制器
///
/// 功能说明: 驱动采集、倒计时与实时波形，结束后产出一次测量会话结果
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class RunningController extends BaseController
{
  /// 剩余秒数
  final RxInt remainingSec = NumberConstants.MEASURE_DURATION_SEC.obs;

  /// 实时波形
  final RxList<double> waveform = <double>[].obs;

  /// 实时心率，为空表示尚未得出
  final RxnDouble liveHeartRate = RxnDouble();

  /// 信号较弱提示
  final RxBool weakSignal = false.obs;

  /// 未检测到手指提示
  final RxBool noFinger = false.obs;

  /// 分析引擎
  final PpgEngine _engine = PpgEngine();

  /// 当前采集适配器
  DeviceAdapter? _adapter;

  /// 倒计时定时器
  Timer? _timer;

  /// 分析定时器
  Timer? _analysisTimer;

  /// 采集开始时刻
  DateTime _startTime = DateTime.now();

  /// 最近一次有效采样时刻
  DateTime _lastSampleTime = DateTime.now();

  @override
  void onInit()
  {
    super.onInit();
    startMeasure();
  }

  /// 启动测量
  Future<void> startMeasure() async
  {
    _startTime = DateTime.now();
    _lastSampleTime = DateTime.now();
    _engine.reset();
    waveform.clear();
    remainingSec.value = NumberConstants.MEASURE_DURATION_SEC;
    await _startAdapter();
    _startTimers();
  }

  /// 启动采集适配器
  ///
  /// 摄像头不可用时自动降级为模拟数据，保证流程可演示
  Future<void> _startAdapter() async
  {
    final cameraAdapter = CameraAdapter();
    try
    {
      await cameraAdapter.start(_onSample);
      _adapter = cameraAdapter;
    }
    catch (error)
    {
      await cameraAdapter.stop();
      final mock = MockAdapter();
      await mock.start(_onSample);
      _adapter = mock;
    }
  }

  /// 采样回调
  ///
  /// [value] 红色通道均值
  /// [timeSec] 相对时间
  void _onSample(double value, double timeSec)
  {
    _lastSampleTime = DateTime.now();
    _engine.addSample(value, timeSec);
    waveform.assignAll(_engine.recentWaveform(NumberConstants.FRAME_RATE_TARGET * 3));
  }

  /// 启动计时器
  void _startTimers()
  {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(milliseconds: NumberConstants.MEASURE_TICK_MS),
      (timer)
      {
        if (remainingSec.value > 0)
        {
          remainingSec.value = remainingSec.value - 1;
        }
        if (remainingSec.value <= 0)
        {
          timer.cancel();
          finish();
        }
      },
    );

    _analysisTimer?.cancel();
    _analysisTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer)
      {
        _refreshAnalysis();
        _checkFingerState();
      },
    );
  }

  /// 刷新实时分析结果
  void _refreshAnalysis()
  {
    final analysis = _engine.analyze();
    if (analysis == null)
    {
      return;
    }
    if (_engine.duration < NumberConstants.MEASURE_MIN_VALID_SEC)
    {
      return;
    }
    liveHeartRate.value = analysis.heartRate;
    weakSignal.value = analysis.quality < NumberConstants.SQI_THRESHOLD;
  }

  /// 检查手指是否离开
  void _checkFingerState()
  {
    final gap = DateTime.now().difference(_lastSampleTime).inMilliseconds;
    noFinger.value = gap > NumberConstants.MEASURE_TICK_MS * 2;
  }

  /// 结束测量并跳转结果页
  void finish()
  {
    final analysis = _engine.analyze();
    _stopTimers();
    _stopAdapter();
    if (analysis == null || analysis.quality < NumberConstants.SQI_THRESHOLD)
    {
      weakSignal.value = true;
    }
    final result = _buildResult(analysis);
    Get.offNamed(RouteConstants.MEASURE_RESULT, arguments: <String, dynamic>{RouteConstants.ARG_MEASURE_RESULT: result});
  }

  /// 取消测量
  Future<void> cancel() async
  {
    _stopTimers();
    await _stopAdapter();
    Get.back();
  }

  /// 停止计时器
  void _stopTimers()
  {
    _timer?.cancel();
    _timer = null;
    _analysisTimer?.cancel();
    _analysisTimer = null;
  }

  /// 停止适配器
  Future<void> _stopAdapter() async
  {
    final adapter = _adapter;
    _adapter = null;
    if (adapter != null)
    {
      await adapter.stop();
    }
  }

  /// 构建测量结果
  ///
  /// [analysis] 分析结果，可能为空
  MeasureResult _buildResult(PpgAnalysis? analysis)
  {
    final heartRate = analysis?.heartRate ?? 0;
    final rmssd = analysis?.rmssd ?? 0;
    final sdnn = analysis?.sdnn ?? 0;
    final quality = analysis?.quality ?? 0;
    final comfort = FormatUtil.comfortScore(heartRate, NumberConstants.RESTING_HR_DEFAULT, rmssd);
    final stressIndex = FormatUtil.stressLevelIndex(rmssd);
    return MeasureResult(
      heartRate: heartRate,
      sdnn: sdnn,
      rmssd: rmssd,
      comfort: comfort,
      stressIndex: stressIndex,
      quality: quality,
      measuredAt: _startTime,
      sessionId: _startTime.millisecondsSinceEpoch.toString(),
    );
  }

  @override
  void onClose()
  {
    _stopTimers();
    _stopAdapter();
    super.onClose();
  }
}
