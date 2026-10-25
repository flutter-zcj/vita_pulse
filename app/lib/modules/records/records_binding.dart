import 'package:get/get.dart';

import 'controller/records_controller.dart';

/// 记录列表绑定
///
/// 功能说明: 注入记录列表控制器
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class RecordsBinding extends Bindings
{
  @override
  void dependencies()
  {
    Get.lazyPut<RecordsController>(() => RecordsController());
  }
}
