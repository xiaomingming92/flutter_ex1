/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-28 08:54:04
 * @LastEditors   : xmm wujixmm@gmail.com
 * @LastEditTime  : 2025-10-28 15:43:10
 * @FilePath      : /ex1/lib/network/request.dart
 * @Description   : http请求方法封装
 * 
 */
import 'package:dio/dio.dart';
import 'dio.dart';
import 'error_handler.dart';

final cancelToken = CancelToken();

class Request {
  static Future<Response<T>> get<T> (
    String path, {
      Map<String, dynamic> ? params,
    }
  ) async {
    try {
      return await DioClient.instance.get(path, queryParameters: params, cancelToken: cancelToken);
    } on DioException catch(e) {
      ErrorHandler.handle(e);
      rethrow;
    }
  }
  
  static Future<Response<T>> post<T> (
    String path, {
      dynamic data,
    }
  ) async {
    try {
      return await DioClient.instance.post(path, data: data, cancelToken: cancelToken);
    } on DioException catch(e) {
      ErrorHandler.handle(e);
      rethrow;
    }
  }

  static Future<Response<T>> put<T> (
    String path, {
      dynamic data,
    }
  ) async {
    try {
      return await DioClient.instance.put(path, data: data, cancelToken: cancelToken);
    } on DioException catch(e) {
      ErrorHandler.handle(e);
      rethrow;
    }
  }

  static Future<Response<T>> delete<T> (
    String path, {
      dynamic data,
    }
  ) async {
    try {
      return await DioClient.instance.delete(path, data: data, cancelToken: cancelToken);
    } on DioException catch(e) {
      ErrorHandler.handle(e);
      rethrow;
    }
  }
}