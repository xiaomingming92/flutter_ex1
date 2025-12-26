/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-28 09:00:37
 * @LastEditors  : Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime : 2025-12-26 17:02:35
 * @FilePath     : \ex1\lib\apis\auth.dart
 * @Description   : 
 * 
 */
import '../network/dio.dart';
import '../network/request.dart';

class AuthApi {
  // /**
  //  * @description   : 登录
  //  * @return         {*}
  //  */
  static Future<ResponseData<LoginRes>> login(String identifier, String passwd) async {
    final Map<String, String> params = {
      'identifier': identifier,
      'password': passwd,
    };
    return await Request.post<LoginRes>(
      '/auth/login',
      data: params,
      parseT: (json) => LoginRes.fromMap(json as Map<String, dynamic>), // 这里就实现项目框架级别的类型转换或者业务级别的类型转换，根据实际情况选择。是渐进式嵌入
    );
  }

  static Future refreshToken(refreshToken) async {
    return Request.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
      parseT: (json) => LoginRes.fromMap(json as Map<String, dynamic>),
    );
  }

  static void logOut() {
    
  }
  static Future checkToken() async {
    return await Request.get(
      '/auth/check-token',
    );
  }

  static Future<ResponseData<dynamic>> sendCode(String phone) async {
    return await Request.post<dynamic>(
      '/auth/send-code',
      data: {'phone': phone},
      parseT: (json) => json,
    );
  }


  static Future<ResponseData<LoginRes>> smsLogin(String phone, String code) async {
    return await Request.post<LoginRes>(
      '/auth/sms-login',
      data: {
        'phone': phone,
        'code': code,
      },
      parseT: (json) => LoginRes.fromMap(json as Map<String, dynamic>),
    );
  }
}

class LoginRes {
  final int code;
  final String message;
  final String accessToken;
  final String refreshToken;
  final int accessExpiresAt;
  final int refreshExpiresAt;
  dynamic userInfo;
  
  LoginRes({
    required this.code,
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpiresAt,
    required this.refreshExpiresAt,
    this.userInfo,
  });
  
  /// 从 JSON Map 创建 LoginRes 实例
  factory LoginRes.fromMap(Map<String, dynamic> json) {
    return LoginRes(
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      accessToken: json['accessToken'] as String? ?? json['access_token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? json['refresh_token'] as String? ?? '',
      accessExpiresAt: json['accessExpiresAt'] as int? ?? json['access_expires_at'] as int? ?? 0,
      refreshExpiresAt: json['refreshExpiresAt'] as int? ?? json['refresh_expires_at'] as int? ?? 0,
      userInfo: json['userInfo'] ?? json['user_info'],
    );
  }
  
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