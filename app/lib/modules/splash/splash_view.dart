import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/str_constant.dart';
import '../../constant/ui_constant.dart';
import 'controller/splash_controller.dart';

/// 启动页
///
/// 功能说明: 初始化网络客户端与仓储，静默完成身份获取后进入首页
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class SplashView extends GetView<SplashController>
{
  /// 构造函数
  const SplashView({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: UIConstants.COLOR_BG_DEEP,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>
          [
            const Text(
              StringConstants.TIP_LOADING,
              style: TextStyle(
                fontSize: UIConstants.FONT_SM,
                color: UIConstants.COLOR_TEXT_ON_DARK_SUB,
              ),
            ),
            const SizedBox(height: UIConstants.PADDING_LG),
            Obx(
              ()
              {
                if (!controller.hasError)
                {
                  return const SizedBox(
                    width: UIConstants.ICON_LG,
                    height: UIConstants.ICON_LG,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                return Column(
                  children: <Widget>
                  [
                    Text(
                      controller.errorMessage.value,
                      style: const TextStyle(
                        fontSize: UIConstants.FONT_SM,
                        color: UIConstants.COLOR_TEXT_ON_DARK_SUB,
                      ),
                    ),
                    const SizedBox(height: UIConstants.PADDING_MD),
                    TextButton(
                      onPressed: controller.bootstrap,
                      child: const Text(StringConstants.BTN_RETRY),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
