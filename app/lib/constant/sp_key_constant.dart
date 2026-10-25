/// 本地偏好存储键名常量
///
/// 功能说明: 统一管理 secure storage 与本地偏好键名，业务数据不落本地
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class SPKeyConstants
{
  // ---- 安全存储 ----
  static const String KEY_ACCESS_TOKEN = 'access_token';
  static const String KEY_TOKEN_TIME = 'access_token_time';

  // ---- 用户偏好 ----
  static const String KEY_BASE_URL = 'base_url';
  static const String KEY_THEME_MODE = 'theme_mode';
  static const String KEY_REMIND_ENABLED = 'remind_enabled';
}
