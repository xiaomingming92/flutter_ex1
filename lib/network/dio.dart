/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-28 08:53:43
 * @LastEditors: Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime: 2025-12-08 15:29:22
 * @FilePath      : /ex1/lib/network/dio.dart
 * @Description   : dio初始化和拦截器,jihua
 * 
 */

import 'package:dio/dio.dart';
import '../config/env.dart';

import 'token_manager.dart';
import 'error_handler.dart';

// TODO getX包装一层

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
          onResponse:(response, handler) => {

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