/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-12-23 17:06:25
 * @FilePath     : \ex1\lib\network\user_manager.dart
 * @Description   : 用户详情管理 - 负责用户信息缓存
 */
import 'dart:convert';
import 'dart:core';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../apis/user.dart';

/// UGC 内容模型
class UGCContent {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  
  UGCContent({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
  });
  
  factory UGCContent.fromJson(Map<String, dynamic> json) {
    return UGCContent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likeCount': likeCount,
      'commentCount': commentCount,
    };
  }
}

/// 用户信息模型
class UserInfo {
  final String id;
  final String username;
  final String? maskedPhone; // 脱敏手机号，如：138****5678
  final String? name;
  final String? avatar;
  final String bio;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> roles; // 角色列表
  
  // 统计数据（需要从API获取或计算）
  final int? postCount;
  final int? followerCount;
  final int? followingCount;
  final List<UGCContent>? ugcContents;
  
  UserInfo({
    required this.id,
    required this.username,
    this.maskedPhone,
    this.name,
    this.avatar,
    required this.bio,
    required this.createdAt,
    required this.updatedAt,
    required this.roles,
    this.postCount,
    this.followerCount,
    this.followingCount,
    this.ugcContents,
  });
  
  /// 从 Map 数据创建 UserInfo
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? '',
      username: json['username'] ?? json['nickname'] ?? json['name'] ?? '未知用户',
      maskedPhone: json['phone'] ?? json['maskedPhone'],
      name: json['name'] ?? json['nickname'] ?? json['username'],
      avatar: json['avatar'] ?? json['headImage'] ?? json['profilePicture'],
      bio: json['bio'] ?? json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      roles: List<String>.from(json['roles'] ?? []),
      postCount: json['postCount'] ?? json['post_count'],
      followerCount: json['followerCount'] ?? json['follower_count'],
      followingCount: json['followingCount'] ?? json['following_count'],
      ugcContents: json['ugcContents'] != null 
          ? (json['ugcContents'] as List).map((e) => UGCContent.fromJson(e)).toList()
          : null,
    );
  }
  
  /// 转换为 Map 数据
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'phone': maskedPhone,
      'name': name,
      'avatar': avatar,
      'bio': bio,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'roles': roles,
      'postCount': postCount,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'ugcContents': ugcContents?.map((e) => e.toJson()).toList(),
    };
  }
  
  /// 空用户信息
  static UserInfo empty() {
    return UserInfo(
      id: '',
      username: '未知用户',
      bio: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      roles: [],
    );
  }
}

class UserManager {
  static const String _userInfoKey = 'userInfo';
  static const String _maskedPhoneKey = 'maskedPhone';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static Map<String, dynamic>? _cachedUserInfo;
  static String? _cachedMaskedPhone;
  static UserInfo? _currentUser;
  static UserInfo? get currentUser => _currentUser;

  /// 缓存用户详情信息
  static Future<void> setUserInfo(Map<String, dynamic> userInfo) async {
    _cachedUserInfo = userInfo;
    _currentUser = UserInfo.fromJson(userInfo);
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
        _currentUser = UserInfo.fromJson(_cachedUserInfo!);
        return _cachedUserInfo;
      } catch (e) {
        print('Failed to parse cached user info: $e');
      }
    }
    return null;
  }

  /// 加载完整用户信息（包含统计数据和UGC内容）
  static Future<void> loadUserProfile() async {
    try {
      // 1. 获取基础用户信息
      final basicUserInfo = await getUserInfoAsync();
      if (basicUserInfo == null) {
        throw Exception('用户未登录');
      }
      
      // 2. 转换为 UserInfo 对象
      _currentUser = UserInfo.fromJson(basicUserInfo);
      
      // 3. 获取统计数据（如果需要）
      await _loadUserStatistics();
      
      // 4. 获取UGC内容（如果需要）
      await _loadUserUGCContent();
      
    } catch (e) {
      print('加载用户信息失败: $e');
      rethrow;
    }
  }
  
  /// 刷新用户信息
  static Future<void> refreshUserProfile() async {
    _currentUser = null; // 清除缓存
    await loadUserProfile();
  }
  
  /// 获取用户统计信息
  static Future<void> _loadUserStatistics() async {
    if (_currentUser == null) return;
    
    try {
      // TODO: 调用获取统计数据的API
      // final response = await ApiService.getUserStatistics(_currentUser!.id);
      // 更新统计数据
    } catch (e) {
      print('获取统计数据失败: $e');
    }
  }
  
  /// 获取用户UGC内容
  static Future<void> _loadUserUGCContent() async {
    if (_currentUser == null) return;
    
    try {
      // TODO: 调用获取UGC内容的API
      // final response = await ApiService.getUserUGCContent(_currentUser!.id);
      // 更新UGC内容
    } catch (e) {
      print('获取UGC内容失败: $e');
    }
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
    _currentUser = null;
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
      
      // 更新当前用户对象
      if (_currentUser != null) {
        _currentUser = UserInfo.fromJson(currentInfo);
      }
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