import 'package:get/get.dart';

import 'controller/trends_controller.dart';

/// 趋势分析绑定
///
/// 功能说明: 注入趋势分析控制器
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class TrendsBinding extends Bindings
{
  @override
  void dependencies()
  {
    Get.lazyPut<TrendsController>(() => TrendsController());
  }
}
