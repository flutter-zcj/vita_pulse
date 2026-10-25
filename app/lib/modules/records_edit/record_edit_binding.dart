import 'package:get/get.dart';

import 'controller/record_edit_controller.dart';

/// 手动录入绑定
///
/// 功能说明: 注入手动录入控制器
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class RecordEditBinding extends Bindings
{
  @override
  void dependencies()
  {
    Get.lazyPut<RecordEditController>(() => RecordEditController());
  }
}
