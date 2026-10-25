import 'package:get/get.dart';

import 'controller/home_controller.dart';

/// 首页绑定
///
/// 功能说明: 注入首页控制器
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class HomeBinding extends Bindings
{
  @override
  void dependencies()
  {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
