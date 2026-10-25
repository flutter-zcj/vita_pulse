import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../constant/sp_key_constant.dart';

/// 令牌本地存取
///
/// 功能说明: 仅持久化访问令牌与基础地址，业务数据不落本地
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class TokenStore
{
  /// 安全存储实例
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// 读取访问令牌
  ///
  /// 返回值为空字符串表示尚未登录
  Future<String> readToken() async
  {
    final value = await _storage.read(key: SPKeyConstants.KEY_ACCESS_TOKEN);
    return value ?? '';
  }

  /// 写入访问令牌
  ///
  /// [token] 登录接口返回的令牌字符串
  Future<void> writeToken(String token) async
  {
    await _storage.write(key: SPKeyConstants.KEY_ACCESS_TOKEN, value: token);
  }

  /// 清除访问令牌
  Future<void> clearToken() async
  {
    await _storage.delete(key: SPKeyConstants.KEY_ACCESS_TOKEN);
  }

  /// 读取自定义服务地址
  ///
  /// 返回值为空字符串表示使用默认地址
  Future<String> readBaseUrl() async
  {
    final value = await _storage.read(key: SPKeyConstants.KEY_BASE_URL);
    return value ?? '';
  }

  /// 写入自定义服务地址
  ///
  /// [baseUrl] 形如 http://host:port 的服务根地址
  Future<void> writeBaseUrl(String baseUrl) async
  {
    await _storage.write(key: SPKeyConstants.KEY_BASE_URL, value: baseUrl);
  }

  /// 读取通用偏好值
  ///
  /// [key] 键名，取自 SPKeyConstants
  /// 返回空字符串表示未设置
  Future<String> readValue(String key) async
  {
    final value = await _storage.read(key: key);
    return value ?? '';
  }

  /// 写入通用偏好值
  ///
  /// [key] 键名，取自 SPKeyConstants
  /// [value] 待写入的值
  Future<void> writeValue(String key, String value) async
  {
    await _storage.write(key: key, value: value);
  }
}
