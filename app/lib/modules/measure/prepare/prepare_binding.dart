import 'package:get/get.dart';

import 'controller/prepare_controller.dart';

/// 测量准备页绑定
///
/// 功能说明: 注入准备页控制器
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class PrepareBinding extends Bindings
{
  @override
  void dependencies()
  {
    Get.lazyPut<PrepareController>(() => PrepareController());
  }
}
