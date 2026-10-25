"""体征业务接口控制器。"""

from typing import Annotated

from fastapi import Path, Query, Request, Response
from sqlalchemy.ext.asyncio import AsyncSession

from common.annotation.log_annotation import Log
from common.aspect.db_session import DBSessionDependency
from common.aspect.pre_auth import CurrentUserDependency, PreAuthDependency
from common.enums import BusinessType
from common.router import APIRouterPro
from common.vo import DataResponseModel, PageResponseModel, ResponseBaseModel
from module_admin.entity.vo.user_vo import CurrentUserModel
from module_vital.entity.vo.vital_vo import (
    VitalAlertRuleModel,
    VitalMetricModel,
    VitalRecordBatchModel,
    VitalRecordModel,
    VitalRecordQueryModel,
    VitalTrendPointModel,
)
from module_vital.service.vital_service import VitalService
from utils.log_util import logger
from utils.response_util import ResponseUtil

vital_controller = APIRouterPro(
    prefix='/vital',
    order_num=20,
    tags=['体征业务'],
    dependencies=[PreAuthDependency()],
)


@vital_controller.get(
    '/metric/list',
    summary='获取指标字典接口',
    description='返回启用中的指标配置，按显示顺序排列',
    response_model=DataResponseModel[list[VitalMetricModel]],
)
async def get_metric_list(
    request: Request,
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    """获取指标字典。

    :param request: 请求对象
    :param current_user: 当前登录用户
    :param query_db: ORM 会话
    :return: 指标字典响应
    """
    result = await VitalService.get_metrics_services(query_db)
    logger.info('获取指标字典成功，共 {} 项', len(result))
    return ResponseUtil.success(data=[item.model_dump(by_alias=True) for item in result])


@vital_controller.get(
    '/record/latest',
    summary='获取各指标最新值接口',
    description='返回当前用户每个指标最近一次记录',
    response_model=DataResponseModel[list[VitalRecordModel]],
)
async def get_latest_record(
    request: Request,
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    """获取各指标最新值。

    :param request: 请求对象
    :param current_user: 当前登录用户
    :param query_db: ORM 会话
    :return: 最新记录响应
    """
    result = await VitalService.get_latest_services(query_db, current_user.user.user_id)
    return ResponseUtil.success(data=[item.model_dump(by_alias=True) for item in result])


@vital_controller.get(
    '/record/list',
    summary='获取记录分页列表接口',
    description='按指标与时间范围分页查询体征记录',
    response_model=PageResponseModel[VitalRecordModel],
)
async def get_record_list(
    request: Request,
    query_model: Annotated[VitalRecordQueryModel, Query()],
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    """分页查询记录。

    :param request: 请求对象
    :param query_model: 查询条件
    :param current_user: 当前登录用户
    :param query_db: ORM 会话
    :return: 分页响应
    """
    page = await VitalService.get_records_services(query_db, current_user.user.user_id, query_model)
    return ResponseUtil.success(model_content=page)


@vital_controller.get(
    '/record/stat',
    summary='获取趋势统计接口',
    description='按天聚合指定指标，返回均值与极值',
    response_model=DataResponseModel[list[VitalTrendPointModel]],
)
async def get_record_stat(
    request: Request,
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
    metric: Annotated[str, Query(description='指标编码')] = '',
    period: Annotated[int, Query(description='统计天数')] = 7,
) -> Response:
    """获取趋势统计。

    :param request: 请求对象
    :param metric: 指标编码
    :param period: 统计天数
    :param current_user: 当前登录用户
    :param query_db: ORM 会话
    :return: 聚合点响应
    """
    result = await VitalService.get_trend_services(query_db, current_user.user.user_id, metric, period)
    return ResponseUtil.success(data=[item.model_dump(by_alias=True) for item in result])


@vital_controller.post(
    '/record',
    summary='新增体征记录接口',
    description='写入单条体征记录，主键由客户端生成',
    response_model=ResponseBaseModel,
)
@Log(title='新增体征记录', business_type=BusinessType.INSERT)
async def add_record(
    request: Request,
    model: VitalRecordModel,
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    """新增单条记录。

    :param request: 请求对象
    :param model: 记录模型
    :param current_user: 当前登录用户
    :param query_db: ORM 会话
    :return: 操作结果响应
    """
    record_id = await VitalService.add_record_services(query_db, current_user.user.user_id, model)
    return ResponseUtil.success(msg='新增成功', data={'recordId': record_id})


@vital_controller.post(
    '/record/batch',
    summary='批量同步体征记录接口',
    description='按记录主键幂等写入，用于一次测量会话的多条记录',
    response_model=ResponseBaseModel,
)
@Log(title='批量同步体征记录', business_type=BusinessType.INSERT)
async def add_record_batch(
    request: Request,
    model: VitalRecordBatchModel,
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    """批量写入记录。

    :param request: 请求对象
    :param model: 批量入参
    :param current_user: 当前登录用户
    :param query_db: ORM 会话
    :return: 操作结果响应
    """
    written = await VitalService.add_records_services(query_db, current_user.user.user_id, model.records)
    return ResponseUtil.success(msg='同步成功', data={'written': written})


@vital_controller.delete(
    '/record/{record_ids}',
    summary='删除体征记录接口',
    description='按主键批量删除记录',
    response_model=ResponseBaseModel,
)
@Log(title='删除体征记录', business_type=BusinessType.DELETE)
async def delete_record(
    request: Request,
    record_ids: Annotated[str, Path(description='记录主键，多个以逗号分隔')],
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    """删除记录。

    :param request: 请求对象
    :param record_ids: 逗号分隔的主键串
    :param current_user: 当前登录用户
    :param query_db: ORM 会话
    :return: 操作结果响应
    """
    id_list = [item for item in record_ids.split(',') if item]
    affected = await VitalService.delete_records_services(query_db, current_user.user.user_id, id_list)
    return ResponseUtil.success(msg='删除成功', data={'affected': affected})


@vital_controller.get(
    '/alertRule',
    summary='获取阈值规则接口',
    description='返回各指标阈值，未配置时以字典默认值补齐',
    response_model=DataResponseModel[list[VitalAlertRuleModel]],
)
async def get_alert_rule(
    request: Request,
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    """获取阈值规则。

    :param request: 请求对象
    :param current_user: 当前登录用户
    :param query_db: ORM 会话
    :return: 规则响应
    """
    result = await VitalService.get_rules_services(query_db, current_user.user.user_id)
    return ResponseUtil.success(data=[item.model_dump(by_alias=True) for item in result])


@vital_controller.put(
    '/alertRule',
    summary='保存阈值规则接口',
    description='按指标新增或更新阈值规则',
    response_model=ResponseBaseModel,
)
@Log(title='保存阈值规则', business_type=BusinessType.UPDATE)
async def save_alert_rule(
    request: Request,
    model: VitalAlertRuleModel,
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    """保存阈值规则。

    :param request: 请求对象
    :param model: 规则模型
    :param current_user: 当前登录用户
    :param query_db: ORM 会话
    :return: 操作结果响应
    """
    await VitalService.save_rule_services(query_db, current_user.user.user_id, model)
    return ResponseUtil.success(msg='保存成功')
