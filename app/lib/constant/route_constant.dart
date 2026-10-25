/// 路由与路由参数常量
///
/// 功能说明: 统一管理 GetX 路由路径与页面间传参键名
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class RouteConstants
{
  // ---- 路由路径 ----
  static const String SPLASH = '/splash';
  static const String HOME = '/home';
  static const String MEASURE_PREPARE = '/measure/prepare';
  static const String MEASURE_RUNNING = '/measure/running';
  static const String MEASURE_RESULT = '/measure/result';
  static const String RECORDS = '/records';
  static const String RECORD_EDIT = '/records/edit';
  static const String TRENDS = '/trends';
  static const String ALERTS = '/alerts';
  static const String SETTINGS = '/settings';

  // ---- 路由参数键 ----
  static const String ARG_METRIC = 'metric';
  static const String ARG_MEASURE_RESULT = 'measureResult';
  static const String ARG_FOCUS_TIME = 'focusTime';
}
