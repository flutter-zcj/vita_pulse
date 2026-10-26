"""体征业务数据访问层。"""

from datetime import datetime, timezone
from typing import Any

from sqlalchemy import delete, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from module_vital.entity.do.vital_do import VitalAlertRule, VitalMetric, VitalRecord
from module_vital.entity.vo.vital_vo import VitalRecordQueryModel
from utils.page_util import PageUtil


class VitalDao:
    """体征业务数据库操作类。"""

    @classmethod
    async def select_metrics(cls, db: AsyncSession) -> list[VitalMetric]:
        """查询启用的指标字典。

        :param db: ORM 会话
        :return: 指标字典列表，按显示顺序升序
        """
        stmt = (
            select(VitalMetric)
            .where(VitalMetric.enabled == '1')
            .order_by(VitalMetric.disp_order.asc())
        )
        return list((await db.execute(stmt)).scalars().all())

    @classmethod
    async def select_records_page(
        cls, db: AsyncSession, user_id: int, query_model: VitalRecordQueryModel
    ) -> Any:
        """分页查询体征记录。

        :param db: ORM 会话
        :param user_id: 用户编号
        :param query_model: 分页与筛选条件
        :return: 分页对象
        """
        stmt = select(VitalRecord).where(
            VitalRecord.user_id == user_id,
            VitalRecord.del_flag == '0',
        )
        if query_model.metric:
            stmt = stmt.where(VitalRecord.metric == query_model.metric)
        if query_model.start_time:
            stmt = stmt.where(VitalRecord.measured_at >= _parse_time(query_model.start_time))
        if query_model.end_time:
            stmt = stmt.where(VitalRecord.measured_at <= _parse_time(query_model.end_time))
        stmt = stmt.order_by(VitalRecord.measured_at.desc())

        return await PageUtil.paginate(db, stmt, query_model.page_num, query_model.page_size, is_page=True)

    @classmethod
    async def select_latest_records(cls, db: AsyncSession, user_id: int) -> list[VitalRecord]:
        """查询各指标最新一条记录。

        :param db: ORM 会话
        :param user_id: 用户编号
        :return: 每个指标一条最新记录
        """
        latest_time = (
            select(
                VitalRecord.metric.label('metric'),
                func.max(VitalRecord.measured_at).label('latest_at'),
            )
            .where(VitalRecord.user_id == user_id, VitalRecord.del_flag == '0')
            .group_by(VitalRecord.metric)
            .subquery()
        )
        stmt = (
            select(VitalRecord)
            .join(
                latest_time,
                (VitalRecord.metric == latest_time.c.metric)
                & (VitalRecord.measured_at == latest_time.c.latest_at),
            )
            .where(VitalRecord.user_id == user_id, VitalRecord.del_flag == '0')
        )
        return list((await db.execute(stmt)).scalars().all())

    @classmethod
    async def select_latest_by_metric(cls, db: AsyncSession, user_id: int, metric: str) -> VitalRecord | None:
        """查询指定指标最新记录。

        :param db: ORM 会话
        :param user_id: 用户编号
        :param metric: 指标编码
        :return: 最新记录，无数据时为 None
        """
        stmt = (
            select(VitalRecord)
            .where(
                VitalRecord.user_id == user_id,
                VitalRecord.metric == metric,
                VitalRecord.del_flag == '0',
            )
            .order_by(VitalRecord.measured_at.desc())
            .limit(1)
        )
        return (await db.execute(stmt)).scalars().first()

    @classmethod
    async def select_existing_ids(cls, db: AsyncSession, record_ids: list[str]) -> set[str]:
        """查询已存在的记录主键。

        :param db: ORM 会话
        :param record_ids: 待检查主键集合
        :return: 已存在的主键集合
        """
        if not record_ids:
            return set()
        stmt = select(VitalRecord.record_id).where(VitalRecord.record_id.in_(record_ids))
        return {row[0] for row in (await db.execute(stmt)).all()}

    @classmethod
    async def insert_records(cls, db: AsyncSession, records: list[VitalRecord]) -> int:
        """批量写入记录。

        :param db: ORM 会话
        :param records: 记录实体集合
        :return: 实际写入条数
        """
        if not records:
            return 0
        db.add_all(records)
        await db.flush()
        return len(records)

    @classmethod
    async def delete_records(cls, db: AsyncSession, user_id: int, record_ids: list[str]) -> int:
        """逻辑删除记录。

        :param db: ORM 会话
        :param user_id: 用户编号
        :param record_ids: 待删除主键集合
        :return: 影响行数
        """
        if not record_ids:
            return 0
        stmt = (
            delete(VitalRecord)
            .where(VitalRecord.record_id.in_(record_ids), VitalRecord.user_id == user_id)
        )
        result = await db.execute(stmt)
        await db.flush()
        return result.rowcount or 0

    @classmethod
    async def select_trend(
        cls, db: AsyncSession, user_id: int, metric: str, start_time: datetime
    ) -> list[dict[str, Any]]:
        """按天聚合指标趋势。

        :param db: ORM 会话
        :param user_id: 用户编号
        :param metric: 指标编码
        :param start_time: 统计起始时间
        :return: 聚合结果列表
        """
        day_column = func.date(VitalRecord.measured_at).label('day')
        stmt = (
            select(
                day_column,
                func.avg(VitalRecord.value).label('avg_value'),
                func.min(VitalRecord.value).label('min_value'),
                func.max(VitalRecord.value).label('max_value'),
            )
            .where(
                VitalRecord.user_id == user_id,
                VitalRecord.metric == metric,
                VitalRecord.del_flag == '0',
                VitalRecord.measured_at >= start_time,
            )
            .group_by(day_column)
            .order_by(day_column.asc())
        )
        rows = (await db.execute(stmt)).all()
        return [
            {
                'time': row[0],
                'value': float(row[1] or 0),
                'minValue': float(row[2] or 0),
                'maxValue': float(row[3] or 0),
            }
            for row in rows
        ]

    @classmethod
    async def select_rules(cls, db: AsyncSession, user_id: int) -> list[VitalAlertRule]:
        """查询用户阈值规则。

        :param db: ORM 会话
        :param user_id: 用户编号
        :return: 规则列表
        """
        stmt = select(VitalAlertRule).where(
            VitalAlertRule.user_id == user_id,
            VitalAlertRule.del_flag == '0',
        )
        return list((await db.execute(stmt)).scalars().all())

    @classmethod
    async def select_rule_by_metric(cls, db: AsyncSession, user_id: int, metric: str) -> VitalAlertRule | None:
        """查询指定指标规则。

        :param db: ORM 会话
        :param user_id: 用户编号
        :param metric: 指标编码
        :return: 规则实体，不存在时为 None
        """
        stmt = select(VitalAlertRule).where(
            VitalAlertRule.user_id == user_id,
            VitalAlertRule.metric == metric,
            VitalAlertRule.del_flag == '0',
        )
        return (await db.execute(stmt)).scalars().first()

    @classmethod
    async def save_rule(cls, db: AsyncSession, rule: VitalAlertRule) -> None:
        """新增或更新规则。

        :param db: ORM 会话
        :param rule: 规则实体
        :return: 无返回值
        """
        db.add(rule)
        await db.flush()


def _parse_time(text: str) -> datetime:
    """解析时间字符串。

    :param text: ISO 风格时间字符串
    :return: 解析后的时间，解析失败时返回当前时间
    """
    try:
        parsed = datetime.fromisoformat(text)
    except ValueError:
        return datetime.now(timezone.utc)
    if parsed.tzinfo is None:
        return parsed.replace(tzinfo=timezone.utc)
    return parsed
