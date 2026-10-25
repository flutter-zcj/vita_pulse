import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/num_constant.dart';
import '../../constant/str_constant.dart';
import '../../constant/ui_constant.dart';
import '../../core/utils/date_util.dart';
import '../../data/models/vital_metric.dart';
import '../../widgets/primary_button.dart';
import 'controller/record_edit_controller.dart';

/// 手动录入页面
///
/// 功能说明: 按指标类型录入数值，校验通过后提交到后端
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class RecordEditView extends GetView<RecordEditController>
{
  /// 构造函数
  const RecordEditView({super.key});

  @override
  Widget build(BuildContext context)
  {
    return PopScope(
      canPop: !controller.isDirty,
      onPopInvoked: (didPop) => _handlePop(didPop),
      child: Scaffold(
        appBar: AppBar(title: const Text(StringConstants.TITLE_RECORD_EDIT)),
        body: Obx(
          ()
          {
            if (controller.isLoading.value && controller.metrics.isEmpty)
            {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              padding: const EdgeInsets.all(UIConstants.PADDING_DEFAULT),
              children: <Widget>
              [
                _buildMetricSelector(),
                const SizedBox(height: UIConstants.PADDING_LG),
                _buildValueInputs(),
                const SizedBox(height: UIConstants.PADDING_LG),
                _buildTimePicker(context),
                const SizedBox(height: UIConstants.PADDING_LG),
                _buildRemark(),
                const SizedBox(height: UIConstants.PADDING_XXL),
                Obx(
                  () => PrimaryButton(
                    text: StringConstants.BTN_SAVE,
                    loading: controller.submitting.value,
                    onPressed: controller.canSubmit ? controller.submit : null,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 指标选择行
  Widget _buildMetricSelector()
  {
    return Obx(
      ()
      {
        final current = controller.selectedMetric.value;
        return Row(
          children: <Widget>
          [
            Text(
              '*${StringConstants.EDIT_METRIC}',
              style: TextStyle(fontSize: UIConstants.FONT_SM, color: UIConstants.COLOR_TEXT_ON_LIGHT),
            ),
            const Spacer(),
            DropdownButton<String>(
              value: current?.metricCode,
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
                  controller.selectMetric(metric);
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// 数值输入区
  Widget _buildValueInputs()
  {
    final metric = controller.selectedMetric.value;
    if (metric == null)
    {
      return const SizedBox.shrink();
    }
    if (metric.isDual)
    {
      return Column(
        children: <Widget>
        [
          _buildNumberRow(StringConstants.EDIT_SYSTOLIC, controller.systolicController),
          const SizedBox(height: UIConstants.PADDING_MD),
          _buildNumberRow(StringConstants.EDIT_DIASTOLIC, controller.diastolicController),
          _buildErrorText(),
        ],
      );
    }
    return Column(
      children: <Widget>
      [
        _buildNumberRow(StringConstants.EDIT_VALUE, controller.valueController),
        const SizedBox(height: UIConstants.PADDING_XS),
        Row(
          children: <Widget>
          [
            Text(
              StringConstants.EDIT_UNIT,
              style: TextStyle(fontSize: UIConstants.FONT_XS, color: UIConstants.COLOR_TEXT_ON_LIGHT_SUB),
            ),
            const SizedBox(width: UIConstants.PADDING_SM),
            Text(
              metric.unit,
              style: TextStyle(fontSize: UIConstants.FONT_XS, color: UIConstants.COLOR_TEXT_ON_LIGHT_SUB),
            ),
          ],
        ),
        _buildErrorText(),
      ],
    );
  }

  /// 数字输入行
  ///
  /// [label] 字段名
  /// [controllerRef] 输入控制器
  Widget _buildNumberRow(String label, TextEditingController controllerRef)
  {
    return Row(
      children: <Widget>
      [
        SizedBox(
          width: UIConstants.CHART_HEIGHT / 3,
          child: Text(
            '*$label',
            style: TextStyle(fontSize: UIConstants.FONT_SM, color: UIConstants.COLOR_TEXT_ON_LIGHT),
          ),
        ),
        Expanded(
          child: TextField(
            controller: controllerRef,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: StringConstants.EDIT_HINT_VALUE,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  /// 错误提示
  Widget _buildErrorText()
  {
    return Obx(
      ()
      {
        if (controller.valueError.value.isEmpty)
        {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: UIConstants.PADDING_XS),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              controller.valueError.value,
              style: TextStyle(fontSize: UIConstants.FONT_XS, color: UIConstants.COLOR_DANGER),
            ),
          ),
        );
      },
    );
  }

  /// 时间选择行
  ///
  /// [context] 上下文
  Widget _buildTimePicker(BuildContext context)
  {
    return Obx(
      ()
      {
        return Row(
          children: <Widget>
          [
            Text(
              '*${StringConstants.EDIT_TIME}',
              style: TextStyle(fontSize: UIConstants.FONT_SM, color: UIConstants.COLOR_TEXT_ON_LIGHT),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => _pickDateTime(context),
              child: Text(DateUtil.formatDate(controller.measuredAt.value)),
            ),
          ],
        );
      },
    );
  }

  /// 备注输入
  Widget _buildRemark()
  {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>
      [
        Padding(
          padding: const EdgeInsets.only(top: UIConstants.PADDING_MD),
          child: Text(
            StringConstants.EDIT_REMARK,
            style: TextStyle(fontSize: UIConstants.FONT_SM, color: UIConstants.COLOR_TEXT_ON_LIGHT),
          ),
        ),
        const SizedBox(width: UIConstants.PADDING_MD),
        Expanded(
          child: TextField(
            controller: controller.remarkController,
            maxLength: NumberConstants.MAX_REMARK_LENGTH,
            maxLines: 2,
            decoration: const InputDecoration(isDense: true),
          ),
        ),
      ],
    );
  }

  /// 弹出时间选择
  ///
  /// [context] 上下文
  Future<void> _pickDateTime(BuildContext context) async
  {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.measuredAt.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked == null)
    {
      return;
    }
    controller.selectTime(
      DateTime(picked.year, picked.month, picked.day, DateTime.now().hour, DateTime.now().minute),
    );
  }

  /// 处理返回拦截
  ///
  /// [didPop] 是否已执行返回
  Future<void> _handlePop(bool didPop) async
  {
    if (didPop)
    {
      return;
    }
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        content: const Text(StringConstants.EDIT_LEAVE_CONFIRM),
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
    if (confirmed == true)
    {
      Get.back();
    }
  }
}
