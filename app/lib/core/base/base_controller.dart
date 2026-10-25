import 'package:get/get.dart';

import '../api/api_exception.dart';

/// 控制器基类
///
/// 功能说明: 统一封装加载态、错误态与任务执行，避免业务 Controller 重复样板代码
/// 时间: 2026-10-25
/// 作者: zhengchaojun
abstract class BaseController extends GetxController
{
  /// 加载状态
  final RxBool isLoading = false.obs;

  /// 错误提示，空字符串表示无错误
  final RxString errorMessage = ''.obs;

  /// 是否处于错误态
  bool get hasError => errorMessage.value.isNotEmpty;

  /// 执行异步任务
  ///
  /// [task] 具体业务逻辑
  /// [showLoading] 是否展示加载态，默认展示
  Future<void> runTask(Future<void> Function() task, {bool showLoading = true}) async
  {
    if (showLoading)
    {
      isLoading.value = true;
    }
    errorMessage.value = '';
    try
    {
      await task();
    }
    on ApiException catch (error)
    {
      errorMessage.value = error.message;
    }
    catch (error)
    {
      errorMessage.value = error.toString();
    }
    finally
    {
      isLoading.value = false;
    }
  }

  /// 清空错误态
  void clearError()
  {
    errorMessage.value = '';
  }

  /// 重试当前任务
  ///
  /// [task] 需要重新执行的业务逻辑
  Future<void> retry(Future<void> Function() task) async
  {
    await runTask(task);
  }
}
