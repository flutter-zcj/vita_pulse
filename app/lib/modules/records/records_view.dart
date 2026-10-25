import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/num_constant.dart';
import '../../constant/str_constant.dart';
import '../../constant/ui_constant.dart';
import '../../core/utils/date_util.dart';
import '../../core/utils/format_util.dart';
import '../../data/models/vital_metric.dart';
import '../../data/models/vital_record.dart';
import '../../widgets/main_bottom_bar.dart';
import '../../widgets/state_view.dart';
import 'controller/records_controller.dart';

/// 记录列表页面
///
/// 功能说明: 展示体征记录，支持筛选、分页加载与左滑删除
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class RecordsView extends GetView<RecordsController>
{
  /// 构造函数
  const RecordsView({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(title: const Text(StringConstants.TITLE_RECORDS)),
      body: Column(
        children: <Widget>
        [
          _buildFilterBar(),
          Expanded(child: _buildList()),
        ],
      ),
      bottomNavigationBar: const MainBottomBar(currentIndex: NumberConstants.TAB_INDEX_RECORDS),
    );
  }

  /// 筛选栏
  Widget _buildFilterBar()
  {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.PADDING_DEFAULT,
        vertical: UIConstants.PADDING_SM,
      ),
      child: Row(
        children: <Widget>
        [
          Obx(
            () => DropdownButton<String>(
              value: controller.filterMetric.value.isEmpty ? null : controller.filterMetric.value,
              hint: const Text(StringConstants.RECORDS_FILTER_ALL),
              underline: const SizedBox.shrink(),
              items: <DropdownMenuItem<String>>[
                const DropdownMenuItem<String>(
                  value: '',
                  child: Text(StringConstants.RECORDS_FILTER_ALL),
                ),
                ...controller.metrics.map(
                  (VitalMetric metric) => DropdownMenuItem<String>(
                    value: metric.metricCode,
                    child: Text(metric.label),
                  ),
                ),
              ],
              onChanged: (value) => controller.changeMetric(value ?? ''),
            ),
          ),
          const Spacer(),
          _buildRangeChip(StringConstants.RECORDS_RANGE_7, NumberConstants.TREND_DAYS_SHORT),
          _buildRangeChip(StringConstants.RECORDS_RANGE_30, NumberConstants.TREND_DAYS_MIDDLE),
          _buildRangeChip(StringConstants.RECORDS_RANGE_ALL, 0),
        ],
      ),
    );
  }

  /// 时间范围芯片
  ///
  /// [label] 文案
  /// [days] 天数，0 表示全部
  Widget _buildRangeChip(String label, int days)
  {
    return Obx(
      ()
      {
        final active = controller.rangeDays.value == days;
        return Padding(
          padding: const EdgeInsets.only(left: UIConstants.PADDING_SM),
          child: GestureDetector(
            onTap: () => controller.changeRange(days),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.PADDING_SM,
                vertical: UIConstants.PADDING_XS,
              ),
              decoration: BoxDecoration(
                color: active ? UIConstants.COLOR_ACCENT_LIGHT : UIConstants.COLOR_RESULT_BG,
                borderRadius: BorderRadius.circular(UIConstants.RADIUS_ROUND),
                border: Border.all(color: UIConstants.COLOR_DIVIDER),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: UIConstants.FONT_XS,
                  color: active ? UIConstants.COLOR_RESULT_BG : UIConstants.COLOR_TEXT_ON_LIGHT_SUB,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 记录列表主体
  Widget _buildList()
  {
    return Obx(
      ()
      {
        if (controller.isLoading.value && controller.records.isEmpty)
        {
          return const StateView.loading();
        }
        if (controller.hasError && controller.records.isEmpty)
        {
          return StateView.error(
            controller.errorMessage.value,
            onRetry: controller.refreshList,
          );
        }
        if (controller.records.isEmpty)
        {
          return StateView.empty(
            StringConstants.RECORDS_EMPTY,
            onRetry: controller.goInput,
          );
        }
        return NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: RefreshIndicator(
            onRefresh: controller.refreshList,
            child: ListView.builder(
              padding: const EdgeInsets.all(UIConstants.PADDING_DEFAULT),
              itemCount: controller.records.length,
              itemBuilder: (context, index)
              {
                final record = controller.records[index];
                return _buildCard(record);
              },
            ),
          ),
        );
      },
    );
  }

  /// 滚动监听触发加载更多
  ///
  /// [notification] 滚动通知
  bool _onScroll(ScrollNotification notification)
  {
    if (notification.metrics.pixels >=
        notification.metrics.maxScrollExtent - NumberConstants.LOAD_MORE_THRESHOLD)
    {
      controller.loadMore();
    }
    return false;
  }

  /// 单条记录卡片
  ///
  /// [record] 记录数据
  Widget _buildCard(VitalRecord record)
  {
    final label = _labelOf(record.metric);
    return Dismissible(
      key: ValueKey<String>(record.recordId),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _confirmDelete(record),
      onDismissed: (direction) => controller.removeLocal(record),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: UIConstants.PADDING_LG),
        color: UIConstants.COLOR_DANGER,
        child: const Text(
          StringConstants.BTN_DELETE,
          style: TextStyle(color: UIConstants.COLOR_RESULT_BG),
        ),
      ),
      child: InkWell(
        onTap: () => controller.goTrend(record.metric),
        child: Container(
          margin: const EdgeInsets.only(bottom: UIConstants.PADDING_MD),
          padding: const EdgeInsets.all(UIConstants.PADDING_DEFAULT),
          decoration: BoxDecoration(
            color: UIConstants.COLOR_RESULT_BG,
            borderRadius: BorderRadius.circular(UIConstants.RADIUS_MD),
            border: Border.all(color: UIConstants.COLOR_DIVIDER),
          ),
          child: Row(
            children: <Widget>
            [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>
                  [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: UIConstants.FONT_SM,
                        color: UIConstants.COLOR_TEXT_ON_LIGHT,
                      ),
                    ),
                    const SizedBox(height: UIConstants.PADDING_XS),
                    Text(
                      '${FormatUtil.formatValue(record.value, NumberConstants.PRECISION_ZERO)} ${record.unit}',
                      style: TextStyle(
                        fontSize: UIConstants.FONT_MD,
                        fontWeight: FontWeight.w600,
                        color: UIConstants.COLOR_TEXT_ON_LIGHT,
                      ),
                    ),
                    const SizedBox(height: UIConstants.PADDING_XS),
                    Text(
                      DateUtil.formatRecordTime(record.measuredAt),
                      style: TextStyle(
                        fontSize: UIConstants.FONT_XS,
                        color: UIConstants.COLOR_TEXT_ON_LIGHT_SUB,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: UIConstants.COLOR_TEXT_ON_LIGHT_SUB,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 删除确认
  ///
  /// [record] 目标记录
  Future<bool> _confirmDelete(VitalRecord record) async
  {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        content: const Text(StringConstants.RECORDS_DELETE_CONFIRM),
        actions: <Widget>
        [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(StringConstants.BTN_CANCEL),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(StringConstants.BTN_CONFIRM),
          ),
        ],
      ),
    );
    if (confirmed != true)
    {
      return false;
    }
    return controller.deleteRemote(record);
  }

  /// 指标名称
  ///
  /// [metricCode] 指标编码
  String _labelOf(String metricCode)
  {
    final metric = controller.metrics.firstWhereOrNull((item) => item.metricCode == metricCode);
    return metric?.label ?? metricCode;
  }
}
