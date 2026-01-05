/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-28 09:00:43
 * @LastEditors  : Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime : 2026-01-05 16:15:25
 * @FilePath     : \ex1\lib\apis\user.dart
 * @Description   : 用户接口
 * 
 */
import 'package:ex1/network/dio.dart';
import 'package:ex1/network/user_manager.dart';
import '../network/request.dart';

class UserApi {
  static Future<ResponseData<UserRes>> getUserInfo() async {
    final userId = UserManager.currentUser?.id;
    if (userId == null) {
      throw Exception('User ID is null');
    }
    return await Request.get<UserRes>(
      '/user/info',
      params: {'id': userId},
      parseT: (json) => UserRes.fromMap(json),
    );
  }
  static Future<ResponseData<Map<String, dynamic>>> getUserInfoMap() async {
    final userId = UserManager.currentUser?.id;
    if (userId == null) {
      throw Exception('User ID is null');
    }
    return await Request.get(
      '/user/info',
      params: {'id': userId},
    );
  }

  /// 获取完整手机号
  static Future<String> getRealPhoneNumber() async {
    final res = await Request.get('/user/realphone');
    return res.data as String;
  }

  static Future updateInfo(Map<String, dynamic> info) async {
    final res = await Request.put('/usr/info', data: info);
    return res;
  }
}

class UserRes {
  final String id;
  final String username;
  final String bio;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> roles; // 角色列表
  final String? maskedPhone; // 脱敏手机号，如：138****5678
  final String? name;
  final String? avatar;
  final String? phone;

  UserRes({
    required this.id,
    required this.username,
    required this.bio,
    required this.createdAt,
    required this.updatedAt,
    required this.roles,
    this.maskedPhone,
    this.name,
    this.avatar,
    this.phone,
  });

  factory UserRes.fromMap(Map<String, dynamic> map) {
    return UserRes(
      id: map['id'],
      username: map['username'] ?? '',
      bio: map['bio'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      roles: List<String>.from(map['roles'] as List),
      maskedPhone: map['maskedPhone'] ??  '',
      name: map['name'] ?? '',
      avatar: map['avatar'] ?? '',
      phone: map['phone'] ?? '',
    );
  }
  UserInfo toUserInfo() {
    return UserInfo(id: id, username: username, bio: bio, createdAt: createdAt, updatedAt: updatedAt, roles: roles);
  }
}