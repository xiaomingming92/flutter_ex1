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
      T Function(dynamic)? fromJsonT,
    }
  ) async {
    try {
      final response = await DioClient.instance.get<dynamic>(
        path,
        queryParameters: params,
        cancelToken: cancelToken ?? CancelToken(), // 每个请求默认独立令牌
      );
      
      // 将响应数据转换为 DioResponseData
      final responseData = _convertResponse<T>(response, fromJsonT);
      
      return Response<DioResponseData<T>>(
        data: responseData,
        headers: response.headers,
        requestOptions: response.requestOptions,
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        isRedirect: response.isRedirect,
        redirects: response.redirects,
        extra: response.extra,
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
      T Function(dynamic)? fromJsonT,
    }
  ) async {
    try {
      final response = await DioClient.instance.post<dynamic>(
        path,
        data: data,
        cancelToken: cancelToken ?? CancelToken(),
      );
      
      // 将响应数据转换为 DioResponseData
      final responseData = _convertResponse<T>(response, fromJsonT);
      
      return Response<DioResponseData<T>>(
        data: responseData,
        headers: response.headers,
        requestOptions: response.requestOptions,
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        isRedirect: response.isRedirect,
        redirects: response.redirects,
        extra: response.extra,
      );
    } on DioException catch(e) {
      ErrorHandler.handle(e);
      rethrow;
    }
  }
  
  /// 将原始响应数据转换为 DioResponseData
  static DioResponseData<T> _convertResponse<T>(
    Response<dynamic> response,
    T Function(dynamic)? fromJsonT,
  ) {
    if (response.data is Map<String, dynamic>) {
      return DioResponseData.fromMap(
        response.data as Map<String, dynamic>,
        fromJsonT,
      );
    } else {
      // 如果响应不是 Map，返回错误格式的响应
      return DioResponseData<T>(
        code: -1,
        message: '响应格式错误',
        data: null,
      );
    }
  }

  static Future<Response<DioResponseData<T>>> put<T>(
    String path, {
      dynamic data,
      CancelToken? cancelToken,
      T Function(dynamic)? fromJsonT,
    }
  ) async {
    try {
      final response = await DioClient.instance.put<dynamic>(
        path,
        data: data,
        cancelToken: cancelToken ?? CancelToken(),
      );
      
      final responseData = _convertResponse<T>(response, fromJsonT);
      
      return Response<DioResponseData<T>>(
        data: responseData,
        headers: response.headers,
        requestOptions: response.requestOptions,
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        isRedirect: response.isRedirect,
        redirects: response.redirects,
        extra: response.extra,
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
      T Function(dynamic)? fromJsonT,
    }
  ) async {
    try {
      final response = await DioClient.instance.delete<dynamic>(
        path,
        data: data,
        cancelToken: cancelToken ?? CancelToken(),
      );
      
      final responseData = _convertResponse<T>(response, fromJsonT);
      
      return Response<DioResponseData<T>>(
        data: responseData,
        headers: response.headers,
        requestOptions: response.requestOptions,
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        isRedirect: response.isRedirect,
        redirects: response.redirects,
        extra: response.extra,
      );
    } on DioException catch(e) {
      ErrorHandler.handle(e);
      rethrow;
    }
  }
}