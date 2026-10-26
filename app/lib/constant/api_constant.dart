/// API 接口常量
///
/// 功能说明: 统一管理后端基础地址与接口路径，路径与 RuoYi-FastAPI 底座保持一致
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class ApiConstants
{
  // ---- 基础地址 ----
  /// 默认服务地址，可通过 --dart-define=API_BASE_URL=xxx 在构建时覆盖
  static const String DEFAULT_BASE_URL = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.2.105:9099',
  );

  // ---- 认证（底座自带）----
  static const String LOGIN = '/login';
  static const String LOGOUT = '/logout';
  static const String USER_INFO = '/getInfo';
  static const String HEALTH = '/health';

  // ---- 指标字典 ----
  static const String METRIC_LIST = '/vital/metric/list';

  // ---- 体征记录 ----
  static const String RECORD = '/vital/record';
  static const String RECORD_BATCH = '/vital/record/batch';
  static const String RECORD_LIST = '/vital/record/list';
  static const String RECORD_LATEST = '/vital/record/latest';
  static const String RECORD_STAT = '/vital/record/stat';

  // ---- 预警 ----
  static const String ALERT_RULE = '/vital/alertRule';
  static const String ALERT_EVENT_LIST = '/vital/alertEvent/list';
  static const String ALERT_EVENT_ACK = '/vital/alertEvent/ack';

  // ---- 请求字段 ----
  static const String FIELD_USERNAME = 'username';
  static const String FIELD_PASSWORD = 'password';
  static const String FIELD_GRANT_TYPE = 'grant_type';
  static const String FIELD_GRANT_PASSWORD = 'password';
  static const String FIELD_CODE = 'code';
  static const String FIELD_UUID = 'uuid';
  static const String FIELD_TOKEN = 'token';
  static const String FIELD_CODE_STATUS = 'code';
  static const String FIELD_MSG = 'msg';
  static const String FIELD_DATA = 'data';
  static const String FIELD_ROWS = 'rows';
  static const String FIELD_TOTAL = 'total';

  // ---- 请求头 ----
  static const String HEADER_AUTHORIZATION = 'Authorization';
  static const String HEADER_BEARER = 'Bearer ';
  static const String HEADER_CONTENT_TYPE = 'Content-Type';
  static const String CONTENT_TYPE_FORM = 'application/x-www-form-urlencoded';

  // ---- 业务字段 ----
  static const String PARAM_PAGE_NUM = 'pageNum';
  static const String PARAM_PAGE_SIZE = 'pageSize';
  static const String PARAM_METRIC = 'metric';
  static const String PARAM_START_TIME = 'startTime';
  static const String PARAM_END_TIME = 'endTime';
  static const String PARAM_PERIOD = 'period';

  // ---- 状态码 ----
  static const int SUCCESS_CODE = 200;
  static const int UNAUTHORIZED_CODE = 401;

  // ---- 演示账号（App 无登录页，启动时静默登录）----
  static const String DEMO_USERNAME = 'admin';
  static const String DEMO_PASSWORD = 'admin123';
}
