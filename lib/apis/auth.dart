/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-28 09:00:37
 * @LastEditors: Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime: 2025-12-10 11:35:06
 * @FilePath     : /ex1/lib/apis/auth.dart
 * @Description   : 
 * 
 */
import 'package:dio/dio.dart';
import '../network/dio.dart';
import '../network/request.dart';

class AuthApi {
  // /**
  //  * @description   : 登录
  //  * @return         {*}
  //  */
  static Future<Response<DioResponseData<LoginRes>>> login(String identifier, String passwd) async {
    final Map<String, String> params = {
      'identifier': identifier,
      'password': passwd,
    };
    print('params:::$params');
    return await Request.post<LoginRes>('/auth/login', data: params);
  }

  static Future refreshToken(refreshToken) async {
    return Request.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );
  }

  static void logOut() {
    
  }
  static Future checkToken() async {
    return await Request.get(
      '/auth/check-token',
    );
  }
}

class LoginRes {
  final String accessToken;
  final String refreshToken;
  final int accessExpiresAt;
  final int refreshExpiresAt;
  dynamic userInfo;
  
  LoginRes({
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpiresAt,
    required this.refreshExpiresAt,
    this.userInfo,
  });
  
  // 转换为标准Map的方法
  Map<String, dynamic> toMap() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'accessExpiresAt': accessExpiresAt,
      'refreshExpiresAt': refreshExpiresAt,
    };
  }
}