import 'package:get/get.dart';

import '../../../constant/num_constant.dart';
import '../../../constant/route_constant.dart';
import '../../../constant/str_constant.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/utils/date_util.dart';
import '../../../data/models/record_page.dart';
import '../../../data/models/vital_metric.dart';
import '../../../data/models/vital_record.dart';
import '../../../data/repositories/vital_repository.dart';

/// 记录列表控制器
///
/// 功能说明: 分页拉取记录、按指标与时间筛选、支持左滑删除
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class RecordsController extends BaseController
{
  /// 体征仓储
  final VitalRepository _repository = Get.find<VitalRepository>();

  /// 记录列表
  final RxList<VitalRecord> records = <VitalRecord>[].obs;

  /// 指标字典，用于筛选下拉
  final RxList<VitalMetric> metrics = <VitalMetric>[].obs;

  /// 当前筛选指标，空字符串表示全部
  final RxString filterMetric = ''.obs;

  /// 当前时间范围天数，0 表示全部
  final RxInt rangeDays = NumberConstants.TREND_DAYS_SHORT.obs;

  /// 页码
  int _pageNum = NumberConstants.FIRST_PAGE_INDEX;

  /// 是否还有下一页
  final RxBool hasMore = true.obs;

  /// 是否正在加载更多
  final RxBool loadingMore = false.obs;

  @override
  void onInit()
  {
    super.onInit();
    _loadMetrics();
    refreshList();
  }

  /// 加载指标字典
  Future<void> _loadMetrics() async
  {
    try
    {
      final loaded = await _repository.loadMetrics();
      metrics.assignAll(loaded);
    }
    catch (error)
    {
      metrics.clear();
    }
  }

  /// 刷新列表
  Future<void> refreshList() async
  {
    _pageNum = NumberConstants.FIRST_PAGE_INDEX;
    hasMore.value = true;
    await runTask(
      () async
      {
        final page = await _fetch(_pageNum);
        records.assignAll(page.records);
        hasMore.value = page.hasMore(page.records.length);
      },
    );
  }

  /// 加载下一页
  Future<void> loadMore() async
  {
    if (!hasMore.value || loadingMore.value)
    {
      return;
    }
    loadingMore.value = true;
    try
    {
      final nextPage = _pageNum + 1;
      final page = await _fetch(nextPage);
      _pageNum = nextPage;
      records.addAll(page.records);
      hasMore.value = page.hasMore(records.length);
    }
    catch (error)
    {
      errorMessage.value = error.toString();
    }
    finally
    {
      loadingMore.value = false;
    }
  }

  /// 切换指标筛选
  ///
  /// [metric] 指标编码，空字符串表示全部
  Future<void> changeMetric(String metric) async
  {
    filterMetric.value = metric;
    await refreshList();
  }

  /// 切换时间范围
  ///
  /// [days] 天数，0 表示全部
  Future<void> changeRange(int days) async
  {
    rangeDays.value = days;
    await refreshList();
  }

  /// 删除远端记录
  ///
  /// [record] 目标记录
  /// 返回 true 表示服务端删除成功
  Future<bool> deleteRemote(VitalRecord record) async
  {
    try
    {
      await _repository.removeRecords(<String>[record.recordId]);
      return true;
    }
    catch (error)
    {
      Get.snackbar(StringConstants.TIP_DELETE_FAILED, error.toString());
      return false;
    }
  }

  /// 从本地列表移除
  ///
  /// [record] 目标记录
  void removeLocal(VitalRecord record)
  {
    records.remove(record);
    Get.snackbar(StringConstants.TIP_DELETE_SUCCESS, StringConstants.TIP_DELETE_SUCCESS);
  }

  /// 打开趋势页
  ///
  /// [metric] 指标编码
  void goTrend(String metric)
  {
    Get.toNamed(RouteConstants.TRENDS, arguments: <String, dynamic>{RouteConstants.ARG_METRIC: metric});
  }

  /// 打开手动录入页
  void goInput()
  {
    Get.toNamed(RouteConstants.RECORD_EDIT);
  }

  /// 执行分页请求
  ///
  /// [pageNum] 页码
  Future<RecordPage> _fetch(int pageNum) async
  {
    final startTime = rangeDays.value == 0 ? '' : DateUtil.toApiTime(DateUtil.daysAgo(rangeDays.value));
    return _repository.loadRecords(
      metric: filterMetric.value,
      pageNum: pageNum,
      startTime: startTime,
    );
  }
}
