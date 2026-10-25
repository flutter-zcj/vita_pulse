import 'package:get/get.dart';

import '../../../constant/num_constant.dart';
import '../../../constant/route_constant.dart';
import '../../../constant/str_constant.dart';
import '../../../core/base/base_controller.dart';
import '../../../data/models/trend_point.dart';
import '../../../data/models/vital_metric.dart';
import '../../../data/repositories/vital_repository.dart';

/// 趋势分析控制器
///
/// 功能说明: 按指标与周期加载聚合数据，并计算统计摘要
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class TrendsController extends BaseController
{
  /// 体征仓储
  final VitalRepository _repository = Get.find<VitalRepository>();

  /// 指标字典
  final RxList<VitalMetric> metrics = <VitalMetric>[].obs;

  /// 当前指标
  final Rxn<VitalMetric> selectedMetric = Rxn<VitalMetric>();

  /// 当前周期天数
  final RxInt periodDays = NumberConstants.TREND_DAYS_SHORT.obs;

  /// 聚合点集合
  final RxList<TrendPoint> points = <TrendPoint>[].obs;

  @override
  void onInit()
  {
    super.onInit();
    _bootstrap();
  }

  /// 初始化加载
  Future<void> _bootstrap() async
  {
    await runTask(
      () async
      {
        final loaded = await _repository.loadMetrics();
        metrics.assignAll(loaded);
        final args = Get.arguments;
        var code = StringConstants.METRIC_HEART_RATE;
        if (args is Map && args[RouteConstants.ARG_METRIC] != null)
        {
          code = args[RouteConstants.ARG_METRIC].toString();
        }
        selectedMetric.value = loaded.firstWhere(
          (item) => item.metricCode == code,
          orElse: () => loaded.isEmpty ? const VitalMetric(metricCode: '', label: '', unit: '') : loaded.first,
        );
        await _loadTrend();
      },
    );
  }

  /// 切换指标
  ///
  /// [metric] 目标指标
  Future<void> changeMetric(VitalMetric metric) async
  {
    selectedMetric.value = metric;
    periodDays.value = NumberConstants.TREND_DAYS_SHORT;
    await _loadTrend();
  }

  /// 切换周期
  ///
  /// [days] 周期天数
  Future<void> changePeriod(int days) async
  {
    if (periodDays.value == days)
    {
      return;
    }
    periodDays.value = days;
    await _loadTrend();
  }

  /// 重新加载
  Future<void> reload() async
  {
    await _loadTrend();
  }

  /// 加载趋势数据
  Future<void> _loadTrend() async
  {
    final metric = selectedMetric.value;
    if (metric == null || metric.metricCode.isEmpty)
    {
      return;
    }
    await runTask(
      () async
      {
        final loaded = await _repository.loadTrend(metric.metricCode, periodDays.value);
        points.assignAll(loaded);
      },
    );
  }

  /// 最小值
  double? get minValue => _reduce((current, item) => item.value < current ? item.value : current);

  /// 最大值
  double? get maxValue => _reduce((current, item) => item.value > current ? item.value : current);

  /// 平均值
  double? get avgValue
  {
    if (points.isEmpty)
    {
      return null;
    }
    var sum = 0.0;
    for (final item in points)
    {
      sum = sum + item.value;
    }
    return sum / points.length;
  }

  /// 样本数
  int get sampleCount => points.length;

  /// 是否样本过少
  bool get isFewSamples => points.length < 2;

  /// 归约计算
  ///
  /// [reducer] 比较函数
  double? _reduce(double Function(double, TrendPoint) reducer)
  {
    if (points.isEmpty)
    {
      return null;
    }
    var current = points.first.value;
    for (final item in points)
    {
      current = reducer(current, item);
    }
    return current;
  }
}
