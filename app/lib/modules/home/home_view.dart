import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/num_constant.dart';
import '../../constant/str_constant.dart';
import '../../constant/ui_constant.dart';
import '../../core/utils/date_util.dart';
import '../../widgets/main_bottom_bar.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/state_view.dart';
import 'controller/home_controller.dart';

/// 首页仪表盘
///
/// 功能说明: 展示今日指标卡片、最近心率迷你趋势与测量入口
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class HomeView extends GetView<HomeController>
{
  /// 构造函数
  const HomeView({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(title: const Text(StringConstants.TITLE_HOME)),
      body: Obx(
        ()
        {
          if (controller.isLoading.value && controller.metrics.isEmpty)
          {
            return const StateView.loading();
          }
          if (controller.hasError && controller.metrics.isEmpty)
          {
            return StateView.error(
              controller.errorMessage.value,
              onRetry: controller.loadData,
            );
          }
          return RefreshIndicator(
            onRefresh: controller.loadData,
            child: ListView(
              padding: const EdgeInsets.all(UIConstants.PADDING_DEFAULT),
              children: <Widget>
              [
                Text(
                  DateUtil.formatDate(DateTime.now()),
                  style: const TextStyle(
                    fontSize: UIConstants.FONT_XS,
                    color: UIConstants.COLOR_TEXT_ON_LIGHT_SUB,
                  ),
                ),
                const SizedBox(height: UIConstants.PADDING_MD),
                ..._buildMetricCards(),
                const SizedBox(height: UIConstants.PADDING_MD),
                _buildSparklineCard(),
                const SizedBox(height: UIConstants.PADDING_LG),
                PrimaryButton(
                  text: StringConstants.HOME_START_MEASURE,
                  onPressed: controller.goMeasure,
                ),
                const SizedBox(height: UIConstants.PADDING_LG),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const MainBottomBar(currentIndex: NumberConstants.TAB_INDEX_HOME),
    );
  }

  /// 构建指标卡片列表
  List<Widget> _buildMetricCards()
  {
    final widgets = <Widget>[];
    for (final metric in controller.metrics)
    {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: UIConstants.PADDING_MD),
          child: MetricCard(
            metric: metric,
            record: controller.recordOf(metric.metricCode),
            onTap: () => controller.goTrend(metric.metricCode),
          ),
        ),
      );
    }
    return widgets;
  }

  /// 构建迷你趋势卡
  Widget _buildSparklineCard()
  {
    final values = controller.recentHeartRates;
    return Container(
      padding: const EdgeInsets.all(UIConstants.PADDING_DEFAULT),
      decoration: BoxDecoration(
        color: UIConstants.COLOR_RESULT_BG,
        borderRadius: BorderRadius.circular(UIConstants.RADIUS_MD),
        border: Border.all(color: UIConstants.COLOR_DIVIDER),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>
        [
          const Text(
            StringConstants.HOME_RECENT_TREND,
            style: TextStyle(
              fontSize: UIConstants.FONT_SM,
              color: UIConstants.COLOR_TEXT_ON_LIGHT_SUB,
            ),
          ),
          const SizedBox(height: UIConstants.PADDING_MD),
          SizedBox(
            height: UIConstants.WAVE_HEIGHT / 2,
            child: values.isEmpty
                ? const Center(
                    child: Text(
                      StringConstants.HOME_GO_INPUT,
                      style: TextStyle(
                        fontSize: UIConstants.FONT_XS,
                        color: UIConstants.COLOR_ACCENT_LIGHT,
                      ),
                    ),
                  )
                : CustomPaint(
                    painter: _SparklinePainter(values.toList()),
                    size: Size.infinite,
                  ),
          ),
        ],
      ),
    );
  }
}

/// 迷你折线绘制
///
/// 功能说明: 将最近若干次心率绘制为无坐标轴的折线
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class _SparklinePainter extends CustomPainter
{
  /// 数据序列
  final List<double> values;

  /// 构造函数
  _SparklinePainter(this.values);

  @override
  void paint(Canvas canvas, Size size)
  {
    if (values.length < 2)
    {
      return;
    }
    var minValue = values.first;
    var maxValue = values.first;
    for (final item in values)
    {
      if (item < minValue)
      {
        minValue = item;
      }
      if (item > maxValue)
      {
        maxValue = item;
      }
    }
    final span = maxValue - minValue;
    final paint = Paint()
      ..color = UIConstants.COLOR_ACCENT_LIGHT
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path();
    for (var index = 0; index < values.length; index++)
    {
      final ratioX = index / (values.length - 1);
      final ratioY = span <= 0 ? 0.5 : (values[index] - minValue) / span;
      final dx = size.width * ratioX;
      final dy = size.height * (1 - ratioY);
      if (index == 0)
      {
        path.moveTo(dx, dy);
      }
      else
      {
        path.lineTo(dx, dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate)
  {
    return oldDelegate.values != values;
  }
}
