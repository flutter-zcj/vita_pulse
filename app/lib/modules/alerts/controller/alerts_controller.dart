import 'package:get/get.dart';

import '../../../constant/str_constant.dart';
import '../../../core/base/base_controller.dart';
import '../../../data/models/alert_rule.dart';
import '../../../data/models/vital_metric.dart';
import '../../../data/repositories/vital_repository.dart';

/// 预警阈值控制器
///
/// 功能说明: 加载阈值规则、切换启用状态并保存编辑结果
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class AlertsController extends BaseController
{
  /// 体征仓储
  final VitalRepository _repository = Get.find<VitalRepository>();

  /// 规则列表
  final RxList<AlertRule> rules = <AlertRule>[].obs;

  /// 指标字典，用于取默认区间
  final RxList<VitalMetric> metrics = <VitalMetric>[].obs;

  /// 正在提交的规则编码
  final RxString pendingMetric = ''.obs;

  @override
  void onInit()
  {
    super.onInit();
    loadRules();
  }

  /// 加载规则
  Future<void> loadRules() async
  {
    await runTask(
      () async
      {
        final loaded = await _repository.loadAlertRules();
        rules.assignAll(loaded);
        final loadedMetrics = await _repository.loadMetrics();
        metrics.assignAll(loadedMetrics);
      },
    );
  }

  /// 查询指标默认区间
  ///
  /// [metricCode] 指标编码
  /// 返回 [下限, 上限]，未配置时返回 [0, 0]
  List<double> defaultRangeOf(String metricCode)
  {
    final metric = metrics.firstWhereOrNull((item) => item.metricCode == metricCode);
    return <double>[metric?.defaultMin ?? 0, metric?.defaultMax ?? 0];
  }

  /// 切换启用状态
  ///
  /// [rule] 目标规则
  /// [enabled] 是否启用
  Future<void> toggle(AlertRule rule, bool enabled) async
  {
    final index = rules.indexWhere((item) => item.metric == rule.metric);
    if (index < 0)
    {
      return;
    }
    final original = rules[index];
    rules[index] = original.copyWith(enabled: enabled);
    pendingMetric.value = rule.metric;
    try
    {
      await _repository.saveAlertRule(original.copyWith(enabled: enabled));
    }
    catch (error)
    {
      rules[index] = original;
      Get.snackbar(StringConstants.ALERT_TOGGLE_FAILED, error.toString());
    }
    finally
    {
      pendingMetric.value = '';
    }
  }

  /// 保存阈值编辑
  ///
  /// [rule] 目标规则
  /// [minValue] 新下限
  /// [maxValue] 新上限
  /// 返回 true 表示保存成功
  Future<bool> saveRange(AlertRule rule, double minValue, double maxValue) async
  {
    if (minValue >= maxValue)
    {
      Get.snackbar(StringConstants.ALERT_RANGE_INVALID, StringConstants.ALERT_RANGE_INVALID);
      return false;
    }
    try
    {
      final updated = rule.copyWith(minValue: minValue, maxValue: maxValue);
      await _repository.saveAlertRule(updated);
      final index = rules.indexWhere((item) => item.metric == rule.metric);
      if (index >= 0)
      {
        rules[index] = updated;
      }
      return true;
    }
    catch (error)
    {
      Get.snackbar(StringConstants.TIP_SAVE_FAILED, error.toString());
      return false;
    }
  }
}
