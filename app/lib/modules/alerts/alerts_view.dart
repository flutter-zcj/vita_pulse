import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/num_constant.dart';
import '../../constant/str_constant.dart';
import '../../constant/ui_constant.dart';
import '../../data/models/alert_rule.dart';
import '../../widgets/state_view.dart';
import 'controller/alerts_controller.dart';

/// 预警阈值页面
///
/// 功能说明: 展示各指标阈值规则，支持开关与底部弹层编辑
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class AlertsView extends GetView<AlertsController>
{
  /// 构造函数
  const AlertsView({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(title: const Text(StringConstants.TITLE_ALERTS)),
      body: Obx(
        ()
        {
          if (controller.isLoading.value && controller.rules.isEmpty)
          {
            return const StateView.loading();
          }
          if (controller.hasError && controller.rules.isEmpty)
          {
            return StateView.error(controller.errorMessage.value, onRetry: controller.loadRules);
          }
          if (controller.rules.isEmpty)
          {
            return StateView.empty(StringConstants.RECORDS_EMPTY, onRetry: controller.loadRules);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(UIConstants.PADDING_DEFAULT),
            itemCount: controller.rules.length,
            itemBuilder: (context, index) => _buildRow(controller.rules[index]),
          );
        },
      ),
    );
  }

  /// 单条规则行
  ///
  /// [rule] 规则数据
  Widget _buildRow(AlertRule rule)
  {
    return Container(
      margin: const EdgeInsets.only(bottom: UIConstants.PADDING_MD),
      decoration: BoxDecoration(
        color: UIConstants.COLOR_RESULT_BG,
        borderRadius: BorderRadius.circular(UIConstants.RADIUS_MD),
        border: Border.all(color: UIConstants.COLOR_DIVIDER),
      ),
      child: InkWell(
        onTap: () => _openEditor(rule),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.PADDING_DEFAULT,
            vertical: UIConstants.PADDING_SM,
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
                      rule.label.isEmpty ? rule.metric : rule.label,
                      style: const TextStyle(fontSize: UIConstants.FONT_SM, color: UIConstants.COLOR_TEXT_ON_LIGHT),
                    ),
                    const SizedBox(height: UIConstants.PADDING_XS),
                    Text(
                      rule.rangeText,
                      style: const TextStyle(
                        fontSize: UIConstants.FONT_XS,
                        color: UIConstants.COLOR_TEXT_ON_LIGHT_SUB,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: rule.enabled,
                onChanged: (value) => controller.toggle(rule, value),
              ),
              const Icon(Icons.chevron_right, color: UIConstants.COLOR_TEXT_ON_LIGHT_SUB),
            ],
          ),
        ),
      ),
    );
  }

  /// 打开编辑弹层
  ///
  /// [rule] 目标规则
  Future<void> _openEditor(AlertRule rule) async
  {
    final minController = TextEditingController(text: rule.minValue?.toStringAsFixed(0) ?? '');
    final maxController = TextEditingController(text: rule.maxValue?.toStringAsFixed(0) ?? '');
    await Get.bottomSheet<void>(
      Container(
        padding: const EdgeInsets.all(UIConstants.PADDING_LG),
        decoration: const BoxDecoration(
          color: UIConstants.COLOR_RESULT_BG,
          borderRadius: BorderRadius.vertical(top: Radius.circular(UIConstants.RADIUS_LG)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>
          [
            Text(
              '${StringConstants.ALERT_EDIT_TITLE} · ${rule.label}',
              style: const TextStyle(fontSize: UIConstants.FONT_DEFAULT, color: UIConstants.COLOR_TEXT_ON_LIGHT),
            ),
            const SizedBox(height: UIConstants.PADDING_LG),
            Row(
              children: <Widget>
              [
                Expanded(child: _buildField(StringConstants.ALERT_MIN, minController)),
                const SizedBox(width: UIConstants.PADDING_MD),
                Expanded(child: _buildField(StringConstants.ALERT_MAX, maxController)),
              ],
            ),
            const SizedBox(height: UIConstants.PADDING_LG),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>
              [
                TextButton(
                  onPressed: () => _resetDefault(rule, minController, maxController),
                  child: const Text(StringConstants.ALERT_RESET_DEFAULT),
                ),
                TextButton(
                  onPressed: () => _submit(rule, minController, maxController),
                  child: const Text(StringConstants.BTN_CONFIRM),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
    minController.dispose();
    maxController.dispose();
  }

  /// 输入框
  ///
  /// [label] 标签
  /// [controllerRef] 输入控制器
  Widget _buildField(String label, TextEditingController controllerRef)
  {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>
      [
        Text(
          label,
          style: const TextStyle(fontSize: UIConstants.FONT_XS, color: UIConstants.COLOR_TEXT_ON_LIGHT_SUB),
        ),
        TextField(
          controller: controllerRef,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(isDense: true),
        ),
      ],
    );
  }

  /// 恢复默认区间
  ///
  /// [rule] 目标规则
  /// [minController] 下限输入
  /// [maxController] 上限输入
  void _resetDefault(AlertRule rule, TextEditingController minController, TextEditingController maxController)
  {
    final range = controller.defaultRangeOf(rule.metric);
    minController.text = range[0].toStringAsFixed(NumberConstants.PRECISION_ZERO);
    maxController.text = range[1].toStringAsFixed(NumberConstants.PRECISION_ZERO);
  }

  /// 提交编辑
  ///
  /// [rule] 目标规则
  /// [minController] 下限输入
  /// [maxController] 上限输入
  Future<void> _submit(
    AlertRule rule,
    TextEditingController minController,
    TextEditingController maxController,
  ) async
  {
    final minValue = double.tryParse(minController.text);
    final maxValue = double.tryParse(maxController.text);
    if (minValue == null || maxValue == null)
    {
      Get.snackbar(StringConstants.EDIT_INVALID_NUMBER, StringConstants.EDIT_INVALID_NUMBER);
      return;
    }
    final success = await controller.saveRange(rule, minValue, maxValue);
    if (success)
    {
      Get.back();
    }
  }
}
