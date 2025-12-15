/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-28 08:53:43
 * @LastEditors: Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime: 2025-12-15 14:33:44
 * @FilePath      : /ex1/lib/network/dio.dart
 * @Description   : dio初始化和拦截器,jihua
 * 
 */

import 'package:dio/dio.dart';
import 'package:ex1/intent_controller/auth_intent_controller.dart';
import 'package:get/get.dart';
import '../env/env.dart';
import 'token_manager.dart';
import 'error_handler.dart';

class ResponseData<T> {
  final int code;
  final String message;
  final T? data;

  ResponseData({
    required this.code,
    required this.message,
    this.data,
  });
  factory ResponseData.parse(dynamic resData, T Function(dynamic)? parseT) {
    // 防止某些网关/静态文件/降级路径返回字符串
    if(resData == Null || resData is String) {
      return ResponseData(code: -1, message: '数据格式错误', data: null);
    }
    switch(resData.runtimeType) {
      case const (Map<String, dynamic>): {
        return ResponseData.fromMap(resData, parseT);
      }
      case const (List<dynamic>): {
        return ResponseData.fromList(resData, parseT);
      }
      case const (String): {
        return ResponseData.fromJSON(resData, parseT); 
      }
      default: {
        return ResponseData<T>(
          code: -1,
          message: '响应格式错误',
          data: null,
        );
      }
    }
  }
  factory ResponseData.fromMap(Map<String, dynamic> map, T Function(dynamic)? parseT) {
    return ResponseData<T>(
      code: map['code'] as int? ?? -1,
      message: map['message'] as String? ?? '',
      data: map['data'] != null 
        ? (parseT != null ? parseT(map['data']) : map['data'] as T?)
        : null,
    );
  }
  factory ResponseData.fromList(List<dynamic> list, T Function(dynamic)? parseT) {
    return ResponseData<T>(
      code: 200,
      message: 'success',
      data: list.map((e) => parseT!(e)).toList() as T?,
    );
  }
  factory ResponseData.fromJSON(String json, T Function(dynamic)? parseT) {
    return ResponseData<T>(
      code: 200,
      message: 'success',
      data: parseT!(json),
    );
  }

  /// 检查响应是否成功
  bool get isSuccess => code == 200;

  /// 检查是否有数据
  bool get hasData => data != null;
}

class DioClient {
  static Dio? _dio;
  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }
  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.current.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: Duration(seconds: 15),
        headers: {
          'Content-Type': "application/json"
        }
      )
    );
    // print("baseURL:${Env.current.baseUrl}");
    dio.interceptors.addAll(
      [
        InterceptorsWrapper(
          onRequest: (options, func) async {
            final token = await TokenManager.getAccessToken();
            if(token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            return func.next(options);
          },
          onResponse: (response, handler) {
            // 此处为横切关注点，要区分框架协议数据结构和业务数据结构，不能修改response
            return handler.next(response);
          },
          onError: (DioException e, handler) async {
            if(e.response?.statusCode == 401) {
              final refreshed = await TokenManager.refreshToken();
              if(refreshed) {
                final retryReq = e.requestOptions;
                retryReq.headers['Authorization'] = 'Bearer ${await TokenManager.getAccessToken()}';
                final res = await dio.fetch(retryReq);
                return handler.resolve(res);
              } else {
                final authIntentController = Get.put(AuthIntentController());
                authIntentController.handleLogoutIntent();
                return;
              }
            }
            ErrorHandler.fromDio(e);
            return handler.next(e);
          },
        ),
        LogInterceptor(
          requestBody: true,
          responseBody: true
        )
      ]
    );
    return dio;
  }
}