/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-12-23 17:06:25
 * @FilePath     : \ex1\lib\network\user_manager.dart
 * @Description   : 用户详情管理 - 负责用户信息缓存
 */
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../apis/user.dart';

class UserManager {
  static const String _userInfoKey = 'userInfo';
  static const String _maskedPhoneKey = 'maskedPhone';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static Map<String, dynamic>? _cachedUserInfo;
  static String? _cachedMaskedPhone;

  /// 缓存用户详情信息
  static Future<void> setUserInfo(Map<String, dynamic> userInfo) async {
    _cachedUserInfo = userInfo;
    await _storage.write(
      key: _userInfoKey, 
      value: json.encode(userInfo)
    );
  }

  /// 获取缓存的用户详情
  static Map<String, dynamic>? getUserInfo() {
    return _cachedUserInfo;
  }

  /// 异步获取用户详情（优先从缓存获取）
  static Future<Map<String, dynamic>?> getUserInfoAsync() async {
    if (_cachedUserInfo != null) {
      return _cachedUserInfo;
    }

    final userInfoString = await _storage.read(key: _userInfoKey);
    if (userInfoString != null) {
      try {
        _cachedUserInfo = json.decode(userInfoString) as Map<String, dynamic>;
        return _cachedUserInfo;
      } catch (e) {
        print('Failed to parse cached user info: $e');
      }
    }
    return null;
  }


  /// 获取用户昵称
  static String? getUserNickname() {
    final userInfo = _cachedUserInfo;
    if (userInfo == null) return null;

    return userInfo['nickname'] ?? 
           userInfo['nickName'] ?? 
           userInfo['username'] ?? 
           userInfo['name'] ?? 
           '未知用户';
  }

  /// 获取用户头像
  static String? getUserAvatar() {
    final userInfo = _cachedUserInfo;
    if (userInfo == null) return null;

    return userInfo['avatar'] ?? userInfo['headImage'] ?? userInfo['profilePicture'];
  }

  /// 检查是否有用户信息
  static bool hasUserInfo() {
    return _cachedUserInfo != null && _cachedUserInfo!.isNotEmpty;
  }

  /// 清除用户信息
  static Future<void> clear() async {
    _cachedUserInfo = null;
    _cachedMaskedPhone = null;
    await Future.wait([
      _storage.delete(key: _userInfoKey),
      _storage.delete(key: _maskedPhoneKey),
    ]);
  }
  
  /// 更新用户信息
  static Future<void> updateUserInfo(Map<String, dynamic> updates) async {
    final currentInfo = await getUserInfoAsync();
    if (currentInfo != null) {
      currentInfo.addAll(updates);
      await setUserInfo(currentInfo);
    }
  }

  /// 从登录响应中提取并缓存用户信息
  static Future<void> setUserInfoFromLogin(dynamic loginData) async {
    if (loginData == null) return;

    // 如果loginData有userInfo字段
    if (loginData is Map<String, dynamic> && loginData.containsKey('userInfo')) {
      final userInfo = loginData['userInfo'];
      if (userInfo is Map<String, dynamic>) {
        await setUserInfo(userInfo);
        return;
      }
    }

    // 如果loginData本身就是用户信息
    if (loginData is Map<String, dynamic>) {
      await setUserInfo(loginData);
    }
  }
}