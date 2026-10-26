"""体征业务服务层。"""

from datetime import datetime, timedelta, timezone
from decimal import Decimal

from sqlalchemy.ext.asyncio import AsyncSession

from module_vital.dao.vital_dao import VitalDao
from module_vital.entity.do.vital_do import VitalAlertRule, VitalRecord
from module_vital.entity.vo.vital_vo import (
    VitalAlertRuleModel,
    VitalMetricModel,
    VitalRecordModel,
    VitalRecordQueryModel,
    VitalTrendPointModel,
)
from utils.log_util import logger

# 趋势统计允许的最大回溯天数
MAX_TREND_DAYS = 365


def _ensure_utc(value: datetime) -> datetime:
    """将时间转换为带 UTC 时区的 datetime。

    :param value: 原始时间，可能不带时区
    :return: 带时区的时间对象
    """
    if value.tzinfo is None:
        return value.replace(tzinfo=timezone.utc)
    return value.astimezone(timezone.utc)


class VitalService:
    """体征业务服务类。"""

    @classmethod
    async def get_metrics_services(cls, db: AsyncSession) -> list[VitalMetricModel]:
        """获取指标字典。

        :param db: ORM 会话
        :return: 指标字典模型列表
        """
        metrics = await VitalDao.select_metrics(db)
        return [
            VitalMetricModel(
                metricCode=item.metric_code,
                label=item.label,
                unit=item.unit,
                valueType=item.value_type,
                precision=item.precision or 0,
                dispOrder=item.disp_order or 0,
                disptype=item.disptype,
                icon=item.icon,
                defaultMin=float(item.default_min) if item.default_min is not None else None,
                defaultMax=float(item.default_max) if item.default_max is not None else None,
                isEstimated=item.is_estimated,
                enabled=item.enabled,
            )
            for item in metrics
        ]

    @classmethod
    async def get_latest_services(cls, db: AsyncSession, user_id: int) -> list[VitalRecordModel]:
        """获取各指标最新值。

        :param db: ORM 会话
        :param user_id: 用户编号
        :return: 最新记录模型列表
        """
        records = await VitalDao.select_latest_records(db, user_id)
        return [cls._to_record_model(item) for item in records]

    @classmethod
    async def get_records_services(
        cls, db: AsyncSession, user_id: int, query_model: VitalRecordQueryModel
    ) -> object:
        """分页查询记录。

        :param db: ORM 会话
        :param user_id: 用户编号
        :param query_model: 查询条件
        :return: 分页对象
        """
        return await VitalDao.select_records_page(db, user_id, query_model)

    @classmethod
    async def add_record_services(cls, db: AsyncSession, user_id: int, model: VitalRecordModel) -> str:
        """新增单条记录。

        :param db: ORM 会话
        :param user_id: 用户编号
        :param model: 记录模型
        :return: 记录主键
        """
        exists = await VitalDao.select_existing_ids(db, [model.record_id])
        if model.record_id in exists:
            return model.record_id
        entity = cls._to_record_entity(model, user_id)
        await VitalDao.insert_records(db, [entity])
        await db.commit()
        logger.info('体征记录写入成功，主键：{}', model.record_id)
        return model.record_id

    @classmethod
    async def add_records_services(cls, db: AsyncSession, user_id: int, models: list[VitalRecordModel]) -> int:
        """批量新增记录，按主键幂等。

        :param db: ORM 会话
        :param user_id: 用户编号
        :param models: 记录模型集合
        :return: 实际写入条数
        """
        if not models:
            return 0
        record_ids = [item.record_id for item in models]
        exists = await VitalDao.select_existing_ids(db, record_ids)
        entities = [cls._to_record_entity(item, user_id) for item in models if item.record_id not in exists]
        written = await VitalDao.insert_records(db, entities)
        await db.commit()
        logger.info('体征记录批量写入完成，请求 {} 条，实际写入 {} 条', len(models), written)
        return written

    @classmethod
    async def delete_records_services(cls, db: AsyncSession, user_id: int, record_ids: list[str]) -> int:
        """删除记录。

        :param db: ORM 会话
        :param user_id: 用户编号
        :param record_ids: 记录主键集合
        :return: 影响行数
        """
        affected = await VitalDao.delete_records(db, user_id, record_ids)
        await db.commit()
        return affected

    @classmethod
    async def get_trend_services(
        cls, db: AsyncSession, user_id: int, metric: str, period: int
    ) -> list[VitalTrendPointModel]:
        """获取趋势聚合数据。

        :param db: ORM 会话
        :param user_id: 用户编号
        :param metric: 指标编码
        :param period: 统计天数
        :return: 聚合点列表
        """
        days = period if 0 < period <= MAX_TREND_DAYS else MAX_TREND_DAYS
        start_time = datetime.now(timezone.utc) - timedelta(days=days)
        rows = await VitalDao.select_trend(db, user_id, metric, start_time)
        points: list[VitalTrendPointModel] = []
        for row in rows:
            raw_time = row['time']
            if isinstance(raw_time, datetime):
                point_time = _ensure_utc(raw_time)
            else:
                point_time = _ensure_utc(datetime.fromisoformat(str(raw_time)))
            points.append(
                VitalTrendPointModel(
                    time=point_time,
                    value=row['value'],
                    minValue=row['minValue'],
                    maxValue=row['maxValue'],
                )
            )
        return points

    @classmethod
    async def get_rules_services(cls, db: AsyncSession, user_id: int) -> list[VitalAlertRuleModel]:
        """获取阈值规则，未配置指标以字典默认区间补齐。

        :param db: ORM 会话
        :param user_id: 用户编号
        :return: 规则模型列表
        """
        metrics = await VitalDao.select_metrics(db)
        rules = await VitalDao.select_rules(db, user_id)
        rule_map = {item.metric: item for item in rules}
        result: list[VitalAlertRuleModel] = []
        for metric in metrics:
            rule = rule_map.get(metric.metric_code)
            if rule is None:
                result.append(
                    VitalAlertRuleModel(
                        ruleId=None,
                        metric=metric.metric_code,
                        label=metric.label,
                        minValue=float(metric.default_min) if metric.default_min is not None else None,
                        maxValue=float(metric.default_max) if metric.default_max is not None else None,
                        enabled='1',
                    )
                )
            else:
                result.append(
                    VitalAlertRuleModel(
                        ruleId=rule.rule_id,
                        metric=rule.metric,
                        label=metric.label,
                        minValue=float(rule.min_value) if rule.min_value is not None else None,
                        maxValue=float(rule.max_value) if rule.max_value is not None else None,
                        enabled=rule.enabled or '1',
                    )
                )
        return result

    @classmethod
    async def save_rule_services(cls, db: AsyncSession, user_id: int, model: VitalAlertRuleModel) -> None:
        """保存阈值规则。

        :param db: ORM 会话
        :param user_id: 用户编号
        :param model: 规则模型
        :return: 无返回值
        """
        existing = await VitalDao.select_rule_by_metric(db, user_id, model.metric)
        exists_value = existing is not None
        if existing is None:
            existing = VitalAlertRule(user_id=user_id, metric=model.metric, del_flag='0')
        existing.min_value = Decimal(str(model.min_value)) if model.min_value is not None else None
        existing.max_value = Decimal(str(model.max_value)) if model.max_value is not None else None
        existing.enabled = model.enabled
        if exists_value:
            await db.merge(existing)
        else:
            await VitalDao.save_rule(db, existing)
        await db.commit()

    @classmethod
    def _to_record_entity(cls, model: VitalRecordModel, user_id: int) -> VitalRecord:
        """将入参模型转换为记录实体。

        :param model: 记录模型
        :param user_id: 用户编号
        :return: 记录实体
        """
        return VitalRecord(
            record_id=model.record_id,
            user_id=user_id,
            metric=model.metric,
            value=Decimal(str(model.value)),
            unit=model.unit,
            measured_at=_ensure_utc(model.measured_at),
            source=model.source,
            quality=Decimal(str(model.quality)) if model.quality is not None else None,
            session_id=model.session_id,
            is_estimated='1' if model.is_estimated else '0',
            remark=model.remark,
            del_flag='0',
        )

    @classmethod
    def _to_record_model(cls, entity: VitalRecord) -> VitalRecordModel:
        """将记录实体转换为出参模型。

        :param entity: 记录实体
        :return: 记录模型
        """
        return VitalRecordModel(
            recordId=entity.record_id,
            metric=entity.metric,
            value=float(entity.value),
            unit=entity.unit,
            measuredAt=entity.measured_at,
            source=entity.source,
            quality=float(entity.quality) if entity.quality is not None else None,
            sessionId=entity.session_id,
            isEstimated=entity.is_estimated == '1',
            remark=entity.remark,
        )
