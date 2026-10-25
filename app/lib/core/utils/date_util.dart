import 'package:intl/intl.dart';

import '../../constant/num_constant.dart';
import '../../constant/str_constant.dart';

/// 日期时间格式化工具
///
/// 功能说明: 统一处理列表时间、趋势坐标与查询区间的时间格式
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class DateUtil
{
  /// 列表时间格式
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  /// 月日时间格式
  static final DateFormat _monthDayFormat = DateFormat('MM-dd HH:mm');

  /// 完整日期格式
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  /// 短日期格式
  static final DateFormat _shortDateFormat = DateFormat('MM-dd');

  /// 接口时间格式
  static final DateFormat _apiFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

  /// 格式化记录时间
  ///
  /// [time] 记录时间
  /// 返回今天 HH:mm / 昨天 HH:mm / MM-dd HH:mm / yyyy-MM-dd
  static String formatRecordTime(DateTime time)
  {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(time.year, time.month, time.day);
    final diffDays = today.difference(target).inDays;
    if (diffDays == NumberConstants.PRECISION_ZERO)
    {
      return '${StringConstants.TIME_TODAY} ${_timeFormat.format(time)}';
    }
    if (diffDays == 1)
    {
      return '${StringConstants.TIME_YESTERDAY} ${_timeFormat.format(time)}';
    }
    if (time.year == now.year)
    {
      return _monthDayFormat.format(time);
    }
    return _dateFormat.format(time);
  }

  /// 格式化日期
  ///
  /// [time] 目标时间
  /// 返回 yyyy-MM-dd
  static String formatDate(DateTime time)
  {
    return _dateFormat.format(time);
  }

  /// 格式化短日期
  ///
  /// [time] 目标时间
  /// 返回 MM-dd
  static String formatShortDate(DateTime time)
  {
    return _shortDateFormat.format(time);
  }

  /// 格式化为接口时间
  ///
  /// [time] 目标时间
  /// 返回 ISO 风格字符串，精度到秒
  static String toApiTime(DateTime time)
  {
    return _apiFormat.format(time);
  }

  /// 计算若干天前的时间
  ///
  /// [days] 天数
  static DateTime daysAgo(int days)
  {
    return DateTime.now().subtract(Duration(days: days));
  }

  /// 判断是否超过指定天数
  ///
  /// [time] 目标时间
  /// [days] 天数阈值
  static bool isStale(DateTime time, int days)
  {
    return DateTime.now().difference(time).inHours > days * NumberConstants.HOURS_PER_DAY;
  }

  /// 当天零点
  ///
  /// [time] 目标时间
  static DateTime startOfDay(DateTime time)
  {
    return DateTime(time.year, time.month, time.day);
  }
}
