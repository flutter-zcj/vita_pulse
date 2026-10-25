import 'package:get/get.dart';

import '../../constant/route_constant.dart';
import '../../modules/alerts/alerts_binding.dart';
import '../../modules/alerts/alerts_view.dart';
import '../../modules/home/home_binding.dart';
import '../../modules/home/home_view.dart';
import '../../modules/measure/prepare/prepare_binding.dart';
import '../../modules/measure/prepare/prepare_view.dart';
import '../../modules/measure/result/result_binding.dart';
import '../../modules/measure/result/result_view.dart';
import '../../modules/measure/running/running_binding.dart';
import '../../modules/measure/running/running_view.dart';
import '../../modules/records/records_binding.dart';
import '../../modules/records/records_view.dart';
import '../../modules/records_edit/record_edit_binding.dart';
import '../../modules/records_edit/record_edit_view.dart';
import '../../modules/settings/settings_binding.dart';
import '../../modules/settings/settings_view.dart';
import '../../modules/splash/splash_binding.dart';
import '../../modules/splash/splash_view.dart';
import '../../modules/trends/trends_binding.dart';
import '../../modules/trends/trends_view.dart';

/// 路由表
///
/// 功能说明: 声明全部 GetPage 与对应绑定，统一由 GetMaterialApp 加载
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class AppPages
{
  /// 页面列表
  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>
  [
    GetPage<dynamic>(
      name: RouteConstants.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage<dynamic>(
      name: RouteConstants.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage<dynamic>(
      name: RouteConstants.MEASURE_PREPARE,
      page: () => const PrepareView(),
      binding: PrepareBinding(),
    ),
    GetPage<dynamic>(
      name: RouteConstants.MEASURE_RUNNING,
      page: () => const RunningView(),
      binding: RunningBinding(),
    ),
    GetPage<dynamic>(
      name: RouteConstants.MEASURE_RESULT,
      page: () => const ResultView(),
      binding: ResultBinding(),
    ),
    GetPage<dynamic>(
      name: RouteConstants.RECORDS,
      page: () => const RecordsView(),
      binding: RecordsBinding(),
    ),
    GetPage<dynamic>(
      name: RouteConstants.RECORD_EDIT,
      page: () => const RecordEditView(),
      binding: RecordEditBinding(),
    ),
    GetPage<dynamic>(
      name: RouteConstants.TRENDS,
      page: () => const TrendsView(),
      binding: TrendsBinding(),
    ),
    GetPage<dynamic>(
      name: RouteConstants.ALERTS,
      page: () => const AlertsView(),
      binding: AlertsBinding(),
    ),
    GetPage<dynamic>(
      name: RouteConstants.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
  ];
}
