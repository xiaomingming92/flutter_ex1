/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-28 08:54:04
 * @LastEditors: Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime: 2025-12-15 13:20:14
 * @FilePath      : /ex1/lib/network/request.dart
 * @Description   : http请求方法封装
 * 
 */

import 'package:dio/dio.dart';
import 'dio.dart';
import 'error_handler.dart';
import 'exception.dart';

class Request {
  // 移除全局cancelToken，改为每个请求独立管理
  static Future<ResponseData<T>> get<T>(
    String path, {
      Map<String, dynamic>? params,
      CancelToken? cancelToken,
      T Function(dynamic)? parseT,
    }
  ) async {
    try {
      final response = await DioClient.instance.get<dynamic>(
        path,
        queryParameters: params,
        cancelToken: cancelToken ?? CancelToken(), // 每个请求默认独立令牌
      );
      
      // 处理 HTTP 状态码：2xx 正常，3xx 重定向（Dio 已处理），4xx/5xx 需要检查
      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 400) {
        // 4xx/5xx 错误，但可能包含业务错误信息
        // 尝试解析响应体，看是否有业务错误码
        if (response.data is Map<String, dynamic>) {
          final responseData = ResponseData.fromMap(response.data as Map<String, dynamic>, parseT);
          // 如果业务层返回了错误码，抛出业务异常
          if (!responseData.isSuccess) {
            // throw BusinessExpection(responseData.message, responseData.code);
            throw ErrorHandler.fromBusiness(response.data);
          }
        }
        // 如果没有业务错误信息，抛出 HTTP 状态码异常
        // throw HttpStatusException.fromStatusCode(statusCode, responseData: response.data);
        throw ErrorHandler.fromHttp(statusCode, response.data);
      }
      
      // 2xx/3xx 正常处理
      final responseData = ResponseData.parse(response.data, parseT);
      return responseData;
    } on BusinessExpection {
      rethrow;
    } on HttpStatusException {
      rethrow;
    } on DioException catch(e) {
      // Dio 抛出的异常（网络错误、超时等）
      throw ErrorHandler.fromDio(e);
    } on APPException {
      rethrow;
    }
  }
  
  static Future<ResponseData<T>> post<T>(
    String path, {
      dynamic data,
      CancelToken? cancelToken,
      T Function(dynamic)? parseT,
    }
  ) async {
    try {
      final response = await DioClient.instance.post<dynamic>(
        path,
        data: data,
        cancelToken: cancelToken ?? CancelToken(),
      );
      
      // 处理 HTTP 状态码：2xx 正常，3xx 重定向（Dio 已处理），4xx/5xx 需要检查
      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 400) {
        if (response.data is Map<String, dynamic>) {
          throw ErrorHandler.fromBusiness(response.data as Map<String, dynamic>);
        }
        throw ErrorHandler.fromHttp(statusCode, response.data);
      }
      
      // 2xx/3xx 正常处理
      final responseData = ResponseData.parse(response.data, parseT);
      if (!responseData.isSuccess) {
        if (response.data is Map<String, dynamic>) {
          throw ErrorHandler.fromBusiness(response.data as Map<String, dynamic>);
        }
        throw ProtocolException(responseData.message);
      }
      
      return responseData;
    } on BusinessExpection {
      rethrow;
    } on ProtocolException {
      rethrow;
    } on HttpStatusException {
      rethrow;
    } on DioException catch(e) {
      throw ErrorHandler.fromDio(e);
    } on APPException {
      rethrow;
    }
  }
  
  static Future<ResponseData<T>> delete<T>(
    String path, {
      dynamic data,
      CancelToken? cancelToken,
      T Function(dynamic)? parseT,
    }
  ) async {
    try {
      final response = await DioClient.instance.delete<dynamic>(
        path,
        data: data,
        cancelToken: cancelToken ?? CancelToken(),
      );
      
      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 400) {
        if (response.data is Map<String, dynamic>) {
          throw ErrorHandler.fromBusiness(response.data as Map<String, dynamic>);
        }
        throw ErrorHandler.fromHttp(statusCode, response.data);
      }
      
      final responseData = ResponseData.parse(response.data, parseT);
      if (!responseData.isSuccess) {
        if (response.data is Map<String, dynamic>) {
          throw ErrorHandler.fromBusiness(response.data as Map<String, dynamic>);
        }
        throw ProtocolException(responseData.message);
      }
      return responseData;
    } on BusinessExpection {
      rethrow;
    } on ProtocolException {
      rethrow;
    } on HttpStatusException {
      rethrow;
    } on DioException catch(e) {
      throw ErrorHandler.fromDio(e);
    } on APPException {
      rethrow;
    }
  }

  static Future<ResponseData<T>> put<T>(
    String path, {
      dynamic data,
      CancelToken? cancelToken,
      T Function(dynamic)? parseT,    
    }
  ) async {
    try {
      final response = await DioClient.instance.put<dynamic>(
        path,
        data: data,
        cancelToken: cancelToken ?? CancelToken(),
      );
      
      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 400) {
        if (response.data is Map<String, dynamic>) {
          throw ErrorHandler.fromBusiness(response.data as Map<String, dynamic>);
        }
        throw ErrorHandler.fromHttp(statusCode, response.data);
      }
      
      final responseData = ResponseData.parse(response.data, parseT);
      if (!responseData.isSuccess) {
        if (response.data is Map<String, dynamic>) {
          throw ErrorHandler.fromBusiness(response.data as Map<String, dynamic>);
        }
        throw ProtocolException(responseData.message);
      }
      return responseData;
    } on BusinessExpection {
      rethrow;
    } on ProtocolException {
      rethrow;
    } on HttpStatusException {
      rethrow;
    } on DioException catch(e) {
      throw ErrorHandler.fromDio(e);
    } on APPException {
      rethrow;
    }
  }
}