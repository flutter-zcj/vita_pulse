-- VitaPulse 体征业务表初始化脚本（PostgreSQL）
-- 执行顺序：先执行 ruoyi-fastapi-pg.sql，再执行本脚本

CREATE TABLE IF NOT EXISTS vital_metric
(
    metric_code  VARCHAR(32) PRIMARY KEY,
    label        VARCHAR(32) NOT NULL,
    unit         VARCHAR(16),
    value_type   VARCHAR(16) DEFAULT 'single',
    precision    INTEGER     DEFAULT 0,
    disp_order   INTEGER     DEFAULT 0 NOT NULL,
    disptype     VARCHAR(16) DEFAULT 'card',
    icon         VARCHAR(64),
    default_min  NUMERIC(8, 2),
    default_max  NUMERIC(8, 2),
    is_estimated CHAR(1)     DEFAULT '0',
    enabled      CHAR(1)     DEFAULT '1',
    create_by    VARCHAR(64) DEFAULT '',
    create_time  TIMESTAMPTZ,
    update_by    VARCHAR(64) DEFAULT '',
    update_time  TIMESTAMPTZ
);

COMMENT ON TABLE vital_metric IS '体征指标字典表';

CREATE TABLE IF NOT EXISTS vital_record
(
    record_id    VARCHAR(64) PRIMARY KEY,
    user_id      BIGINT       NOT NULL,
    metric       VARCHAR(32)  NOT NULL,
    value        NUMERIC(8, 2) NOT NULL,
    unit         VARCHAR(16),
    measured_at  TIMESTAMPTZ  NOT NULL,
    source       VARCHAR(16) DEFAULT 'manual' NOT NULL,
    quality      NUMERIC(4, 2),
    session_id   VARCHAR(64),
    is_estimated CHAR(1)     DEFAULT '0',
    remark       VARCHAR(500),
    del_flag     CHAR(1)     DEFAULT '0',
    create_by    VARCHAR(64) DEFAULT '',
    create_time  TIMESTAMPTZ,
    update_by    VARCHAR(64) DEFAULT '',
    update_time  TIMESTAMPTZ
);

COMMENT ON TABLE vital_record IS '体征记录表';

CREATE INDEX IF NOT EXISTS idx_vital_record_user_metric_time
    ON vital_record (user_id, metric, measured_at DESC);

CREATE TABLE IF NOT EXISTS vital_alert_rule
(
    rule_id     SERIAL PRIMARY KEY,
    user_id     BIGINT      NOT NULL,
    metric      VARCHAR(32) NOT NULL,
    min_value   NUMERIC(8, 2),
    max_value   NUMERIC(8, 2),
    enabled     CHAR(1)     DEFAULT '1',
    del_flag    CHAR(1)     DEFAULT '0',
    create_by   VARCHAR(64) DEFAULT '',
    create_time TIMESTAMPTZ,
    update_by   VARCHAR(64) DEFAULT '',
    update_time TIMESTAMPTZ
);

COMMENT ON TABLE vital_alert_rule IS '体征预警阈值表';

CREATE INDEX IF NOT EXISTS idx_vital_alert_rule_user
    ON vital_alert_rule (user_id, metric);

-- 指标字典初始数据
INSERT INTO vital_metric (metric_code, label, unit, value_type, precision, disp_order, disptype, default_min, default_max, is_estimated, enabled)
VALUES ('heart_rate', '心率', 'bpm', 'single', 0, 10, 'card', 60, 100, '0', '1')
ON CONFLICT (metric_code) DO NOTHING;

INSERT INTO vital_metric (metric_code, label, unit, value_type, precision, disp_order, disptype, default_min, default_max, is_estimated, enabled)
VALUES ('spo2', '血氧', '%', 'percent', 0, 20, 'card', 95, 100, '0', '1')
ON CONFLICT (metric_code) DO NOTHING;

INSERT INTO vital_metric (metric_code, label, unit, value_type, precision, disp_order, disptype, default_min, default_max, is_estimated, enabled)
VALUES ('systolic', '收缩压', 'mmHg', 'single', 0, 30, 'card', 90, 140, '0', '1')
ON CONFLICT (metric_code) DO NOTHING;

INSERT INTO vital_metric (metric_code, label, unit, value_type, precision, disp_order, disptype, default_min, default_max, is_estimated, enabled)
VALUES ('diastolic', '舒张压', 'mmHg', 'single', 0, 31, 'card', 60, 90, '0', '1')
ON CONFLICT (metric_code) DO NOTHING;

INSERT INTO vital_metric (metric_code, label, unit, value_type, precision, disp_order, disptype, default_min, default_max, is_estimated, enabled)
VALUES ('temperature', '体温', '℃', 'single', 1, 40, 'card', 36.0, 37.2, '0', '1')
ON CONFLICT (metric_code) DO NOTHING;

INSERT INTO vital_metric (metric_code, label, unit, value_type, precision, disp_order, disptype, default_min, default_max, is_estimated, enabled)
VALUES ('resp_rate', '呼吸率', '次/分', 'single', 0, 50, 'card', 12, 20, '1', '1')
ON CONFLICT (metric_code) DO NOTHING;

INSERT INTO vital_metric (metric_code, label, unit, value_type, precision, disp_order, disptype, default_min, default_max, is_estimated, enabled)
VALUES ('weight', '体重', 'kg', 'single', 1, 60, 'card', 45, 85, '0', '1')
ON CONFLICT (metric_code) DO NOTHING;

INSERT INTO vital_metric (metric_code, label, unit, value_type, precision, disp_order, disptype, default_min, default_max, is_estimated, enabled)
VALUES ('hrv_sdnn', 'SDNN', 'ms', 'single', 0, 70, 'card', 30, 80, '0', '1')
ON CONFLICT (metric_code) DO NOTHING;

INSERT INTO vital_metric (metric_code, label, unit, value_type, precision, disp_order, disptype, default_min, default_max, is_estimated, enabled)
VALUES ('hrv_rmssd', '心率变异性', 'ms', 'single', 0, 71, 'card', 20, 60, '0', '1')
ON CONFLICT (metric_code) DO NOTHING;

INSERT INTO vital_metric (metric_code, label, unit, value_type, precision, disp_order, disptype, default_min, default_max, is_estimated, enabled)
VALUES ('comfort', '舒适度', '', 'single', 0, 80, 'card', 60, 100, '1', '1')
ON CONFLICT (metric_code) DO NOTHING;

INSERT INTO vital_metric (metric_code, label, unit, value_type, precision, disp_order, disptype, default_min, default_max, is_estimated, enabled)
VALUES ('stress', '压力等级', '', 'single', 0, 81, 'card', 0, 2, '1', '1')
ON CONFLICT (metric_code) DO NOTHING;

-- App 端不做图形验证码，关闭底座验证码开关（后端仍保留验证码接口）
UPDATE sys_config SET config_value = 'false' WHERE config_key = 'sys.account.captchaEnabled';
