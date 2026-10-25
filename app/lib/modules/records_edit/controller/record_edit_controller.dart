import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constant/num_constant.dart';
import '../../../constant/str_constant.dart';
import '../../../core/base/base_controller.dart';
import '../../../data/models/vital_metric.dart';
import '../../../data/models/vital_record.dart';
import '../../../data/repositories/vital_repository.dart';

/// 手动录入控制器
///
/// 功能说明: 处理指标切换、数值校验与记录提交，血压场景写入两条记录
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class RecordEditController extends BaseController
{
  /// 体征仓储
  final VitalRepository _repository = Get.find<VitalRepository>();

  /// 指标字典
  final RxList<VitalMetric> metrics = <VitalMetric>[].obs;

  /// 当前选中指标
  final Rxn<VitalMetric> selectedMetric = Rxn<VitalMetric>();

  /// 数值输入控制器
  final TextEditingController valueController = TextEditingController();

  /// 收缩压输入控制器
  final TextEditingController systolicController = TextEditingController();

  /// 舒张压输入控制器
  final TextEditingController diastolicController = TextEditingController();

  /// 备注输入控制器
  final TextEditingController remarkController = TextEditingController();

  /// 测量时间
  final Rx<DateTime> measuredAt = DateTime.now().obs;

  /// 数值错误提示
  final RxString valueError = ''.obs;

  /// 提交中状态
  final RxBool submitting = false.obs;

  /// 是否已修改过内容
  bool _dirty = false;

  @override
  void onInit()
  {
    super.onInit();
    _loadMetrics();
    valueController.addListener(_markDirty);
    systolicController.addListener(_markDirty);
    diastolicController.addListener(_markDirty);
    remarkController.addListener(_markDirty);
  }

  /// 加载指标字典
  Future<void> _loadMetrics() async
  {
    await runTask(
      () async
      {
        final loaded = await _repository.loadMetrics();
        metrics.assignAll(loaded);
        if (loaded.isNotEmpty)
        {
          selectedMetric.value = loaded.firstWhere(
            (item) => item.metricCode == StringConstants.METRIC_SPO2,
            orElse: () => loaded.first,
          );
        }
      },
    );
  }

  /// 切换指标
  ///
  /// [metric] 目标指标
  void selectMetric(VitalMetric metric)
  {
    selectedMetric.value = metric;
    valueController.clear();
    systolicController.clear();
    diastolicController.clear();
    valueError.value = '';
    _dirty = true;
  }

  /// 选择测量时间
  ///
  /// [time] 目标时间
  void selectTime(DateTime time)
  {
    measuredAt.value = time;
    _dirty = true;
  }

  /// 是否允许提交
  bool get canSubmit
  {
    final metric = selectedMetric.value;
    if (metric == null)
    {
      return false;
    }
    if (metric.isDual)
    {
      return systolicController.text.isNotEmpty && diastolicController.text.isNotEmpty;
    }
    return valueController.text.isNotEmpty;
  }

  /// 提交流程
  Future<void> submit() async
  {
    final metric = selectedMetric.value;
    if (metric == null)
    {
      return;
    }
    if (!_validate(metric))
    {
      return;
    }
    submitting.value = true;
    await runTask(
      () async
      {
        final records = _buildRecords(metric);
        if (records.length == 1)
        {
          await _repository.saveRecord(records.first);
        }
        else
        {
          await _repository.saveMeasure(records);
        }
        Get.snackbar(StringConstants.TIP_SAVE_SUCCESS, StringConstants.TIP_SAVE_SUCCESS);
        Get.back();
      },
      showLoading: false,
    );
    submitting.value = false;
  }

  /// 是否有未保存内容
  bool get isDirty => _dirty;

  /// 构造待写入记录
  ///
  /// [metric] 当前指标
  List<VitalRecord> _buildRecords(VitalMetric metric)
  {
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    if (metric.isDual)
    {
      return <VitalRecord>
      [
        _buildRecord(metric, StringConstants.METRIC_SYSTOLIC, _parse(systolicController.text), 'mmHg', sessionId),
        _buildRecord(metric, StringConstants.METRIC_DIASTOLIC, _parse(diastolicController.text), 'mmHg', sessionId),
      ];
    }
    return <VitalRecord>
    [
      _buildRecord(metric, metric.metricCode, _parse(valueController.text), metric.unit, sessionId),
    ];
  }

  /// 构造单条记录
  ///
  /// [metric] 指标
  /// [code] 指标编码
  /// [value] 数值
  /// [unit] 单位
  /// [sessionId] 会话编号
  VitalRecord _buildRecord(VitalMetric metric, String code, double value, String unit, String sessionId)
  {
    return VitalRecord(
      recordId: '$sessionId-$code',
      metric: code,
      value: value,
      unit: unit,
      measuredAt: measuredAt.value,
      source: 'manual',
      sessionId: sessionId,
      remark: remarkController.text,
    );
  }

  /// 校验输入
  ///
  /// [metric] 当前指标
  bool _validate(VitalMetric metric)
  {
    if (measuredAt.value.isAfter(DateTime.now()))
    {
      valueError.value = StringConstants.EDIT_TIME_FUTURE;
      selectTime(DateTime.now());
      return false;
    }
    if (metric.isDual)
    {
      final systolic = _parse(systolicController.text);
      final diastolic = _parse(diastolicController.text);
      if (systolic < NumberConstants.SYSTOLIC_MIN || systolic > NumberConstants.SYSTOLIC_MAX)
      {
        valueError.value = StringConstants.EDIT_OUT_OF_RANGE;
        return false;
      }
      if (diastolic < NumberConstants.DIASTOLIC_MIN || diastolic > NumberConstants.DIASTOLIC_MAX)
      {
        valueError.value = StringConstants.EDIT_OUT_OF_RANGE;
        return false;
      }
      valueError.value = '';
      return true;
    }
    final value = _parse(valueController.text);
    if (valueController.text.isEmpty)
    {
      valueError.value = StringConstants.EDIT_EMPTY_VALUE;
      return false;
    }
    final bounds = _rangeOf(metric.metricCode);
    if (value < bounds[0] || value > bounds[1])
    {
      valueError.value = StringConstants.EDIT_OUT_OF_RANGE;
      return false;
    }
    valueError.value = '';
    return true;
  }

  /// 指标合理区间
  ///
  /// [code] 指标编码
  List<double> _rangeOf(String code)
  {
    switch (code)
    {
      case StringConstants.METRIC_HEART_RATE:
        return <double>[NumberConstants.HR_MIN, NumberConstants.HR_MAX];
      case StringConstants.METRIC_SPO2:
        return <double>[NumberConstants.SPO2_MIN, NumberConstants.SPO2_MAX];
      case StringConstants.METRIC_TEMPERATURE:
        return <double>[NumberConstants.TEMPERATURE_MIN, NumberConstants.TEMPERATURE_MAX];
      case StringConstants.METRIC_WEIGHT:
        return <double>[NumberConstants.WEIGHT_MIN, NumberConstants.WEIGHT_MAX];
      case StringConstants.METRIC_RESP_RATE:
        return <double>[NumberConstants.RESP_MIN, NumberConstants.RESP_MAX];
      default:
        return <double>[NumberConstants.ZERO, NumberConstants.HUNDRED];
    }
  }

  /// 解析数字
  ///
  /// [text] 输入文本
  double _parse(String text)
  {
    return double.tryParse(text) ?? 0;
  }

  /// 标记内容已修改
  void _markDirty()
  {
    _dirty = true;
  }

  @override
  void onClose()
  {
    valueController.dispose();
    systolicController.dispose();
    diastolicController.dispose();
    remarkController.dispose();
    super.onClose();
  }
}
