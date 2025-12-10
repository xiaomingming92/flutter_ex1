/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-28 08:53:43
 * @LastEditors: Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime: 2025-12-10 11:39:21
 * @FilePath      : /ex1/lib/network/dio.dart
 * @Description   : dio初始化和拦截器,jihua
 * 
 */

import 'package:dio/dio.dart';
import '../config/env.dart';

import 'token_manager.dart';
import 'error_handler.dart';

// TODO getX包装一层

class DioResponseData<T> {
  final int code;
  final String message;
  final T? data;

  DioResponseData({
    required this.code,
    required this.message,
    this.data,
  });

  /// 从 Map 创建 DioResponseData 实例
  /// 自动处理数据转换，确保类型安全
  factory DioResponseData.fromMap(Map<String, dynamic> map, T Function(dynamic)? fromJsonT) {
    return DioResponseData<T>(
      code: map['code'] as int? ?? -1,
      message: map['message'] as String? ?? '',
      data: map['data'] != null 
        ? (fromJsonT != null ? fromJsonT(map['data']) : map['data'] as T?)
        : null,
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
    print("baseURL:${Env.current.baseUrl}");
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
            // final d = response.data;
            // DioResponseData<dynamic> wrappedData;
            
            // if (d is Map) {
            //   wrappedData = (
            //     code: d['code'] as int? ?? -1,
            //     message: d['message'] as String? ?? '',
            //     data: d['data'] ?? d // 兼容没有data字段的响应
            //   );
            // } else {
            //   wrappedData = (
            //     code: -1,
            //     message: '响应格式错误',
            //     data: d
            //   );
            // }
            
            // response.data = wrappedData;
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
              }
            }
            ErrorHandler.handle(e);
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