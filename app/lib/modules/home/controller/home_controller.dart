import 'package:get/get.dart';

import '../../../constant/route_constant.dart';
import '../../../constant/str_constant.dart';
import '../../../core/base/base_controller.dart';
import '../../../data/models/record_page.dart';
import '../../../data/models/vital_metric.dart';
import '../../../data/models/vital_record.dart';
import '../../../data/repositories/vital_repository.dart';

/// 首页控制器
///
/// 功能说明: 拉取指标字典与最新值，驱动仪表盘卡片与迷你趋势
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class HomeController extends BaseController
{
  /// 体征仓储
  final VitalRepository _repository = Get.find<VitalRepository>();

  /// 指标字典
  final RxList<VitalMetric> metrics = <VitalMetric>[].obs;

  /// 各指标最新记录
  final RxMap<String, VitalRecord> latest = <String, VitalRecord>{}.obs;

  /// 最近心率序列，用于迷你折线
  final RxList<double> recentHeartRates = <double>[].obs;

  @override
  void onInit()
  {
    super.onInit();
    loadData();
  }

  /// 加载首页数据
  Future<void> loadData() async
  {
    await runTask(
      () async
      {
        final loadedMetrics = await _repository.loadMetrics();
        metrics.assignAll(loadedMetrics);
        final loadedLatest = await _repository.loadLatest();
        latest.assignAll(loadedLatest);
        await _loadRecentHeartRates();
      },
    );
  }

  /// 加载最近心率序列
  Future<void> _loadRecentHeartRates() async
  {
    try
    {
      final RecordPage page = await _repository.loadRecords(
        metric: StringConstants.METRIC_HEART_RATE,
      );
      final values = page.records.map((item) => item.value).toList().reversed.toList();
      recentHeartRates.assignAll(values);
    }
    catch (error)
    {
      recentHeartRates.clear();
    }
  }

  /// 跳转测量准备页
  void goMeasure()
  {
    Get.toNamed(RouteConstants.MEASURE_PREPARE);
  }

  /// 跳转趋势页
  ///
  /// [metricCode] 指标编码
  void goTrend(String metricCode)
  {
    Get.toNamed(RouteConstants.TRENDS, arguments: <String, dynamic>{RouteConstants.ARG_METRIC: metricCode});
  }

  /// 跳转手动录入页
  void goInput()
  {
    Get.toNamed(RouteConstants.RECORD_EDIT);
  }

  /// 查询指定指标的最新记录
  ///
  /// [metricCode] 指标编码
  VitalRecord? recordOf(String metricCode)
  {
    return latest[metricCode];
  }
}
