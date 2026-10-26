import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constant/num_constant.dart';
import '../../../constant/str_constant.dart';
import '../../../constant/ui_constant.dart';
import '../../../widgets/primary_button.dart';
import 'controller/result_controller.dart';

/// 检测结果页面
///
/// 功能说明: 展示心率、舒适度、HRV 与血氧，并支持保存或重新检测
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class ResultView extends GetView<ResultController>
{
  /// 构造函数
  const ResultView({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: UIConstants.COLOR_RESULT_BG,
      appBar: AppBar(title: const Text(StringConstants.TITLE_MEASURE_RESULT)),
      body: ListView(
        padding: const EdgeInsets.all(UIConstants.PADDING_DEFAULT),
        children: <Widget>
        [
          if (controller.result.isWeak) _buildWeakBanner(),
          _buildMetricGrid(),
          const SizedBox(height: UIConstants.PADDING_LG),
          _buildStressSection(),
          const SizedBox(height: UIConstants.PADDING_LG),
          const Text(
            StringConstants.RESULT_STRESS_DESC,
            style: TextStyle(fontSize: UIConstants.FONT_XS, color: UIConstants.COLOR_TEXT_ON_LIGHT_SUB),
          ),
          const SizedBox(height: UIConstants.PADDING_XS),
          const Text(
            StringConstants.DISCLAIMER,
            style: TextStyle(fontSize: UIConstants.FONT_XS, color: UIConstants.COLOR_TEXT_ON_LIGHT_SUB),
          ),
          const SizedBox(height: UIConstants.PADDING_XL),
          Obx(
            () => PrimaryButton(
              text: StringConstants.RESULT_SAVE,
              loading: controller.saving.value,
              onPressed: controller.saving.value ? null : controller.save,
            ),
          ),
          const SizedBox(height: UIConstants.PADDING_SM),
          TextButton(
            onPressed: controller.measureAgain,
            child: const Text(StringConstants.RESULT_AGAIN),
          ),
        ],
      ),
    );
  }

  /// 信号较弱提示条
  Widget _buildWeakBanner()
  {
    return Container(
      margin: const EdgeInsets.only(bottom: UIConstants.PADDING_MD),
      padding: const EdgeInsets.all(UIConstants.PADDING_MD),
      decoration: BoxDecoration(
        color: UIConstants.COLOR_WARNING.withOpacity(0.12),
        borderRadius: BorderRadius.circular(UIConstants.RADIUS_DEFAULT),
      ),
      child: const Row(
        children: <Widget>
        [
          Icon(Icons.info_outline, size: UIConstants.ICON_SM, color: UIConstants.COLOR_WARNING),
          SizedBox(width: UIConstants.PADDING_SM),
          Expanded(
            child: Text(
              StringConstants.RESULT_WEAK_HINT,
              style: TextStyle(fontSize: UIConstants.FONT_XS, color: UIConstants.COLOR_WARNING),
            ),
          ),
        ],
      ),
    );
  }

  /// 四宫格指标
  Widget _buildMetricGrid()
  {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: UIConstants.PADDING_MD,
      crossAxisSpacing: UIConstants.PADDING_MD,
      childAspectRatio: 1.6,
      children: <Widget>
      [
        _buildTile(
          StringConstants.RESULT_HR,
          controller.result.heartRate.toStringAsFixed(NumberConstants.PRECISION_ZERO),
          'bpm',
          StringConstants.RESULT_SOURCE_CAMERA,
        ),
        _buildTile(
          StringConstants.RESULT_COMFORT,
          controller.result.comfort.toString(),
          '',
          '',
        ),
        _buildTile(
          StringConstants.RESULT_HRV,
          controller.result.rmssd.toStringAsFixed(NumberConstants.PRECISION_ZERO),
          'ms',
          '',
        ),
        Obx(
          () => _buildTile(
            StringConstants.RESULT_SPO2,
            controller.spo2Text,
            '%',
            controller.spo2Record.value == null ? StringConstants.RESULT_NO_SPO2 : StringConstants.RESULT_SOURCE_MANUAL,
          ),
        ),
      ],
    );
  }

  /// 单个指标卡
  ///
  /// [label] 指标名
  /// [value] 数值文本
  /// [unit] 单位
  /// [badge] 来源角标
  Widget _buildTile(String label, String value, String unit, String badge)
  {
    return Container(
      padding: const EdgeInsets.all(UIConstants.PADDING_MD),
      decoration: BoxDecoration(
        color: UIConstants.COLOR_RESULT_BG,
        borderRadius: BorderRadius.circular(UIConstants.RADIUS_MD),
        border: Border.all(color: UIConstants.COLOR_DIVIDER),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>
        [
          Row(
            children: <Widget>
            [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: UIConstants.FONT_XS,
                    color: UIConstants.COLOR_TEXT_ON_LIGHT_SUB,
                  ),
                ),
              ),
              if (badge.isNotEmpty)
                Text(
                  badge,
                  style: const TextStyle(fontSize: UIConstants.FONT_XS - 2, color: UIConstants.COLOR_ACCENT_LIGHT),
                ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>
            [
              Text(
                value,
                style: const TextStyle(
                  fontSize: UIConstants.FONT_LG,
                  fontWeight: FontWeight.w600,
                  color: UIConstants.COLOR_TEXT_ON_LIGHT,
                ),
              ),
              if (unit.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: UIConstants.PADDING_XS),
                  child: Text(
                    unit,
                    style: const TextStyle(fontSize: UIConstants.FONT_XS, color: UIConstants.COLOR_TEXT_ON_LIGHT_SUB),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// 压力段位条
  Widget _buildStressSection()
  {
    final labels = <String>
    [
      StringConstants.STRESS_VERY_LOW,
      StringConstants.STRESS_LOW,
      StringConstants.STRESS_MIDDLE,
      StringConstants.STRESS_HIGH,
      StringConstants.STRESS_VERY_HIGH,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>
      [
        Row(
          children: <Widget>
          [
            const Text(
              StringConstants.RESULT_STRESS,
              style: TextStyle(fontSize: UIConstants.FONT_SM, color: UIConstants.COLOR_TEXT_ON_LIGHT),
            ),
            const Spacer(),
            Text(
              controller.result.stressLabel,
              style: const TextStyle(fontSize: UIConstants.FONT_SM, color: UIConstants.COLOR_ACCENT_LIGHT),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.PADDING_SM),
        Row(
          children: List<Widget>.generate(
            labels.length,
            (index)
            {
              final active = index == controller.result.stressIndex;
              return Expanded(
                child: Container(
                  height: UIConstants.PADDING_SM,
                  margin: const EdgeInsets.only(right: UIConstants.PADDING_XS),
                  decoration: BoxDecoration(
                    color: active
                        ? UIConstants.COLOR_ACCENT_LIGHT
                        : UIConstants.COLOR_DIVIDER,
                    borderRadius: BorderRadius.circular(UIConstants.RADIUS_SM),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: UIConstants.PADDING_XS),
        Row(
          children: List<Widget>.generate(
            labels.length,
            (index)
            {
              return Expanded(
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: UIConstants.FONT_XS - 2,
                    color: UIConstants.COLOR_TEXT_ON_LIGHT_SUB,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
