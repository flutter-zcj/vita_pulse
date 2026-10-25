import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../constant/route_constant.dart';
import '../../../core/base/base_controller.dart';

/// 测量准备页控制器
///
/// 功能说明: 校验相机权限并处理申请流程，权限就绪后进入检测页
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class PrepareController extends BaseController
{
  /// 是否已获得相机权限
  final RxBool permissionGranted = false.obs;

  /// 是否被永久拒绝
  final RxBool permanentlyDenied = false.obs;

  @override
  void onInit()
  {
    super.onInit();
    checkPermission();
  }

  /// 检查相机权限
  ///
  /// 未授权时自动发起一次申请
  Future<void> checkPermission() async
  {
    await runTask(
      () async
      {
        final status = await Permission.camera.status;
        if (status.isGranted)
        {
          permissionGranted.value = true;
          permanentlyDenied.value = false;
          return;
        }
        if (status.isPermanentlyDenied)
        {
          permissionGranted.value = false;
          permanentlyDenied.value = true;
          return;
        }
        final requested = await Permission.camera.request();
        permissionGranted.value = requested.isGranted;
        permanentlyDenied.value = requested.isPermanentlyDenied;
      },
      showLoading: false,
    );
  }

  /// 打开系统设置页
  Future<void> openSettings() async
  {
    await openAppSettings();
  }

  /// 进入检测页
  void startMeasure()
  {
    if (!permissionGranted.value)
    {
      return;
    }
    Get.toNamed(RouteConstants.MEASURE_RUNNING);
  }

  /// 改用手动录入
  void goManual()
  {
    Get.offNamed(RouteConstants.RECORD_EDIT);
  }
}
