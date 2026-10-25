import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';
import 'constant/route_constant.dart';
import 'core/api/api_client.dart';
import 'data/repositories/vital_repository.dart';

/// 应用入口
///
/// 功能说明: 初始化网络客户端与仓储后启动应用，无登录页直接进入启动流程
/// 时间: 2026-10-25
/// 作者: zhengchaojun
Future<void> main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync<ApiClient>(() => ApiClient().init(), permanent: true);
  Get.put<VitalRepository>(VitalRepository(), permanent: true);
  runApp(const VitaPulseApp());
}

/// 应用根组件
///
/// 功能说明: 装配主题、路由与初始页面
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class VitaPulseApp extends StatelessWidget
{
  /// 构造函数
  const VitaPulseApp({super.key});

  @override
  Widget build(BuildContext context)
  {
    return GetMaterialApp(
      title: 'VitaPulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: RouteConstants.SPLASH,
      getPages: AppPages.pages,
      defaultTransition: Transition.cupertino,
    );
  }
}
