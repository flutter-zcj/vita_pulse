import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constant/route_constant.dart';
import '../../../constant/sp_key_constant.dart';
import '../../../constant/str_constant.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/token_store.dart';
import '../../../core/base/base_controller.dart';

/// 设置页控制器
///
/// 功能说明: 管理外观模式与服务地址，仅这两项允许本地持久化
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class SettingsController extends BaseController
{
  /// 网络客户端
  final ApiClient _client = Get.find<ApiClient>();

  /// 偏好存储
  final TokenStore _store = TokenStore();

  /// 外观模式
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  /// 服务地址
  final RxString serverAddress = ''.obs;

  /// 测量提醒开关
  final RxBool remindEnabled = true.obs;

  @override
  void onInit()
  {
    super.onInit();
    _restore();
  }

  /// 恢复本地偏好
  Future<void> _restore() async
  {
    serverAddress.value = _client.baseUrl;
    final savedTheme = await _store.readValue(SPKeyConstants.KEY_THEME_MODE);
    themeMode.value = _parseTheme(savedTheme);
    final remind = await _store.readValue(SPKeyConstants.KEY_REMIND_ENABLED);
    remindEnabled.value = remind != '0';
  }

  /// 切换外观模式
  ///
  /// [mode] 目标模式
  Future<void> changeTheme(ThemeMode mode) async
  {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    await _store.writeValue(SPKeyConstants.KEY_THEME_MODE, mode.name);
  }

  /// 切换测量提醒
  ///
  /// [enabled] 是否开启
  Future<void> toggleRemind(bool enabled) async
  {
    remindEnabled.value = enabled;
    await _store.writeValue(SPKeyConstants.KEY_REMIND_ENABLED, enabled ? '1' : '0');
  }

  /// 测试服务连通性
  ///
  /// [address] 目标地址
  Future<bool> testConnection(String address) async
  {
    final valid = address.startsWith('http://') || address.startsWith('https://');
    if (!valid)
    {
      return false;
    }
    return _client.testConnection(address);
  }

  /// 保存服务地址
  ///
  /// [address] 新地址
  /// 返回 true 表示切换成功
  Future<bool> saveServerAddress(String address) async
  {
    final reachable = await testConnection(address);
    if (!reachable)
    {
      Get.snackbar(StringConstants.SETTING_SERVER_FAILED, StringConstants.SETTING_SERVER_TIMEOUT);
      return false;
    }
    await _client.changeBaseUrl(address);
    serverAddress.value = address;
    Get.snackbar(StringConstants.SETTING_SERVER_OK, StringConstants.SETTING_SERVER_OK);
    return true;
  }

  /// 打开阈值设置页
  void goAlerts()
  {
    Get.toNamed(RouteConstants.ALERTS);
  }

  /// 解析主题模式
  ///
  /// [value] 存储值
  ThemeMode _parseTheme(String value)
  {
    if (value == ThemeMode.light.name)
    {
      return ThemeMode.light;
    }
    if (value == ThemeMode.dark.name)
    {
      return ThemeMode.dark;
    }
    return ThemeMode.system;
  }
}
