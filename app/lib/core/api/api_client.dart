import 'package:dio/dio.dart';
import 'package:get/get.dart' show GetxService;

import '../../constant/api_constant.dart';
import '../../constant/num_constant.dart';
import '../../constant/str_constant.dart';
import 'api_exception.dart';
import 'token_store.dart';

/// 网络请求客户端
///
/// 功能说明: 统一封装 Dio，负责令牌注入、响应解包、401 静默重登与异常转换
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class ApiClient extends GetxService
{
  /// Dio 实例
  late final Dio _dio;

  /// 令牌存储
  final TokenStore _tokenStore = TokenStore();

  /// 当前访问令牌
  String _token = '';

  /// 是否正在执行静默登录，避免并发重复登录
  bool _loggingIn = false;

  /// 初始化客户端
  ///
  /// 读取本地服务地址与令牌，完成 Dio 基础配置
  Future<ApiClient> init() async
  {
    final storedBaseUrl = await _tokenStore.readBaseUrl();
    final baseUrl = storedBaseUrl.isEmpty ? ApiConstants.DEFAULT_BASE_URL : storedBaseUrl;
    _token = await _tokenStore.readToken();
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(milliseconds: NumberConstants.CONNECT_TIMEOUT_MS),
        receiveTimeout: const Duration(milliseconds: NumberConstants.RECEIVE_TIMEOUT_MS),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );
    return this;
  }

  /// 当前服务地址
  String get baseUrl => _dio.options.baseUrl;

  /// 是否已持有令牌
  bool get hasToken => _token.isNotEmpty;

  /// 修改服务地址
  ///
  /// [newBaseUrl] 新的服务根地址，修改后清空令牌并重新登录
  Future<void> changeBaseUrl(String newBaseUrl) async
  {
    _dio.options.baseUrl = newBaseUrl;
    await _tokenStore.writeBaseUrl(newBaseUrl);
    await _tokenStore.clearToken();
    _token = '';
    await silentLogin();
  }

  /// 发起 GET 请求
  ///
  /// [path] 接口路径，取自 ApiConstants
  /// [query] 查询参数
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async
  {
    return _request(() => _dio.get<dynamic>(path, queryParameters: query));
  }

  /// 发起 POST 请求
  ///
  /// [path] 接口路径，取自 ApiConstants
  /// [data] 表单或 JSON 请求体
  Future<dynamic> post(String path, {Object? data}) async
  {
    return _request(() => _dio.post<dynamic>(path, data: data));
  }

  /// 发起 PUT 请求
  ///
  /// [path] 接口路径，取自 ApiConstants
  /// [data] 请求体
  Future<dynamic> put(String path, {Object? data}) async
  {
    return _request(() => _dio.put<dynamic>(path, data: data));
  }

  /// 发起 DELETE 请求
  ///
  /// [path] 接口路径，取自 ApiConstants
  Future<dynamic> delete(String path) async
  {
    return _request(() => _dio.delete<dynamic>(path));
  }

  /// 静默登录
  ///
  /// App 无登录页，启动时用内置账号换取令牌
  Future<void> silentLogin() async
  {
    if (_loggingIn)
    {
      return;
    }
    _loggingIn = true;
    try
    {
      final form = <String, dynamic>
      {
        ApiConstants.FIELD_USERNAME: ApiConstants.DEMO_USERNAME,
        ApiConstants.FIELD_PASSWORD: ApiConstants.DEMO_PASSWORD,
        ApiConstants.FIELD_GRANT_TYPE: ApiConstants.FIELD_GRANT_PASSWORD,
      };
      final response = await _dio.post<dynamic>(
        ApiConstants.LOGIN,
        data: form,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      final body = _asMap(response.data);
      final token = body[ApiConstants.FIELD_TOKEN]?.toString() ?? '';
      if (token.isEmpty)
      {
        throw ApiException(StringConstants.ERROR_SERVER);
      }
      _token = token;
      await _tokenStore.writeToken(token);
    }
    on ApiException
    {
      rethrow;
    }
    catch (error)
    {
      throw ApiException(StringConstants.TIP_SERVICE_UNAVAILABLE);
    }
    finally
    {
      _loggingIn = false;
    }
  }

  /// 测试服务连通性
  ///
  /// [targetBaseUrl] 待测试的服务根地址
  /// 返回 true 表示可访问
  Future<bool> testConnection(String targetBaseUrl) async
  {
    final probe = Dio(
      BaseOptions(
        baseUrl: targetBaseUrl,
        connectTimeout: const Duration(milliseconds: NumberConstants.CONNECTION_TEST_TIMEOUT_MS),
        receiveTimeout: const Duration(milliseconds: NumberConstants.CONNECTION_TEST_TIMEOUT_MS),
      ),
    );
    try
    {
      final response = await probe.get<dynamic>(ApiConstants.HEALTH);
      return response.statusCode != null && response.statusCode! < 400;
    }
    catch (error)
    {
      return false;
    }
    finally
    {
      probe.close();
    }
  }

  /// 执行请求并处理重试
  ///
  /// [send] 实际发送请求的闭包
  /// [retry] 是否允许在 401 时重试一次
  Future<dynamic> _request(Future<Response<dynamic>> Function() send, {bool retry = true}) async
  {
    try
    {
      final response = await send();
      return _unwrap(response.data);
    }
    on DioException catch (error)
    {
      if (_isUnauthorized(error) && retry)
      {
        await silentLogin();
        return _request(send, retry: false);
      }
      throw ApiException(_mapMessage(error));
    }
  }

  /// 解包统一响应结构
  ///
  /// [payload] 服务端原始响应体
  /// 返回 data 或 rows 字段内容
  dynamic _unwrap(dynamic payload)
  {
    final body = _asMap(payload);
    if (body.isEmpty)
    {
      return payload;
    }
    final code = body[ApiConstants.FIELD_CODE_STATUS];
    if (code is int && code != ApiConstants.SUCCESS_CODE)
    {
      if (code == ApiConstants.UNAUTHORIZED_CODE)
      {
        throw ApiException(StringConstants.TIP_SERVICE_UNAVAILABLE, code: code);
      }
      final msg = body[ApiConstants.FIELD_MSG]?.toString() ?? StringConstants.ERROR_SERVER;
      throw ApiException(msg, code: code);
    }
    if (body.containsKey(ApiConstants.FIELD_DATA))
    {
      return body[ApiConstants.FIELD_DATA];
    }
    if (body.containsKey(ApiConstants.FIELD_ROWS))
    {
      return body;
    }
    return body;
  }

  /// 转换为 Map
  ///
  /// [payload] 任意响应体，非 Map 时返回空 Map
  Map<String, dynamic> _asMap(dynamic payload)
  {
    if (payload is Map<String, dynamic>)
    {
      return payload;
    }
    if (payload is Map)
    {
      return payload.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }

  /// 判断是否为未授权
  ///
  /// [error] Dio 抛出的异常
  bool _isUnauthorized(DioException error)
  {
    return error.response?.statusCode == ApiConstants.UNAUTHORIZED_CODE;
  }

  /// 转换错误提示
  ///
  /// [error] Dio 抛出的异常
  String _mapMessage(DioException error)
  {
    switch (error.type)
    {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return StringConstants.ERROR_TIMEOUT;
      case DioExceptionType.connectionError:
        return StringConstants.ERROR_NETWORK;
      default:
        final data = _asMap(error.response?.data);
        return data[ApiConstants.FIELD_MSG]?.toString() ?? StringConstants.ERROR_SERVER;
    }
  }
}
