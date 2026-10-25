"""体征业务数据对象定义。"""

from sqlalchemy import CHAR, BigInteger, Column, Integer, Numeric, String

from common.mixin import AuditTimeMixin
from common.types import DbUtcDateTime
from config.database import Base


class VitalMetric(AuditTimeMixin, Base):
    """指标字典表。

    承载指标的展示配置，驱动客户端卡片渲染顺序与形态。
    """

    __tablename__ = 'vital_metric'
    __table_args__ = {'comment': '体征指标字典表'}

    metric_code = Column(String(32), primary_key=True, nullable=False, comment='指标编码')
    label = Column(String(32), nullable=False, comment='指标名称')
    unit = Column(String(16), nullable=True, comment='单位')
    value_type = Column(String(16), nullable=True, server_default='single', comment='取值类型')
    precision = Column(Integer, nullable=True, server_default='0', comment='小数位数')
    disp_order = Column(Integer, nullable=False, server_default='0', comment='显示顺序')
    disptype = Column(String(16), nullable=True, server_default='card', comment='渲染形态')
    icon = Column(String(64), nullable=True, comment='图标标识')
    default_min = Column(Numeric(8, 2), nullable=True, comment='默认下限')
    default_max = Column(Numeric(8, 2), nullable=True, comment='默认上限')
    is_estimated = Column(CHAR(1), nullable=True, server_default='0', comment='是否估算值')
    enabled = Column(CHAR(1), nullable=True, server_default='1', comment='是否启用')


class VitalRecord(AuditTimeMixin, Base):
    """体征记录表。

    一条测量会话可写入多条记录，通过 session_id 归组。
    """

    __tablename__ = 'vital_record'
    __table_args__ = {'comment': '体征记录表'}

    record_id = Column(String(64), primary_key=True, nullable=False, comment='记录主键，客户端生成')
    user_id = Column(BigInteger, nullable=False, index=True, comment='用户ID')
    metric = Column(String(32), nullable=False, comment='指标编码')
    value = Column(Numeric(8, 2), nullable=False, comment='指标数值')
    unit = Column(String(16), nullable=True, comment='单位')
    measured_at = Column(DbUtcDateTime(), nullable=False, comment='测量时间')
    source = Column(String(16), nullable=False, server_default='manual', comment='数据来源')
    quality = Column(Numeric(4, 2), nullable=True, comment='信号质量分')
    session_id = Column(String(64), nullable=True, comment='测量会话编号')
    is_estimated = Column(CHAR(1), nullable=True, server_default='0', comment='是否估算值')
    remark = Column(String(500), nullable=True, comment='备注')
    del_flag = Column(CHAR(1), nullable=True, server_default='0', comment='删除标志')


class VitalAlertRule(AuditTimeMixin, Base):
    """预警阈值规则表。

    按指标配置上下限，未配置的指标继承字典默认区间。
    """

    __tablename__ = 'vital_alert_rule'
    __table_args__ = {'comment': '体征预警阈值表'}

    rule_id = Column(Integer, primary_key=True, nullable=False, autoincrement=True, comment='规则主键')
    user_id = Column(BigInteger, nullable=False, index=True, comment='用户ID')
    metric = Column(String(32), nullable=False, comment='指标编码')
    min_value = Column(Numeric(8, 2), nullable=True, comment='下限')
    max_value = Column(Numeric(8, 2), nullable=True, comment='上限')
    enabled = Column(CHAR(1), nullable=True, server_default='1', comment='是否启用')
    del_flag = Column(CHAR(1), nullable=True, server_default='0', comment='删除标志')
