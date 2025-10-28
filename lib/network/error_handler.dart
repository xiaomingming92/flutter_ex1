/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-28 08:59:58
 * @LastEditors   : xmm wujixmm@gmail.com
 * @LastEditTime  : 2025-10-28 14:36:21
 * @FilePath      : /ex1/lib/network/error_handler.dart
 * @Description   : 
 * 
 */
import 'package:dio/dio.dart';

class ErrorHandler {
  static void handle(DioException e) {
    switch(e.type) {
      case DioExceptionType.connectionTimeout: {
        // 连接超时
        break;

      }
      case DioExceptionType.receiveTimeout: {
        // 响应超时
        break;
      }
      case DioExceptionType.badResponse: {
        final code = e.response?.statusCode;
        final message = e.response?.statusMessage;
        // http error
        break;
      }
      default: {
        break;
      }
    }
  }
}