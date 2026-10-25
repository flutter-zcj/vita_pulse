import 'package:get/get.dart';

import 'controller/alerts_controller.dart';

/// 预警阈值绑定
///
/// 功能说明: 注入阈值控制器
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class AlertsBinding extends Bindings
{
  @override
  void dependencies()
  {
    Get.lazyPut<AlertsController>(() => AlertsController());
  }
}
