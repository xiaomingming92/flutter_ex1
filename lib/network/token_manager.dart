/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-28 08:55:56
 * @LastEditors: Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime: 2025-12-15 10:13:58
 * @FilePath      : /ex1/lib/network/token_manager.dart
 * @Description   : token管理
 * 
 */
import 'package:ex1/apis/auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  // 存储键常量
  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _refreshExpiresAtKey = 'refreshExpiresAt';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<String?> getAccessToken() async{
    return await _storage.read(key: _accessTokenKey);
  }

  static Future<String?> getRefreshToken() async{
    return await _storage.read(key: _refreshTokenKey);
  }

  static Future<void> setTokens(LoginRes loginResData) async {
    final data = loginResData.toMap();
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: data['accessToken']),
      _storage.write(key: _refreshTokenKey, value: data['refreshToken']),
      _storage.write(key: _refreshExpiresAtKey, value: data['refreshExpiresAt'].toString()),
      // _storage.write(key: 'access_expires_at', value: data['accessExpiresAt'].toString()),
    ]);
  }

  static Future<bool> refreshToken() async {
    final refreshToken = await getRefreshToken();
    if(refreshToken == null) return false;
    try {
      final res = await AuthApi.refreshToken(refreshToken);
      if(res.isSuccess && res.hasData) {
        await setTokens(res.data!);
        return true;
      }
      return false;
    } catch(e) {
      print("token refresh failed:$e");
      return false;
    }
  }
  static Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }
  static Future<bool> isTokenExpired() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    if(accessToken == null && refreshToken == null) return true;
    // 解析token过期时间
    try{
      final refreshExpiresAt = await _storage.read(key: _refreshExpiresAtKey).then((value) => int.parse(value ?? DateTime.now().millisecondsSinceEpoch.toString()));
      if(refreshExpiresAt <= DateTime.now().millisecondsSinceEpoch) {
        return true;
      }
      final payload = await AuthApi.checkToken();
      if(payload == null) return true;
      return false; // Token有效
    } catch(e) {
      print("token verify failed:$e");
      return true;
    }
  }

  static Future getRefreshExpiresAt() async {}
}