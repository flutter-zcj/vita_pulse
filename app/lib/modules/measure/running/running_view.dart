import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constant/num_constant.dart';
import '../../../constant/str_constant.dart';
import '../../../constant/ui_constant.dart';
import '../../../widgets/primary_button.dart';
import 'controller/running_controller.dart';

/// 检测进行中页面
///
/// 功能说明: 展示倒计时圆环、实时波形与取消入口
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class RunningView extends GetView<RunningController>
{
  /// 构造函数
  const RunningView({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: UIConstants.COLOR_BG_DEEP,
      appBar: AppBar(title: const Text(StringConstants.TITLE_MEASURE_RUNNING)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: UIConstants.PADDING_XL),
        child: Column(
          children: <Widget>
          [
            const SizedBox(height: UIConstants.PADDING_LG),
            Text(
              StringConstants.RUNNING_SUBTITLE,
              style: TextStyle(
                fontSize: UIConstants.FONT_SM,
                color: UIConstants.COLOR_TEXT_ON_DARK_SUB,
              ),
            ),
            const SizedBox(height: UIConstants.PADDING_XXL),
            _buildCountdown(),
            const SizedBox(height: UIConstants.PADDING_XXL),
            _buildWaveCard(),
            const Spacer(),
            if (controller.noFinger.value)
              Padding(
                padding: const EdgeInsets.only(bottom: UIConstants.PADDING_MD),
                child: Text(
                  StringConstants.RUNNING_NO_FINGER,
                  style: TextStyle(fontSize: UIConstants.FONT_XS, color: UIConstants.COLOR_WARNING),
                ),
              ),
            PrimaryButton(
              text: StringConstants.RUNNING_CANCEL,
              outlined: true,
              onDark: true,
              onPressed: controller.cancel,
            ),
            const SizedBox(height: UIConstants.PADDING_XL),
          ],
        ),
      ),
    );
  }

  /// 构建倒计时圆环
  Widget _buildCountdown()
  {
    return Obx(
      ()
      {
        final ratio = controller.remainingSec.value / NumberConstants.MEASURE_DURATION_SEC;
        return SizedBox(
          width: UIConstants.CIRCLE_SIZE,
          height: UIConstants.CIRCLE_SIZE,
          child: CustomPaint(
            painter: _ProgressRingPainter(ratio),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>
                [
                  Text(
                    '${controller.remainingSec.value}',
                    style: TextStyle(
                      fontSize: UIConstants.FONT_DISPLAY,
                      fontWeight: FontWeight.w300,
                      color: UIConstants.COLOR_ACCENT,
                    ),
                  ),
                  Text(
                    StringConstants.RUNNING_UNIT_SECOND,
                    style: TextStyle(
                      fontSize: UIConstants.FONT_SM,
                      color: UIConstants.COLOR_TEXT_ON_DARK_SUB,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建波形卡片
  Widget _buildWaveCard()
  {
    return Container(
      padding: const EdgeInsets.all(UIConstants.PADDING_DEFAULT),
      decoration: BoxDecoration(
        color: UIConstants.COLOR_SURFACE_DARK,
        borderRadius: BorderRadius.circular(UIConstants.RADIUS_LG),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>
        [
          Row(
            children: <Widget>
            [
              Expanded(
                child: Text(
                  StringConstants.RUNNING_WAVE_TITLE,
                  style: TextStyle(
                    fontSize: UIConstants.FONT_SM,
                    color: UIConstants.COLOR_TEXT_ON_DARK_SUB,
                  ),
                ),
              ),
              Obx(
                ()
                {
                  final value = controller.liveHeartRate.value;
                  if (value == null)
                  {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    '${value.toStringAsFixed(0)} bpm',
                    style: TextStyle(fontSize: UIConstants.FONT_SM, color: UIConstants.COLOR_ACCENT),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: UIConstants.PADDING_MD),
          SizedBox(
            height: UIConstants.WAVE_HEIGHT,
            child: Obx(
              ()
              {
                final values = controller.waveform;
                if (values.length < 2)
                {
                  return const SizedBox.shrink();
                }
                return CustomPaint(
                  painter: _WavePainter(values.toList()),
                  size: Size.infinite,
                );
              },
            ),
          ),
          if (controller.weakSignal.value)
            Padding(
              padding: const EdgeInsets.only(top: UIConstants.PADDING_SM),
              child: Text(
                StringConstants.RUNNING_WEAK_SIGNAL,
                style: TextStyle(fontSize: UIConstants.FONT_XS, color: UIConstants.COLOR_WARNING),
              ),
            ),
        ],
      ),
    );
  }
}

/// 倒计时进度环
///
/// 功能说明: 按剩余比例绘制弧形进度
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class _ProgressRingPainter extends CustomPainter
{
  /// 剩余比例，0-1
  final double ratio;

  /// 构造函数
  _ProgressRingPainter(this.ratio);

  @override
  void paint(Canvas canvas, Size size)
  {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - UIConstants.PROGRESS_STROKE;
    final background = Paint()
      ..color = UIConstants.COLOR_ACCENT_DIM.withOpacity(UIConstants.OPACITY_DISABLED)
      ..strokeWidth = UIConstants.PROGRESS_STROKE
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, background);

    final foreground = Paint()
      ..color = UIConstants.COLOR_ACCENT
      ..strokeWidth = UIConstants.PROGRESS_STROKE
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final sweep = 2 * 3.1415926 * ratio.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.1415926 / 2,
      sweep,
      false,
      foreground,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate)
  {
    return oldDelegate.ratio != ratio;
  }
}

/// 实时波形绘制
///
/// 功能说明: 逐帧绘制归一化脉搏波
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class _WavePainter extends CustomPainter
{
  /// 波形数据，取值 0-1
  final List<double> values;

  /// 构造函数
  _WavePainter(this.values);

  @override
  void paint(Canvas canvas, Size size)
  {
    if (values.length < 2)
    {
      return;
    }
    final paint = Paint()
      ..color = UIConstants.COLOR_ACCENT
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path();
    for (var index = 0; index < values.length; index++)
    {
      final dx = size.width * index / (values.length - 1);
      final dy = size.height * (1 - values[index]);
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
  bool shouldRepaint(covariant _WavePainter oldDelegate)
  {
    return true;
  }
}
