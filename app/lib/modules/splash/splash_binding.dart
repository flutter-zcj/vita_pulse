import 'package:get/get.dart';

import 'controller/splash_controller.dart';

/// 启动页绑定
///
/// 功能说明: 注入启动页控制器
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class SplashBinding extends Bindings
{
  @override
  void dependencies()
  {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}
