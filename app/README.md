# VitaPulse App（Flutter）

个人生命体征管家的客户端实现，基于 GetX，无本地业务数据存储。

## 环境要求

| 项 | 版本 |
|---|---|
| Flutter | >= 3.24.0 |
| Dart | >= 3.4.0 |

> 低版本 Flutter 无法解析 `pubspec.yaml` 的 SDK 约束，且缺少 `PopScope` 等 API。

## 启动

```bash
cd app
flutter pub get
flutter run
```

后端地址默认 `http://192.168.2.105:9099`，可在「设置 → 服务器地址」中修改。

## 目录说明

```
lib/
├── constant/          全量字符串、数字、接口、路由、色值常量
├── app/               主题与路由表
├── core/              网络客户端、异常、基类控制器、工具
├── data/              模型、接口、仓储
├── modules/           页面模块（view / controller / binding 三件套）
├── services/          PPG 算法与设备适配器
└── widgets/           公共组件
```

## 编码约定

1. 所有大括号换行（Allman 风格）；
2. 字符串与数字常量统一定义在 `lib/constant/`，业务代码不出现裸字面量；
3. 每个模块固定 `xxx_view.dart` + `controller/xxx_controller.dart` + `xxx_binding.dart`；
4. 数据一律经 `ApiClient` 调用，页面不直接发起请求；
5. 业务数据不落本地库，仅令牌与两项偏好存 `flutter_secure_storage`。

## 测试

```bash
flutter test
```

`test/ppg_engine_test.dart` 使用合成正弦波验证心率估算精度。
