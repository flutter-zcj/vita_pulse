import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/num_constant.dart';
import '../../constant/str_constant.dart';
import '../../constant/ui_constant.dart';
import '../../core/utils/date_util.dart';
import '../../core/utils/format_util.dart';
import '../../data/models/trend_point.dart';
import '../../data/models/vital_metric.dart';
import '../../widgets/main_bottom_bar.dart';
import '../../widgets/state_view.dart';
import 'controller/trends_controller.dart';

/// 趋势分析页面
///
/// 功能说明: 以折线图展示指标变化，叠加参考区间带与统计摘要
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class TrendsView extends GetView<TrendsController>
{
  /// 构造函数
  const TrendsView({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(title: const Text(StringConstants.TITLE_TRENDS)),
      body: Column(
        children: <Widget>
        [
          _buildFilterBar(),
          Expanded(child: Obx(() => _buildBody())),
        ],
      ),
      bottomNavigationBar: const MainBottomBar(currentIndex: NumberConstants.TAB_INDEX_TRENDS),
    );
  }

  /// 顶部筛选
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
              value: controller.selectedMetric.value?.metricCode,
              underline: const SizedBox.shrink(),
              items: controller.metrics
                  .map(
                    (VitalMetric metric) => DropdownMenuItem<String>(
                      value: metric.metricCode,
                      child: Text(metric.label),
                    ),
                  )
                  .toList(),
              onChanged: (code)
              {
                final metric = controller.metrics.firstWhereOrNull((item) => item.metricCode == code);
                if (metric != null)
                {
                  controller.changeMetric(metric);
                }
              },
            ),
          ),
          const Spacer(),
          _buildPeriodChip(NumberConstants.TREND_DAYS_SHORT, StringConstants.RECORDS_RANGE_7),
          _buildPeriodChip(NumberConstants.TREND_DAYS_MIDDLE, StringConstants.RECORDS_RANGE_30),
          _buildPeriodChip(NumberConstants.TREND_DAYS_LONG, StringConstants.RECORDS_RANGE_90),
        ],
      ),
    );
  }

  /// 周期芯片
  ///
  /// [days] 天数
  /// [label] 文案
  Widget _buildPeriodChip(int days, String label)
  {
    return Obx(
      ()
      {
        final active = controller.periodDays.value == days;
        return Padding(
          padding: const EdgeInsets.only(left: UIConstants.PADDING_SM),
          child: GestureDetector(
            onTap: () => controller.changePeriod(days),
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

  /// 主体内容
  Widget _buildBody()
  {
    if (controller.isLoading.value && controller.points.isEmpty)
    {
      return const StateView.loading();
    }
    if (controller.hasError && controller.points.isEmpty)
    {
      return StateView.error(controller.errorMessage.value, onRetry: controller.reload);
    }
    if (controller.points.isEmpty)
    {
      return StateView.empty(StringConstants.TREND_EMPTY, onRetry: controller.reload);
    }
    return ListView(
      padding: const EdgeInsets.all(UIConstants.PADDING_DEFAULT),
      children: <Widget>
      [
        SizedBox(height: UIConstants.CHART_HEIGHT, child: _buildChart()),
        const SizedBox(height: UIConstants.PADDING_LG),
        _buildStats(),
        if (controller.isFewSamples)
          Padding(
            padding: const EdgeInsets.only(top: UIConstants.PADDING_MD),
            child: Text(
              StringConstants.TREND_FEW_SAMPLES,
              style: TextStyle(fontSize: UIConstants.FONT_XS, color: UIConstants.COLOR_TEXT_ON_LIGHT_SUB),
            ),
          ),
      ],
    );
  }

  /// 折线图
  Widget _buildChart()
  {
    final points = controller.points;
    final metric = controller.selectedMetric.value;
    final spots = <FlSpot>[];
    for (var index = 0; index < points.length; index++)
    {
      spots.add(FlSpot(index.toDouble(), points[index].value));
    }
    final minValue = controller.minValue ?? NumberConstants.ZERO;
    final maxValue = controller.maxValue ?? NumberConstants.HUNDRED;
    final padding = (maxValue - minValue) * 0.2 + 1;

    return LineChart(
      LineChartData(
        minY: minValue - padding,
        maxY: maxValue + padding,
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: UIConstants.PADDING_XXL),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: UIConstants.PADDING_XXL,
              interval: _labelInterval(points.length),
              getTitlesWidget: (value, meta) => _bottomLabel(value, points),
            ),
          ),
        ),
        rangeAnnotations: _buildRange(metric),
        lineBarsData: <LineChartBarData>
        [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: UIConstants.COLOR_ACCENT_LIGHT,
            barWidth: 2,
            dotData: FlDotData(show: points.length <= NumberConstants.CHART_DOT_MAX_POINTS),
            belowBarData: BarAreaData(
              show: true,
              color: UIConstants.COLOR_ACCENT_LIGHT.withOpacity(0.08),
            ),
          ),
        ],
      ),
    );
  }

  /// 参考区间标注
  ///
  /// [metric] 当前指标
  RangeAnnotations _buildRange(VitalMetric? metric)
  {
    final minValue = metric?.defaultMin;
    final maxValue = metric?.defaultMax;
    if (minValue == null || maxValue == null)
    {
      return RangeAnnotations();
    }
    return RangeAnnotations(
      horizontalRangeAnnotations: <HorizontalRangeAnnotation>
      [
        HorizontalRangeAnnotation(
          y1: minValue,
          y2: maxValue,
          color: UIConstants.COLOR_ACCENT_LIGHT.withOpacity(0.08),
        ),
      ],
    );
  }

  /// 横轴标签间隔
  ///
  /// [count] 点数
  double _labelInterval(int count)
  {
    if (count <= NumberConstants.TREND_MAX_LABELS)
    {
      return NumberConstants.ONE;
    }
    return (count / NumberConstants.TREND_MAX_LABELS).ceilToDouble();
  }

  /// 横轴标签
  ///
  /// [value] 坐标值
  /// [points] 数据集合
  Widget _bottomLabel(double value, List<TrendPoint> points)
  {
    final index = value.round();
    if (index < 0 || index >= points.length)
    {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: UIConstants.PADDING_XS),
      child: Text(
        DateUtil.formatShortDate(points[index].time),
        style: TextStyle(fontSize: UIConstants.FONT_XS - 2, color: UIConstants.COLOR_TEXT_ON_LIGHT_SUB),
      ),
    );
  }

  /// 统计摘要
  Widget _buildStats()
  {
    final metric = controller.selectedMetric.value;
    final precision = metric?.precision ?? NumberConstants.PRECISION_ZERO;
    return Container(
      padding: const EdgeInsets.all(UIConstants.PADDING_DEFAULT),
      decoration: BoxDecoration(
        color: UIConstants.COLOR_RESULT_BG,
        borderRadius: BorderRadius.circular(UIConstants.RADIUS_MD),
        border: Border.all(color: UIConstants.COLOR_DIVIDER),
      ),
      child: Row(
        children: <Widget>
        [
          _buildStatItem(StringConstants.TREND_MIN, FormatUtil.formatValue(controller.minValue, precision)),
          _buildStatItem(StringConstants.TREND_AVG, FormatUtil.formatValue(controller.avgValue, precision)),
          _buildStatItem(StringConstants.TREND_MAX, FormatUtil.formatValue(controller.maxValue, precision)),
          _buildStatItem(StringConstants.TREND_COUNT, '${controller.sampleCount}'),
        ],
      ),
    );
  }

  /// 单项统计
  ///
  /// [label] 标签
  /// [value] 数值文本
  Widget _buildStatItem(String label, String value)
  {
    return Expanded(
      child: Column(
        children: <Widget>
        [
          Text(
            value,
            style: TextStyle(
              fontSize: UIConstants.FONT_MD,
              fontWeight: FontWeight.w600,
              color: UIConstants.COLOR_TEXT_ON_LIGHT,
            ),
          ),
          const SizedBox(height: UIConstants.PADDING_XS),
          Text(
            label,
            style: TextStyle(fontSize: UIConstants.FONT_XS, color: UIConstants.COLOR_TEXT_ON_LIGHT_SUB),
          ),
        ],
      ),
    );
  }
}
