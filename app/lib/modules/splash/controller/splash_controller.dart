import 'package:get/get.dart';

import '../../../constant/route_constant.dart';
import '../../../core/api/api_client.dart';
import '../../../core/base/base_controller.dart';

/// 启动页控制器
///
/// 功能说明: 完成静默登录与指标字典预热，成功后进入首页
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class SplashController extends BaseController
{
  /// 网络客户端
  final ApiClient _client = Get.find<ApiClient>();

  @override
  void onInit()
  {
    super.onInit();
    bootstrap();
  }

  /// 初始化流程
  ///
  /// 静默获取令牌后跳转首页，失败时保留错误态供用户重试
  Future<void> bootstrap() async
  {
    await runTask(
      () async
      {
        if (!_client.hasToken)
        {
          await _client.silentLogin();
        }
        Get.offAllNamed(RouteConstants.HOME);
      },
    );
  }
}
