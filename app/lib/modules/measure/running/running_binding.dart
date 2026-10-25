import 'package:get/get.dart';

import 'controller/running_controller.dart';

/// 检测进行中绑定
///
/// 功能说明: 注入检测页控制器，页面销毁时同步释放相机
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class RunningBinding extends Bindings
{
  @override
  void dependencies()
  {
    Get.lazyPut<RunningController>(() => RunningController());
  }
}
