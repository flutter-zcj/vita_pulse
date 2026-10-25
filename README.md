# VitaPulse 脉迹

个人生命体征管家 · Flutter (GetX) + RuoYi-FastAPI

用手机摄像头测心率，日常记录并管理个人生命体征，看趋势、早发现异常。

> ⚠️ 本产品为健康参考工具，非医疗器械。测量结果不能用于诊断或治疗决策。

---

## 仓库结构

```
vita_pulse/
├── app/                     Flutter 客户端（GetX）
│   ├── lib/constant/        全量常量（文案、数字、接口、路由、色值）
│   ├── lib/core/            网络、异常、基类、工具
│   ├── lib/data/            模型 / 接口 / 仓储
│   ├── lib/modules/         9 个业务页面模块（三件套）
│   ├── lib/services/        PPG 算法、设备适配器
│   └── test/                算法单元测试
├── server/                  RuoYi-FastAPI 后端（v1.10.0 底座）
│   ├── module_admin/        底座原有：登录、用户、角色、菜单
│   ├── module_vital/        新增：体征业务模块
│   └── sql/vital-init.sql   业务表与指标字典初始化
└── docs/                    产品方案、技术方案、需求规格
```

## 快速启动

### 1. 后端

```bash
cd server
cp .env.example .env          # 已按 docker 网络预置
docker compose up -d          # 启动 PostgreSQL + Redis + API
# 打开 http://localhost:9099/docs
```

数据库首次启动自动执行 `sql/ruoyi-fastapi-pg.sql` 与 `sql/vital-init.sql`。
默认账号 `admin` / `admin123`，App 启动时静默登录，无需手动输入。

### 2. 客户端

```bash
cd app
flutter pub get
flutter run
```

要求 Flutter >= 3.24.0、Dart >= 3.4.0。后端地址在「设置 → 服务器地址」中修改。

## 技术栈

| 层 | 选型 |
|---|---|
| 客户端 | Flutter · GetX · Dio · fl_chart · camera |
| 后端 | FastAPI 0.141 · SQLAlchemy 2.0 · Redis · PyJWT |
| 数据库 | PostgreSQL 16 |

## 已实现能力

| 模块 | 说明 |
|---|---|
| 摄像头测量 | 30 秒 PPG 采集，输出心率 / SDNN / RMSSD / 舒适度 / 压力等级 |
| 手动录入 | 血氧、血压、体温、体重，含范围校验 |
| 首页仪表盘 | 指标卡片由后端字典驱动，附最近心率迷你趋势 |
| 记录列表 | 分页、指标与时间筛选、左滑删除 |
| 趋势分析 | 7 / 30 / 90 天聚合，参考区间带 |
| 预警阈值 | 按指标配置上下限，开关即时生效 |
| 指标字典 | `vital_metric` 表驱动，新增指标无需发版 |

## 数据边界

| 指标 | 来源 |
|---|---|
| 心率 / HRV / 舒适度 / 压力 | 摄像头 PPG 算法 |
| 呼吸率 | 摄像头估算，标注「估算」 |
| 血氧 / 血压 / 体温 / 体重 | 仅手动录入，**不做摄像头测算** |

手机单色光源无法完成血氧所需的双波长比值计算，本项目不提供该类估算值。

## 文档

- [产品方案](docs/产品方案.md)
- [Flutter 技术方案](docs/Flutter技术方案.md)
- [需求规格文档索引](docs/需求规格/README.md)
- [客户端说明](app/README.md)

## 许可证

MIT。后端底座源自 [RuoYi-FastAPI](https://github.com/insistence/RuoYi-FastAPI)，保留原作者版权声明。
