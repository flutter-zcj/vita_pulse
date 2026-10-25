/// 统一业务异常
///
/// 功能说明: 封装接口层返回的错误码与错误消息，供 Controller 统一捕获
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class ApiException implements Exception
{
  /// 错误码
  final int code;

  /// 错误消息
  final String message;

  /// 构造函数
  ///
  /// [code] 业务错误码，默认为 -1 表示客户端异常
  /// [message] 面向用户的错误提示
  ApiException(this.message, {this.code = -1});

  @override
  String toString()
  {
    return 'ApiException($code): $message';
  }
}
