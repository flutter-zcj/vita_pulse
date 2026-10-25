import 'package:get/get.dart';

import '../../../constant/num_constant.dart';
import '../../../constant/route_constant.dart';
import '../../../constant/str_constant.dart';
import '../../../core/base/base_controller.dart';
import '../../../data/models/measure_result.dart';
import '../../../data/models/vital_record.dart';
import '../../../data/repositories/vital_repository.dart';

/// 检测结果页控制器
///
/// 功能说明: 展示本次测量结果、补充血氧参考值并负责保存
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class ResultController extends BaseController
{
  /// 体征仓储
  final VitalRepository _repository = Get.find<VitalRepository>();

  /// 本次测量结果
  late final MeasureResult result;

  /// 最近一次血氧记录
  final Rxn<VitalRecord> spo2Record = Rxn<VitalRecord>();

  /// 是否已保存成功
  final RxBool saved = false.obs;

  /// 保存中状态
  final RxBool saving = false.obs;

  @override
  void onInit()
  {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args[RouteConstants.ARG_MEASURE_RESULT] is MeasureResult)
    {
      result = args[RouteConstants.ARG_MEASURE_RESULT] as MeasureResult;
    }
    else
    {
      result = MeasureResult(
        heartRate: 0,
        sdnn: 0,
        rmssd: 0,
        comfort: 0,
        stressIndex: 2,
        quality: 0,
        measuredAt: DateTime.now(),
        sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
      );
    }
    loadSpo2();
  }

  /// 加载最近一次血氧记录
  ///
  /// 血氧不通过摄像头测算，取用户手动录入值
  Future<void> loadSpo2() async
  {
    try
    {
      final record = await _repository.loadLatestByMetric(StringConstants.METRIC_SPO2);
      spo2Record.value = record;
    }
    catch (error)
    {
      spo2Record.value = null;
    }
  }

  /// 保存本次测量
  Future<void> save() async
  {
    if (saved.value)
    {
      Get.snackbar(StringConstants.TIP_SAVE_SUCCESS, StringConstants.TIP_SAVED_ALREADY);
      Get.offAllNamed(RouteConstants.HOME);
      return;
    }
    saving.value = true;
    await runTask(
      () async
      {
        await _repository.saveMeasure(result.toRecords());
        saved.value = true;
        Get.snackbar(StringConstants.TIP_SAVE_SUCCESS, StringConstants.TIP_SAVE_SUCCESS);
        Get.offAllNamed(RouteConstants.HOME);
      },
      showLoading: false,
    );
    saving.value = false;
    if (hasError)
    {
      Get.snackbar(StringConstants.TIP_SAVE_FAILED, errorMessage.value);
    }
  }

  /// 重新检测
  void measureAgain()
  {
    Get.offNamed(RouteConstants.MEASURE_PREPARE);
  }

  /// 血氧显示值
  String get spo2Text
  {
    final value = spo2Record.value?.value;
    if (value == null)
    {
      return '--';
    }
    return value.toStringAsFixed(NumberConstants.PRECISION_ZERO);
  }
}
