import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/route_constant.dart';
import '../constant/str_constant.dart';
import '../constant/ui_constant.dart';

/// 底部主导航
///
/// 功能说明: 统一首页、记录、趋势、设置四个 Tab 的切换，避免各页重复实现
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class MainBottomBar extends StatelessWidget
{
  /// 当前选中索引
  final int currentIndex;

  /// 构造函数
  const MainBottomBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context)
  {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: UIConstants.COLOR_RESULT_BG,
      selectedItemColor: UIConstants.COLOR_ACCENT_LIGHT,
      unselectedItemColor: UIConstants.COLOR_TEXT_ON_LIGHT_SUB,
      selectedFontSize: UIConstants.FONT_XS,
      unselectedFontSize: UIConstants.FONT_XS,
      onTap: _onTap,
      items: const <BottomNavigationBarItem>
      [
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: StringConstants.TAB_HOME),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: StringConstants.TAB_RECORDS),
        BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: StringConstants.TAB_TRENDS),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: StringConstants.TAB_SETTINGS),
      ],
    );
  }

  /// 切换 Tab
  ///
  /// [index] 目标索引
  void _onTap(int index)
  {
    if (index == currentIndex)
    {
      return;
    }
    if (index == 0)
    {
      Get.offNamed(RouteConstants.HOME);
    }
    else if (index == 1)
    {
      Get.offNamed(RouteConstants.RECORDS);
    }
    else if (index == 2)
    {
      Get.offNamed(RouteConstants.TRENDS);
    }
    else if (index == 3)
    {
      Get.offNamed(RouteConstants.SETTINGS);
    }
  }
}
