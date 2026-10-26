"""健康检查接口控制器。"""

from fastapi import Request, Response

from common.router import APIRouterPro
from utils.response_util import ResponseUtil

health_controller = APIRouterPro(
    prefix='',
    order_num=1,
    tags=['健康检查'],
)


@health_controller.get(
    '/health',
    summary='健康检查接口',
    description='用于客户端测试服务连通性，无需鉴权',
    include_in_schema=True,
)
async def health(request: Request) -> Response:
    """返回服务存活状态。

    :param request: 请求对象
    :return: 健康状态响应
    """
    return ResponseUtil.success(msg='ok', data={'status': 'ok'})
