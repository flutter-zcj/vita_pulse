import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constant/str_constant.dart';
import '../../../constant/ui_constant.dart';
import '../../../widgets/primary_button.dart';
import 'controller/prepare_controller.dart';

/// 测量准备页
///
/// 功能说明: 展示测量要点与示意区域，权限就绪后允许开始检测
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class PrepareView extends GetView<PrepareController>
{
  /// 构造函数
  const PrepareView({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: UIConstants.COLOR_BG_DEEP,
      appBar: AppBar(
        title: const Text(StringConstants.TITLE_MEASURE_PREPARE),
      ),
      body: Obx(
        ()
        {
          if (!controller.permissionGranted.value)
          {
            return _buildPermissionHint();
          }
          return _buildContent();
        },
      ),
    );
  }

  /// 构建权限提示
  Widget _buildPermissionHint()
  {
    return Padding(
      padding: const EdgeInsets.all(UIConstants.PADDING_XL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>
        [
          const Icon(
            Icons.no_photography_outlined,
            size: UIConstants.ICON_XL,
            color: UIConstants.COLOR_TEXT_ON_DARK_SUB,
          ),
          const SizedBox(height: UIConstants.PADDING_LG),
          Text(
            controller.permanentlyDenied.value
                ? StringConstants.PREPARE_PERMISSION_DENIED
                : StringConstants.PREPARE_PERMISSION_TITLE,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: UIConstants.FONT_SM,
              color: UIConstants.COLOR_TEXT_ON_DARK_SUB,
            ),
          ),
          const SizedBox(height: UIConstants.PADDING_LG),
          PrimaryButton(
            text: StringConstants.PREPARE_GO_SETTING,
            outlined: true,
            onDark: true,
            onPressed: controller.openSettings,
          ),
          const SizedBox(height: UIConstants.PADDING_MD),
          TextButton(
            onPressed: controller.goManual,
            child: const Text(
              StringConstants.PREPARE_USE_MANUAL,
              style: TextStyle(color: UIConstants.COLOR_ACCENT),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建准备内容
  Widget _buildContent()
  {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UIConstants.PADDING_XL),
      child: Column(
        children: <Widget>
        [
          const SizedBox(height: UIConstants.PADDING_LG),
          const Text(
            StringConstants.PREPARE_SUBTITLE,
            style: TextStyle(
              fontSize: UIConstants.FONT_SM,
              color: UIConstants.COLOR_TEXT_ON_DARK_SUB,
            ),
          ),
          const SizedBox(height: UIConstants.PADDING_XXL),
          SizedBox(
            height: UIConstants.CIRCLE_SIZE,
            child: CustomPaint(
              painter: _DashedOvalPainter(),
              child: const Center(
                child: Icon(
                  Icons.accessibility_new,
                  size: UIConstants.ICON_XL * 2,
                  color: UIConstants.COLOR_ACCENT,
                ),
              ),
            ),
          ),
          const SizedBox(height: UIConstants.PADDING_XXL),
          _buildTip(StringConstants.PREPARE_TIP_LIGHT),
          _buildTip(StringConstants.PREPARE_TIP_STABLE),
          _buildTip(StringConstants.PREPARE_TIP_STILL),
          const Spacer(),
          PrimaryButton(
            text: StringConstants.PREPARE_START,
            onDark: true,
            onPressed: controller.startMeasure,
          ),
          const SizedBox(height: UIConstants.PADDING_LG),
          const Text(
            StringConstants.DISCLAIMER,
            style: TextStyle(
              fontSize: UIConstants.FONT_XS,
              color: UIConstants.COLOR_TEXT_ON_DARK_SUB,
            ),
          ),
          const SizedBox(height: UIConstants.PADDING_XL),
        ],
      ),
    );
  }

  /// 构建单条要点
  ///
  /// [text] 要点文案
  Widget _buildTip(String text)
  {
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.PADDING_MD),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>
        [
          Container(
            margin: const EdgeInsets.only(top: UIConstants.PADDING_SM),
            width: UIConstants.PADDING_SM / 2,
            height: UIConstants.PADDING_SM / 2,
            decoration: const BoxDecoration(
              color: UIConstants.COLOR_ACCENT,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: UIConstants.PADDING_MD),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: UIConstants.FONT_SM,
                color: UIConstants.COLOR_TEXT_ON_DARK,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 虚线椭圆绘制
///
/// 功能说明: 绘制测量示意区域的虚线轮廓
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class _DashedOvalPainter extends CustomPainter
{
  @override
  void paint(Canvas canvas, Size size)
  {
    final paint = Paint()
      ..color = UIConstants.COLOR_ACCENT_DIM
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final rect = Rect.fromLTWH(
      UIConstants.PADDING_MD,
      UIConstants.PADDING_MD,
      size.width - UIConstants.PADDING_XL,
      size.height - UIConstants.PADDING_XL,
    );
    const segment = 12.0;
    final path = Path()..addOval(rect);
    for (final metric in path.computeMetrics())
    {
      var distance = 0.0;
      while (distance < metric.length)
      {
        final next = distance + segment;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + segment;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate)
  {
    return false;
  }
}
