/// 应用级字符串常量
///
/// 功能说明: 统一管理界面文案、提示语与错误消息，禁止在业务代码中硬编码字符串
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class StringConstants
{
  // ---- 通用按钮 ----
  static const String BTN_CONFIRM = '确定';
  static const String BTN_CANCEL = '取消';
  static const String BTN_SAVE = '保存';
  static const String BTN_DELETE = '删除';
  static const String BTN_RETRY = '重试';
  static const String BTN_BACK = '返回';

  // ---- 通用提示 ----
  static const String TIP_LOADING = '加载中...';
  static const String TIP_LOAD_FAILED = '加载失败';
  static const String TIP_SAVE_SUCCESS = '已保存';
  static const String TIP_SAVE_FAILED = '保存失败，请重试';
  static const String TIP_DELETE_SUCCESS = '已删除';
  static const String TIP_DELETE_FAILED = '删除未完成';
  static const String TIP_NO_MORE = '没有更多了';
  static const String TIP_LOAD_MORE_FAILED = '加载失败，点击重试';
  static const String TIP_NETWORK_ERROR = '网络异常';
  static const String TIP_SERVICE_UNAVAILABLE = '服务暂不可用';
  static const String TIP_SAVED_ALREADY = '本次记录已保存';

  // ---- 错误消息 ----
  static const String ERROR_NETWORK = '网络连接失败，请检查网络设置';
  static const String ERROR_TIMEOUT = '请求超时，请重试';
  static const String ERROR_SERVER = '服务器繁忙，请稍后重试';
  static const String ERROR_UNKNOWN = '未知错误';
  static const String ERROR_PARSE = '数据解析失败';

  // ---- 页面标题 ----
  static const String TITLE_HOME = '今日概览';
  static const String TITLE_MEASURE_PREPARE = '生命体征检测';
  static const String TITLE_MEASURE_RUNNING = '正在检测';
  static const String TITLE_MEASURE_RESULT = '检测结果';
  static const String TITLE_RECORDS = '测量记录';
  static const String TITLE_RECORD_EDIT = '手动录入';
  static const String TITLE_TRENDS = '趋势分析';
  static const String TITLE_ALERTS = '预警阈值';
  static const String TITLE_SETTINGS = '设置';

  // ---- 底部导航 ----
  static const String TAB_HOME = '首页';
  static const String TAB_RECORDS = '记录';
  static const String TAB_TRENDS = '趋势';
  static const String TAB_SETTINGS = '设置';

  // ---- 首页 ----
  static const String HOME_START_MEASURE = '开始测量';
  static const String HOME_RECENT_TREND = '最近 7 次心率';
  static const String HOME_EMPTY = '暂无数据，请检查网络后重试';
  static const String HOME_GO_INPUT = '去录入';
  static const String HOME_NOT_MEASURED_LONG = '较久未测';
  static const String HOME_REFERENCE_RANGE = '参考区间';

  // ---- 测量准备 ----
  static const String PREPARE_SUBTITLE = '对准画面，保持静止约 30 秒';
  static const String PREPARE_TIP_LIGHT = '光线充足，正对光源';
  static const String PREPARE_TIP_STABLE = '手机放稳，轻触屏入镜';
  static const String PREPARE_TIP_STILL = '检测期间不说话、不移动';
  static const String PREPARE_START = '开始检测';
  static const String PREPARE_PERMISSION_TITLE = '需要相机权限才能测量';
  static const String PREPARE_PERMISSION_DENIED = '权限已被永久拒绝，请到系统设置中手动开启';
  static const String PREPARE_GO_SETTING = '去设置';
  static const String PREPARE_NO_CAMERA = '当前设备不支持摄像头测量';
  static const String PREPARE_USE_MANUAL = '改用手动录入';
  static const String DISCLAIMER = '结果仅供健康参考，不能替代医疗诊断';

  // ---- 测量进行中 ----
  static const String RUNNING_SUBTITLE = '正在检测，请保持静止';
  static const String RUNNING_WAVE_TITLE = '实时脉搏波形';
  static const String RUNNING_CANCEL = '取消检测';
  static const String RUNNING_UNIT_SECOND = '秒';
  static const String RUNNING_WEAK_SIGNAL = '信号较弱，请调整手指位置并保持不动';
  static const String RUNNING_NO_FINGER = '未检测到手指，请覆盖摄像头';
  static const String RUNNING_CAMERA_FAILED = '相机启动失败';
  static const String RUNNING_INTERRUPTED = '检测已中断';
  static const String RUNNING_LOW_PERFORMANCE = '设备性能不足，无法完成测量';

  // ---- 检测结果 ----
  static const String RESULT_HR = '心率';
  static const String RESULT_COMFORT = '舒适度';
  static const String RESULT_HRV = '心率变异性';
  static const String RESULT_SPO2 = '血氧';
  static const String RESULT_STRESS = '压力水平';
  static const String RESULT_STRESS_DESC = '压力指数由心率变异性推算，仅供参考。';
  static const String RESULT_WEAK_HINT = '本次信号较弱，结果仅供参考';
  static const String RESULT_SAVE = '保存记录';
  static const String RESULT_AGAIN = '重新检测';
  static const String RESULT_NO_SPO2 = '暂无';
  static const String RESULT_SOURCE_MANUAL = '手动';
  static const String RESULT_SOURCE_CAMERA = '实时';
  static const String RESULT_SOURCE_ESTIMATE = '估算';
  static const String STRESS_VERY_LOW = '很低';
  static const String STRESS_LOW = '较低';
  static const String STRESS_MIDDLE = '中等';
  static const String STRESS_HIGH = '较高';
  static const String STRESS_VERY_HIGH = '很高';

  // ---- 记录列表 ----
  static const String RECORDS_EMPTY = '暂无记录';
  static const String RECORDS_FILTER_METRIC = '指标';
  static const String RECORDS_FILTER_ALL = '全部';
  static const String RECORDS_RANGE_7 = '近7天';
  static const String RECORDS_RANGE_30 = '近30天';
  static const String RECORDS_RANGE_90 = '近90天';
  static const String RECORDS_RANGE_ALL = '全部';
  static const String RECORDS_DELETE_CONFIRM = '确定删除这条记录吗？';
  static const String TIME_TODAY = '今天';
  static const String TIME_YESTERDAY = '昨天';

  // ---- 手动录入 ----
  static const String EDIT_METRIC = '指标类型';
  static const String EDIT_VALUE = '数值';
  static const String EDIT_SYSTOLIC = '收缩压';
  static const String EDIT_DIASTOLIC = '舒张压';
  static const String EDIT_UNIT = '单位';
  static const String EDIT_TIME = '测量时间';
  static const String EDIT_REMARK = '备注';
  static const String EDIT_HINT_VALUE = '请输入数值';
  static const String EDIT_EMPTY_VALUE = '请输入数值';
  static const String EDIT_INVALID_NUMBER = '请输入有效数字';
  static const String EDIT_OUT_OF_RANGE = '数值超出合理范围';
  static const String EDIT_BP_BOTH_REQUIRED = '收缩压与舒张压需同时填写';
  static const String EDIT_TIME_FUTURE = '测量时间不能晚于当前时间';
  static const String EDIT_LEAVE_CONFIRM = '内容未保存，确定离开？';

  // ---- 趋势 ----
  static const String TREND_EMPTY = '该周期内暂无数据';
  static const String TREND_FEW_SAMPLES = '数据较少，趋势仅供参考';
  static const String TREND_MIN = '最小值';
  static const String TREND_AVG = '平均值';
  static const String TREND_MAX = '最大值';
  static const String TREND_COUNT = '样本数';
  static const String TREND_SWITCH_PERIOD = '切换周期';

  // ---- 预警阈值 ----
  static const String ALERT_MIN = '下限';
  static const String ALERT_MAX = '上限';
  static const String ALERT_RESET_DEFAULT = '恢复默认';
  static const String ALERT_RANGE_INVALID = '下限必须小于上限';
  static const String ALERT_OUT_OF_RANGE = '阈值超出合理范围';
  static const String ALERT_TOGGLE_FAILED = '设置未生效，请重试';
  static const String ALERT_EDIT_TITLE = '编辑阈值';

  // ---- 设置 ----
  static const String SETTING_GROUP_DATA = '数据';
  static const String SETTING_GROUP_DISPLAY = '显示';
  static const String SETTING_GROUP_SERVICE = '服务';
  static const String SETTING_GROUP_ABOUT = '关于';
  static const String SETTING_ALERT_RULE = '预警阈值';
  static const String SETTING_REMIND = '测量提醒';
  static const String SETTING_THEME = '外观模式';
  static const String SETTING_SERVER = '服务器地址';
  static const String SETTING_DISCLAIMER = '免责声明';
  static const String SETTING_VERSION = '版本号';
  static const String SETTING_THEME_SYSTEM = '跟随系统';
  static const String SETTING_THEME_LIGHT = '浅色';
  static const String SETTING_THEME_DARK = '深色';
  static const String SETTING_SERVER_INVALID = '请输入合法的 http/https 地址';
  static const String SETTING_SERVER_TIMEOUT = '连接超时，请检查地址与网络';
  static const String SETTING_SERVER_OK = '连接正常';
  static const String SETTING_SERVER_FAILED = '新地址不可用，已保留原地址';
  static const String SETTING_DISCLAIMER_BODY =
      '本产品为健康参考工具，非医疗器械。测量结果不能用于诊断或治疗决策。'
      '如出现身体不适，请及时就医。摄像头测量受光线、肤色、手指按压力度影响，'
      '数据仅用于个人长期趋势观察。';
  static const String APP_VERSION = 'v1.0.0 (1)';

  // ---- 指标编码 ----
  static const String METRIC_HEART_RATE = 'heart_rate';
  static const String METRIC_SPO2 = 'spo2';
  static const String METRIC_SYSTOLIC = 'systolic';
  static const String METRIC_DIASTOLIC = 'diastolic';
  static const String METRIC_TEMPERATURE = 'temperature';
  static const String METRIC_WEIGHT = 'weight';
  static const String METRIC_RESP_RATE = 'resp_rate';
  static const String METRIC_HRV_SDNN = 'hrv_sdnn';
  static const String METRIC_HRV_RMSSD = 'hrv_rmssd';
  static const String METRIC_COMFORT = 'comfort';
  static const String METRIC_STRESS = 'stress';
}
