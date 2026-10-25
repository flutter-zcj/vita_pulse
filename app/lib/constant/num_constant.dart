/// 数字常量
///
/// 功能说明: 统一管理超时时间、长度限制、分页参数与业务阈值
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class NumberConstants
{
  // ---- 网络相关 ----
  static const int CONNECT_TIMEOUT_MS = 8000;
  static const int RECEIVE_TIMEOUT_MS = 8000;
  static const int MAX_RETRY_COUNT = 1;

  // ---- 分页相关 ----
  static const int PAGE_SIZE_DEFAULT = 20;
  static const int FIRST_PAGE_INDEX = 1;

  // ---- 底部导航索引 ----
  static const int TAB_INDEX_HOME = 0;
  static const int TAB_INDEX_RECORDS = 1;
  static const int TAB_INDEX_TRENDS = 2;
  static const int TAB_INDEX_SETTINGS = 3;
  static const int LOAD_MORE_THRESHOLD = 200;

  // ---- 测量相关 ----
  static const int MEASURE_DURATION_SEC = 30;
  static const int MEASURE_MIN_VALID_SEC = 15;
  static const int MEASURE_TICK_MS = 1000;
  static const int FRAME_RATE_TARGET = 30;
  static const int FRAME_RATE_ACCEPTABLE = 20;
  static const int FFT_WINDOW_SIZE = 1024;
  static const double BANDPASS_LOW_HZ = 0.7;
  static const double BANDPASS_HIGH_HZ = 3.0;
  static const double RESP_LOW_HZ = 0.1;
  static const double RESP_HIGH_HZ = 0.5;
  static const double SQI_THRESHOLD = 0.35;
  static const double DETREND_WINDOW_SEC = 1.0;
  static const int NO_FINGER_FRAMES = 90;
  static const double MIN_BRIGHTNESS = 30.0;
  static const double MAX_BRIGHTNESS = 250.0;
  static const double ROI_SCALE = 0.4;

  // ---- 业务阈值 ----
  static const double HR_MIN = 30.0;
  static const double HR_MAX = 220.0;
  static const double SPO2_MIN = 70.0;
  static const double SPO2_MAX = 100.0;
  static const double TEMPERATURE_MIN = 34.0;
  static const double TEMPERATURE_MAX = 42.0;
  static const double WEIGHT_MIN = 20.0;
  static const double WEIGHT_MAX = 300.0;
  static const double RESP_MIN = 5.0;
  static const double RESP_MAX = 60.0;
  static const double SYSTOLIC_MIN = 60.0;
  static const double SYSTOLIC_MAX = 260.0;
  static const double DIASTOLIC_MIN = 30.0;
  static const double DIASTOLIC_MAX = 180.0;
  static const double COMFORT_MIN = 0.0;
  static const double COMFORT_MAX = 100.0;
  static const double RMSSD_VERY_LOW = 20.0;
  static const double RMSSD_LOW = 30.0;
  static const double RMSSD_MIDDLE = 45.0;
  static const double RMSSD_HIGH = 60.0;
  static const double RESTING_RMSSD_BASE = 55.0;
  static const double RESTING_HR_DEFAULT = 72.0;
  static const int CHART_DOT_MAX_POINTS = 10;
  static const double COMFORT_HR_FACTOR = 1.2;
  static const double COMFORT_RMSSD_FACTOR = 1.5;
  static const double COMFORT_DIVISOR = 2.0;

  // ---- 时间相关 ----
  static const int HOURS_PER_DAY = 24;
  static const int STALE_SPO2_DAYS = 30;
  static const int TREND_DAYS_SHORT = 7;
  static const int TREND_DAYS_MIDDLE = 30;
  static const int TREND_DAYS_LONG = 90;
  static const int TREND_MAX_LABELS = 7;
  static const int WEEK_AGGREGATE_DAYS = 7;

  // ---- 校验相关 ----
  static const int MAX_REMARK_LENGTH = 140;
  static const int DEBOUNCE_MS = 300;
  static const int CONNECTION_TEST_TIMEOUT_MS = 5000;
  static const int VERSION_TAP_COUNT = 5;

  // ---- 格式化精度 ----
  static const int PRECISION_ZERO = 0;
  static const int PRECISION_ONE = 1;
  static const int PRECISION_TWO = 2;

  // ---- 算法常数 ----
  static const double ZERO = 0.0;
  static const double ONE = 1.0;
  static const double TWO = 2.0;
  static const double SIXTY = 60.0;
  static const double HUNDRED = 100.0;
  static const double HALF = 0.5;
}
