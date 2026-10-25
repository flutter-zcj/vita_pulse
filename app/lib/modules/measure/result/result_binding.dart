import 'package:get/get.dart';

import 'controller/result_controller.dart';

/// 检测结果页绑定
///
/// 功能说明: 注入结果页控制器
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class ResultBinding extends Bindings
{
  @override
  void dependencies()
  {
    Get.lazyPut<ResultController>(() => ResultController());
  }
}
