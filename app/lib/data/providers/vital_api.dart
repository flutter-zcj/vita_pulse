import 'package:get/get.dart';

import '../../constant/api_constant.dart';
import '../../constant/num_constant.dart';
import '../../core/api/api_client.dart';
import '../models/alert_rule.dart';
import '../models/record_page.dart';
import '../models/trend_point.dart';
import '../models/vital_metric.dart';
import '../models/vital_record.dart';

/// 体征业务接口
///
/// 功能说明: 封装 /vital/* 全部接口，页面不得直接发起请求
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class VitalApi
{
  /// 网络客户端
  final ApiClient _client = Get.find<ApiClient>();

  /// 拉取指标字典
  ///
  /// 返回按 dispOrder 升序排列的指标列表
  Future<List<VitalMetric>> fetchMetrics() async
  {
    final data = await _client.get(ApiConstants.METRIC_LIST);
    final list = _asList(data);
    final metrics = list.map((item) => VitalMetric.fromJson(_asMap(item))).toList();
    metrics.sort((left, right) => left.dispOrder.compareTo(right.dispOrder));
    return metrics;
  }

  /// 拉取各指标最新值
  ///
  /// 返回以指标编码为键的记录映射
  Future<Map<String, VitalRecord>> fetchLatest() async
  {
    final data = await _client.get(ApiConstants.RECORD_LATEST);
    final list = _asList(data);
    final result = <String, VitalRecord>{};
    for (final item in list)
    {
      final record = VitalRecord.fromJson(_asMap(item));
      if (record.metric.isNotEmpty)
      {
        result[record.metric] = record;
      }
    }
    return result;
  }

  /// 查询指定指标最近一条记录
  ///
  /// [metric] 指标编码
  /// 返回 null 表示无记录
  Future<VitalRecord?> fetchLatestByMetric(String metric) async
  {
    final data = await _client.get(
      ApiConstants.RECORD_LIST,
      query: <String, dynamic>
      {
        ApiConstants.PARAM_METRIC: metric,
        ApiConstants.PARAM_PAGE_NUM: NumberConstants.FIRST_PAGE_INDEX,
        ApiConstants.PARAM_PAGE_SIZE: 1,
      },
    );
    final map = _asMap(data);
    final rows = _asList(map[ApiConstants.FIELD_ROWS]);
    if (rows.isEmpty)
    {
      return null;
    }
    return VitalRecord.fromJson(_asMap(rows.first));
  }

  /// 分页查询记录
  ///
  /// [metric] 指标编码，空表示全部
  /// [pageNum] 页码
  /// [pageSize] 每页条数
  /// [startTime] 起始时间
  /// [endTime] 结束时间
  Future<RecordPage> fetchRecords({
    String metric = '',
    int pageNum = NumberConstants.FIRST_PAGE_INDEX,
    int pageSize = NumberConstants.PAGE_SIZE_DEFAULT,
    String startTime = '',
    String endTime = '',
  }) async
  {
    final query = <String, dynamic>
    {
      ApiConstants.PARAM_PAGE_NUM: pageNum,
      ApiConstants.PARAM_PAGE_SIZE: pageSize,
    };
    if (metric.isNotEmpty)
    {
      query[ApiConstants.PARAM_METRIC] = metric;
    }
    if (startTime.isNotEmpty)
    {
      query[ApiConstants.PARAM_START_TIME] = startTime;
    }
    if (endTime.isNotEmpty)
    {
      query[ApiConstants.PARAM_END_TIME] = endTime;
    }
    final data = await _client.get(ApiConstants.RECORD_LIST, query: query);
    final map = _asMap(data);
    final rows = _asList(map[ApiConstants.FIELD_ROWS]).map((item) => VitalRecord.fromJson(_asMap(item))).toList();
    final total = map[ApiConstants.FIELD_TOTAL];
    return RecordPage(records: rows, total: total is int ? total : rows.length);
  }

  /// 新增单条记录
  ///
  /// [record] 待写入的记录
  Future<void> createRecord(VitalRecord record) async
  {
    await _client.post(ApiConstants.RECORD, data: record.toJson());
  }

  /// 批量写入记录
  ///
  /// [records] 同一次会话的多条记录
  Future<void> createRecords(List<VitalRecord> records) async
  {
    await _client.post(
      ApiConstants.RECORD_BATCH,
      data: <String, dynamic>{'records': records.map((item) => item.toJson()).toList()},
    );
  }

  /// 删除记录
  ///
  /// [recordIds] 记录主键集合
  Future<void> deleteRecords(List<String> recordIds) async
  {
    await _client.delete('${ApiConstants.RECORD}/${recordIds.join(',')}');
  }

  /// 查询趋势统计
  ///
  /// [metric] 指标编码
  /// [period] 统计周期天数
  Future<List<TrendPoint>> fetchTrend(String metric, int period) async
  {
    final data = await _client.get(
      ApiConstants.RECORD_STAT,
      query: <String, dynamic>
      {
        ApiConstants.PARAM_METRIC: metric,
        ApiConstants.PARAM_PERIOD: period,
      },
    );
    return _asList(data).map((item) => TrendPoint.fromJson(_asMap(item))).toList();
  }

  /// 拉取阈值规则
  Future<List<AlertRule>> fetchAlertRules() async
  {
    final data = await _client.get(ApiConstants.ALERT_RULE);
    return _asList(data).map((item) => AlertRule.fromJson(_asMap(item))).toList();
  }

  /// 保存阈值规则
  ///
  /// [rule] 待保存的规则
  Future<void> saveAlertRule(AlertRule rule) async
  {
    await _client.put(ApiConstants.ALERT_RULE, data: rule.toJson());
  }

  /// 转换为 Map
  ///
  /// [value] 任意结构
  Map<String, dynamic> _asMap(dynamic value)
  {
    if (value is Map<String, dynamic>)
    {
      return value;
    }
    if (value is Map)
    {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return <String, dynamic>{};
  }

  /// 转换为列表
  ///
  /// [value] 任意结构
  List<dynamic> _asList(dynamic value)
  {
    if (value is List)
    {
      return value;
    }
    return <dynamic>[];
  }
}
