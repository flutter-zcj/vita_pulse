import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/num_constant.dart';
import '../../constant/str_constant.dart';
import '../../constant/ui_constant.dart';
import '../../widgets/main_bottom_bar.dart';
import 'controller/settings_controller.dart';

/// 设置页面
///
/// 功能说明: 提供阈值入口、外观模式、服务地址与免责声明
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class SettingsView extends GetView<SettingsController>
{
  /// 构造函数
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(title: const Text(StringConstants.TITLE_SETTINGS)),
      body: ListView(
        padding: const EdgeInsets.all(UIConstants.PADDING_DEFAULT),
        children: <Widget>
        [
          _buildGroupTitle(StringConstants.SETTING_GROUP_DATA),
          _buildRow(
            title: StringConstants.SETTING_ALERT_RULE,
            onTap: controller.goAlerts,
            showArrow: true,
          ),
          Obx(
            () => _buildRow(
              title: StringConstants.SETTING_REMIND,
              trailing: Switch(
                value: controller.remindEnabled.value,
                onChanged: controller.toggleRemind,
              ),
            ),
          ),
          const SizedBox(height: UIConstants.PADDING_LG),
          _buildGroupTitle(StringConstants.SETTING_GROUP_DISPLAY),
          Obx(
            () => _buildRow(
              title: StringConstants.SETTING_THEME,
              value: _themeLabel(controller.themeMode.value),
              onTap: () => _pickTheme(context),
              showArrow: true,
            ),
          ),
          const SizedBox(height: UIConstants.PADDING_LG),
          _buildGroupTitle(StringConstants.SETTING_GROUP_SERVICE),
          Obx(
            () => _buildRow(
              title: StringConstants.SETTING_SERVER,
              value: controller.serverAddress.value,
              onTap: () => _editServer(context),
              showArrow: true,
            ),
          ),
          const SizedBox(height: UIConstants.PADDING_LG),
          _buildGroupTitle(StringConstants.SETTING_GROUP_ABOUT),
          _buildRow(
            title: StringConstants.SETTING_DISCLAIMER,
            onTap: _showDisclaimer,
            showArrow: true,
          ),
          _buildRow(
            title: StringConstants.SETTING_VERSION,
            value: StringConstants.APP_VERSION,
          ),
        ],
      ),
      bottomNavigationBar: const MainBottomBar(currentIndex: NumberConstants.TAB_INDEX_SETTINGS),
    );
  }

  /// 分组标题
  ///
  /// [title] 标题文本
  Widget _buildGroupTitle(String title)
  {
    return Padding(
      padding: const EdgeInsets.only(
        left: UIConstants.PADDING_XS,
        bottom: UIConstants.PADDING_SM,
      ),
      child: Text(
        title,
        style: const TextStyle(fontSize: UIConstants.FONT_XS, color: UIConstants.COLOR_TEXT_ON_LIGHT_SUB),
      ),
    );
  }

  /// 设置项行
  ///
  /// [title] 标题
  /// [value] 右侧文本
  /// [onTap] 点击回调
  /// [showArrow] 是否展示箭头
  /// [trailing] 自定义右侧组件
  Widget _buildRow({
    required String title,
    String value = '',
    VoidCallback? onTap,
    bool showArrow = false,
    Widget? trailing,
  })
  {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.PADDING_MD,
          vertical: UIConstants.PADDING_MD,
        ),
        decoration: const BoxDecoration(
          color: UIConstants.COLOR_RESULT_BG,
          border: Border(bottom: BorderSide(color: UIConstants.COLOR_DIVIDER)),
        ),
        child: Row(
          children: <Widget>
          [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: UIConstants.FONT_SM, color: UIConstants.COLOR_TEXT_ON_LIGHT),
              ),
            ),
            if (value.isNotEmpty)
              Text(
                value,
                style: const TextStyle(fontSize: UIConstants.FONT_XS, color: UIConstants.COLOR_TEXT_ON_LIGHT_SUB),
              ),
            if (trailing != null) trailing,
            if (showArrow)
              const Icon(
                Icons.chevron_right,
                size: UIConstants.ICON_DEFAULT,
                color: UIConstants.COLOR_TEXT_ON_LIGHT_SUB,
              ),
          ],
        ),
      ),
    );
  }

  /// 外观模式文案
  ///
  /// [mode] 主题模式
  String _themeLabel(ThemeMode mode)
  {
    if (mode == ThemeMode.light)
    {
      return StringConstants.SETTING_THEME_LIGHT;
    }
    if (mode == ThemeMode.dark)
    {
      return StringConstants.SETTING_THEME_DARK;
    }
    return StringConstants.SETTING_THEME_SYSTEM;
  }

  /// 选择外观模式
  ///
  /// [context] 上下文
  Future<void> _pickTheme(BuildContext context) async
  {
    await Get.bottomSheet<void>(
      Container(
        padding: const EdgeInsets.symmetric(vertical: UIConstants.PADDING_MD),
        decoration: const BoxDecoration(
          color: UIConstants.COLOR_RESULT_BG,
          borderRadius: BorderRadius.vertical(top: Radius.circular(UIConstants.RADIUS_LG)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>
          [
            _buildThemeOption(StringConstants.SETTING_THEME_SYSTEM, ThemeMode.system),
            _buildThemeOption(StringConstants.SETTING_THEME_LIGHT, ThemeMode.light),
            _buildThemeOption(StringConstants.SETTING_THEME_DARK, ThemeMode.dark),
          ],
        ),
      ),
    );
  }

  /// 主题选项
  ///
  /// [label] 文案
  /// [mode] 主题模式
  Widget _buildThemeOption(String label, ThemeMode mode)
  {
    return ListTile(
      title: Text(label),
      onTap: ()
      {
        controller.changeTheme(mode);
        Get.back();
      },
    );
  }

  /// 编辑服务地址
  ///
  /// [context] 上下文
  Future<void> _editServer(BuildContext context) async
  {
    final textController = TextEditingController(text: controller.serverAddress.value);
    await Get.dialog<void>(
      AlertDialog(
        title: const Text(StringConstants.SETTING_SERVER),
        content: TextField(
          controller: textController,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(hintText: StringConstants.SETTING_SERVER),
        ),
        actions: <Widget>
        [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(StringConstants.BTN_CANCEL),
          ),
          TextButton(
            onPressed: () async
            {
              final success = await controller.saveServerAddress(textController.text.trim());
              if (success)
              {
                Get.back();
              }
            },
            child: const Text(StringConstants.BTN_SAVE),
          ),
        ],
      ),
    );
    textController.dispose();
  }

  /// 展示免责声明
  Future<void> _showDisclaimer() async
  {
    await Get.dialog<void>(
      AlertDialog(
        title: const Text(StringConstants.SETTING_DISCLAIMER),
        content: const SingleChildScrollView(
          child: Text(StringConstants.SETTING_DISCLAIMER_BODY),
        ),
        actions: <Widget>
        [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(StringConstants.BTN_CONFIRM),
          ),
        ],
      ),
    );
  }
}
