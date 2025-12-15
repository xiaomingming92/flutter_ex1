/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-28 08:59:58
 * @LastEditors: Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime: 2025-12-15 11:45:10
 * @FilePath      : /ex1/lib/network/error_handler.dart
 * @Description   : 错误处理
 * 
 */
import 'package:dio/dio.dart';
import './exception.dart';

class ErrorHandler {
  static APPException fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkException(NetworkError.timeout, e.message ?? '连接超时');
      case DioExceptionType.sendTimeout:
        return NetworkException(NetworkError.timeout, e.message ?? '发送超时');
      case DioExceptionType.receiveTimeout:
        return NetworkException(NetworkError.timeout, e.message ?? '响应超时');
      case DioExceptionType.badResponse:
        return NetworkException(
            NetworkError.serverError, e.response?.statusMessage ?? '服务器异常');
      case DioExceptionType.cancel:
        return NetworkException(NetworkError.cancelled, e.message ?? '请求取消');
      case DioExceptionType.badCertificate:
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return NetworkException(NetworkError.unknown, e.message ?? '未知网络异常');
    }
  }

  static APPException fromBusiness(Map<String, dynamic> responseData) {
    final code = responseData['code'] as int?;
    final message = responseData['message'] as String? ?? '业务处理失败';
    if (code != null && code != 0) {
      return BusinessExpection(message, code);
    } else {
      return ProtocolException(message);
    }
  }
  static APPException fromHttp(statusCode, Map<String, dynamic> responseData) {
    return HttpStatusException.fromStatusCode(statusCode, responseData: responseData);
  }
}