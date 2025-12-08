/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-28 08:55:56
 * @LastEditors   : xmm wujixmm@gmail.com
 * @LastEditTime  : 2025-10-28 15:10:26
 * @FilePath      : /ex1/lib/network/token_manager.dart
 * @Description   : token管理
 * 
 */
import 'package:dio/dio.dart';
import '../config/env.dart';

class TokenManager {
  static String? _accesstoken;
  static String? _refreshToken;

  static Future<String?> getAccessToken() async => _accesstoken;

  static Future<void> setTokens(String access, String refresh) async {
    _accesstoken = access;
    _refreshToken = refresh;
  }

  static Future<bool> refreshToken() async {
    if(_refreshToken == null) return false;
    try {
      final dio = Dio(BaseOptions(baseUrl: Env.current.baseUrl));
      final res = await dio.post('/auth/refresh', data: {
        'refresh_token': _refreshToken
      });
      final data =res.data;
      _accesstoken = data['access_token'];
      _refreshToken = data['refresh_token'];
      return true;
    } catch(e) {
      print("token refresh failed:$e");
      return false;
    }
  }
  static void clear() {
    _accesstoken = null;
    _refreshToken = null;
  }
}