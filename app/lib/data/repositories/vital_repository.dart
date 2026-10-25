import 'package:get/get.dart';

import '../models/alert_rule.dart';
import '../models/record_page.dart';
import '../models/trend_point.dart';
import '../models/vital_metric.dart';
import '../models/vital_record.dart';
import '../providers/vital_api.dart';

/// 体征仓储
///
/// 功能说明: 组合接口调用并持有会话级内存缓存，业务数据不落本地
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class VitalRepository extends GetxService
{
  /// 业务接口
  final VitalApi _api = VitalApi();

  /// 指标字典内存缓存
  List<VitalMetric> _metricCache = <VitalMetric>[];

  /// 初始化仓储
  Future<VitalRepository> init() async
  {
    return this;
  }

  /// 获取指标字典
  ///
  /// [forceRefresh] 是否强制刷新，忽略内存缓存
  Future<List<VitalMetric>> loadMetrics({bool forceRefresh = false}) async
  {
    if (!forceRefresh && _metricCache.isNotEmpty)
    {
      return _metricCache;
    }
    final metrics = await _api.fetchMetrics();
    _metricCache = metrics;
    return metrics;
  }

  /// 按编码查找指标
  ///
  /// [metricCode] 指标编码
  /// 返回 null 表示字典中不存在
  VitalMetric? findMetric(String metricCode)
  {
    for (final metric in _metricCache)
    {
      if (metric.metricCode == metricCode)
      {
        return metric;
      }
    }
    return null;
  }

  /// 获取各指标最新值
  Future<Map<String, VitalRecord>> loadLatest() async
  {
    return _api.fetchLatest();
  }

  /// 获取指定指标最近一条记录
  ///
  /// [metric] 指标编码
  Future<VitalRecord?> loadLatestByMetric(String metric) async
  {
    return _api.fetchLatestByMetric(metric);
  }

  /// 分页查询记录
  ///
  /// [metric] 指标编码
  /// [pageNum] 页码
  /// [startTime] 起始时间
  /// [endTime] 结束时间
  Future<RecordPage> loadRecords({
    String metric = '',
    int pageNum = 1,
    String startTime = '',
    String endTime = '',
  }) async
  {
    return _api.fetchRecords(
      metric: metric,
      pageNum: pageNum,
      startTime: startTime,
      endTime: endTime,
    );
  }

  /// 保存测量结果
  ///
  /// [records] 同一次会话的多条记录
  Future<void> saveMeasure(List<VitalRecord> records) async
  {
    await _api.createRecords(records);
  }

  /// 保存单条记录
  ///
  /// [record] 待写入记录
  Future<void> saveRecord(VitalRecord record) async
  {
    await _api.createRecord(record);
  }

  /// 删除记录
  ///
  /// [recordIds] 记录主键集合
  Future<void> removeRecords(List<String> recordIds) async
  {
    await _api.deleteRecords(recordIds);
  }

  /// 查询趋势统计
  ///
  /// [metric] 指标编码
  /// [period] 周期天数
  Future<List<TrendPoint>> loadTrend(String metric, int period) async
  {
    return _api.fetchTrend(metric, period);
  }

  /// 获取阈值规则
  Future<List<AlertRule>> loadAlertRules() async
  {
    return _api.fetchAlertRules();
  }

  /// 保存阈值规则
  ///
  /// [rule] 待保存规则
  Future<void> saveAlertRule(AlertRule rule) async
  {
    await _api.saveAlertRule(rule);
  }
}
