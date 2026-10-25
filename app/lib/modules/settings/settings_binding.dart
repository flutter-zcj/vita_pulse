import 'package:get/get.dart';

import 'controller/settings_controller.dart';

/// 设置页绑定
///
/// 功能说明: 注入设置页控制器
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class SettingsBinding extends Bindings
{
  @override
  void dependencies()
  {
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
