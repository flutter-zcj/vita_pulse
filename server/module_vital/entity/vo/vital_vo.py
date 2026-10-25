"""体征业务出入参模型定义。"""

from datetime import datetime
from typing import Any, Literal

from pydantic import BaseModel, ConfigDict, Field
from pydantic.alias_generators import to_camel


class VitalMetricModel(BaseModel):
    """指标字典出参模型。"""

    model_config = ConfigDict(alias_generator=to_camel)

    metric_code: str = Field(description='指标编码')
    label: str = Field(description='指标名称')
    unit: str | None = Field(default=None, description='单位')
    value_type: str | None = Field(default='single', description='取值类型')
    precision: int = Field(default=0, description='小数位数')
    disp_order: int = Field(default=0, description='显示顺序')
    disptype: str | None = Field(default='card', description='渲染形态')
    icon: str | None = Field(default=None, description='图标标识')
    default_min: float | None = Field(default=None, description='默认下限')
    default_max: float | None = Field(default=None, description='默认上限')
    is_estimated: str | None = Field(default='0', description='是否估算值')
    enabled: str | None = Field(default='1', description='是否启用')


class VitalRecordModel(BaseModel):
    """体征记录出参与入参模型。"""

    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True)

    record_id: str = Field(description='记录主键')
    metric: str = Field(description='指标编码')
    value: float = Field(description='指标数值')
    unit: str | None = Field(default=None, description='单位')
    measured_at: datetime = Field(description='测量时间')
    source: Literal['camera', 'manual', 'ble'] = Field(default='manual', description='数据来源')
    quality: float | None = Field(default=None, description='信号质量分')
    session_id: str | None = Field(default=None, description='测量会话编号')
    is_estimated: bool = Field(default=False, description='是否估算值')
    remark: str | None = Field(default=None, description='备注')


class VitalRecordBatchModel(BaseModel):
    """批量写入体征记录入参模型。"""

    records: list[VitalRecordModel] = Field(description='记录集合')


class VitalRecordQueryModel(BaseModel):
    """体征记录分页查询模型。"""

    model_config = ConfigDict(alias_generator=to_camel)

    page_num: int = Field(default=1, description='当前页码')
    page_size: int = Field(default=20, description='每页记录数')
    metric: str | None = Field(default=None, description='指标编码')
    start_time: str | None = Field(default=None, description='起始时间')
    end_time: str | None = Field(default=None, description='结束时间')


class VitalTrendPointModel(BaseModel):
    """趋势聚合点出参模型。"""

    model_config = ConfigDict(alias_generator=to_camel)

    time: datetime = Field(description='聚合时间')
    value: float = Field(description='平均值')
    min_value: float | None = Field(default=None, description='区间最小值')
    max_value: float | None = Field(default=None, description='区间最大值')


class VitalAlertRuleModel(BaseModel):
    """预警阈值出参与入参模型。"""

    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True)

    rule_id: int | None = Field(default=None, description='规则主键')
    metric: str = Field(description='指标编码')
    label: str | None = Field(default=None, description='指标名称')
    min_value: float | None = Field(default=None, description='下限')
    max_value: float | None = Field(default=None, description='上限')
    enabled: str = Field(default='1', description='是否启用')


class VitalStatSummaryModel(BaseModel):
    """统计摘要出参模型。"""

    model_config = ConfigDict(alias_generator=to_camel)

    metric: str = Field(description='指标编码')
    count: int = Field(default=0, description='样本数')
    min_value: float | None = Field(default=None, description='最小值')
    max_value: float | None = Field(default=None, description='最大值')
    avg_value: float | None = Field(default=None, description='平均值')
    extra: dict[str, Any] | None = Field(default=None, description='扩展信息')
