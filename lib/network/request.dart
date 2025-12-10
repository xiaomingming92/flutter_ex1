/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-28 08:54:04
 * @LastEditors: Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime: 2025-12-10 11:15:43
 * @FilePath      : /ex1/lib/network/request.dart
 * @Description   : http请求方法封装
 * 
 */
import 'package:dio/dio.dart';
import 'dio.dart';
import 'error_handler.dart';

class Request {
  // 移除全局cancelToken，改为每个请求独立管理
  static Future<Response<DioResponseData<T>>> get<T>(
    String path, {
      Map<String, dynamic>? params,
      CancelToken? cancelToken,
    }
  ) async {
    try {
      return await DioClient.instance.get<DioResponseData<T>>(
        path,
        queryParameters: params,
        cancelToken: cancelToken ?? CancelToken(), // 每个请求默认独立令牌
      );
    } on DioException catch(e) {
      ErrorHandler.handle(e);
      rethrow;
    }
  }
  
  static Future<Response<DioResponseData<T>>> post<T>(
    String path, {
      dynamic data,
      CancelToken? cancelToken,
    }
  ) async {
    try {
      return await DioClient.instance.post<DioResponseData<T>>(
        path,
        data: data,
        cancelToken: cancelToken ?? CancelToken(),
      );
    } on DioException catch(e) {
      ErrorHandler.handle(e);
      rethrow;
    }
  }

  static Future<Response<DioResponseData<T>>> put<T>(
    String path, {
      dynamic data,
      CancelToken? cancelToken,
    }
  ) async {
    try {
      return await DioClient.instance.put<DioResponseData<T>>(
        path,
        data: data,
        cancelToken: cancelToken ?? CancelToken(),
      );
    } on DioException catch(e) {
      ErrorHandler.handle(e);
      rethrow;
    }
  }

  static Future<Response<DioResponseData<T>>> delete<T>(
    String path, {
      dynamic data,
      CancelToken? cancelToken,
    }
  ) async {
    try {
      return await DioClient.instance.delete<DioResponseData<T>>(
        path,
        data: data,
        cancelToken: cancelToken ?? CancelToken(),
      );
    } on DioException catch(e) {
      ErrorHandler.handle(e);
      rethrow;
    }
  }
}