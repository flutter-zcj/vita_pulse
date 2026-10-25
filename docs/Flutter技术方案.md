# VitaPulse Flutter 技术方案（v3 · 无本地存储版）

> 变更：**取消 Hive 本地库与离线同步队列**，所有数据直连后端接口（RuoYi-FastAPI）。
> 状态管理保持 GetX。

---

## 一、数据流：接口即唯一数据源

```
View (GetView)  →  Controller (GetxController)  →  Provider (Dio)  →  RuoYi /vital/*
```

- **不做本地持久化**：无 Hive、无 GetStorage、无 SQLite
- **不做离线队列**：断网即提示，恢复后由用户下拉刷新
- **唯一例外**：登录令牌存 `flutter_secure_storage`（安全要求，非业务数据）
- **内存级缓存**：`GetxService` 里保留本次会话的指标字典（`vital_metric`）与最近一次查询结果，避免页面来回跳转重复请求；App 进程结束即失效

### 这个决定的代价（提前说清）

| 影响 | 说明 | 缓解 |
|---|---|---|
| 无网不可用 | 断网时看不到历史数据 | 空态页 + 重试按钮，措辞明确 |
| 每次进入页面都要请求 | 弱网下首屏变慢 | 骨架屏 + 会话内内存缓存 |
| 测量中途网络抖动 | 结果保存失败会丢数据 | 结果页"保存失败"时保留当前数值在内存，可重试保存 |

> 如果以后要离线能力，只需在 `data/local/` 加一层实现，Repository 接口不变——现在先把接口层设计干净。

---

## 二、技术选型

| 用途 | 包 | 说明 |
|---|---|---|
| 状态 / 路由 / DI | `get` | GetMaterialApp + GetxController + Bindings |
| 网络 | `dio` | 拦截器：注入 Bearer、统一解包、401 静默重登 |
| 图表 | `fl_chart` | 趋势折线、参考区间带 |
| 摄像头 | `camera` | YUV_420_888 帧流，30fps |
| 权限 | `permission_handler` | 相机权限 |
| 安全存储 | `flutter_secure_storage` | 仅存 token |
| 格式化 | `intl` | 日期、数字、单位 |

不引入：`hive`、`hive_flutter`、`get_storage`、`sqflite`、`connectivity_plus`。

---

## 三、目录结构

```
app/lib/
├── main.dart                     # GetMaterialApp + 主题 + 初始路由
├── app/
│   ├── routes/app_routes.dart    # 路由常量
│   ├── routes/app_pages.dart     # GetPage + Binding 声明
│   └── theme/app_theme.dart      # 设计 token（见 §5）
├── core/
│   ├── api/api_client.dart       # Dio 单例（GetxService, permanent）
│   ├── api/api_exception.dart    # 统一异常
│   ├── api/token_store.dart      # secure storage 读写
│   ├── base/base_controller.dart # 统一 loading / error / retry
│   └── utils/                    # 时间、单位、数值格式化
├── data/
│   ├── models/                   # 纯 Dart 模型（fromJson / toJson）
│   │   ├── vital_metric.dart
│   │   ├── vital_record.dart
│   │   └── alert_rule.dart
│   ├── providers/
│   │   ├── vital_api.dart        # /vital/* 全部接口
│   │   └── auth_api.dart         # /login /logout /getInfo
│   └── repositories/
│       └── vital_repository.dart # 组合 + 内存缓存
├── modules/
│   ├── splash/                   # 静默登录 + 拉字典
│   ├── home/                     # 首页仪表盘
│   ├── measure/
│   │   ├── prepare/              # 原型图 1
│   │   ├── running/              # 原型图 2
│   │   └── result/               # 原型图 3
│   ├── records/                  # 记录列表
│   ├── records_edit/             # 手动录入
│   ├── trends/                   # 趋势
│   ├── alerts/                   # 预警设置
│   └── settings/                 # 设置
└── services/
    ├── ppg/                      # 算法纯 Dart：filter / fft / quality / engine
    └── device/                   # DeviceAdapter：camera / mock / ble(预留)
```

每个 module 固定：`xxx_view.dart` + `xxx_controller.dart` + `xxx_binding.dart` + `widgets/`。

---

## 四、GetX 约定

| 场景 | 写法 |
|---|---|
| 页面跳转 | `Get.toNamed(Routes.MEASURE_RUNNING)` |
| 依赖注入 | 路由级 `Binding` + `Get.lazyPut()` |
| 响应式 | Controller 字段 `.obs` + View 里 `Obx(() => ...)` |
| 全局服务 | `Get.put(ApiClient(), permanent: true)` |
| 加载态 | `BaseController` 统一 `isLoading / error / retry()` |
| 生命周期 | 测量页 `onInit` 开相机，`onClose` **必须 release**，否则再次进入黑屏 |

---

## 五、设计 Token

| Token | 值 | 用途 |
|---|---|---|
| `bgDeep` | `#0B3133` | 测量流程背景 |
| `surfaceDark` | `#103C3E` | 波形卡片 |
| `accent` | `#2ED3BE` | 圆环、按钮、波形 |
| `accentDim` | `#1B7F78` | 次级描边 |
| `textOnDark` | `#E8F6F4` / `#7EA9A4` | 主/次文字 |
| `resultBg` | `#FFFFFF` | 结果页 |
| `textOnLight` | `#123639` / `#6B8C8C` | 结果页文字 |
| `accentLight` | `#17A99A` | 结果页强调 |

---

## 六、接口对接（底座现状）

| 项 | 事实 |
|---|---|
| 登录 | `POST /login`，**表单编码**，返回 `{code,msg,token}`；App 静默调用，无登录页 |
| 鉴权 | `Authorization: Bearer <token>`，24h 有效，无 refresh |
| 401 处理 | 拦截器自动重登一次 → 仍失败则提示"服务不可用" |
| 响应 | `{code:200, msg, data}` / `{code:200, msg, rows, total}` |
| 分页 | `pageNum` / `pageSize` |
| 时间 | 服务端 RFC3339 UTC，前端转本地时区 |

---

## 七、里程碑（按无存储版重排）

| 阶段 | 内容 | 验证 |
|---|---|---|
| M1 | GetX 骨架 + 主题 token + ApiClient + 三个原型页（Mock 数据） | `flutter analyze` 0 error |
| M2 | PPG 引擎 + 合成信号单测 + 摄像头接入 + 实时波形 | `dart test` 通过 |
| M3 | 首页 / 记录 / 趋势 / 预警接真实接口 | 端到端增删改查 |
| M4 | `module_vital` 后端 + `vital_metric` 字典 + Redis 预热 | `pytest` + 联调 |
| M5 | 打磨、README、CI | clone 即跑 |
