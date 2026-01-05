/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-12-26 10:00:00
 * @FilePath     : \ex1\lib\intent_controller\personal_center_intent_controller.dart
 * @Description   : 个人中心操作意图控制器
 */
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ex1/network/user_manager.dart';
import 'package:ex1/intent_controller/auth_intent_controller.dart';
import 'package:get/get.dart';

class PersonalCenterController extends GetxController {
  /// 用户中心操作意图控制：
  /// - 不直接维护GUI状态，GUI状态由Widget内部处理
  /// - 专注于业务意图的处理和触发
  
  // PersonalCenterController成为唯一的状态持有者
  final Rx<UserInfo?> _currentUser = Rx<UserInfo?>(null);
  UserInfo? get currentUser => _currentUser.value;
  
  static const String _userInfoKey = 'userInfo';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();
  AuthIntentController authIntentController = Get.find<AuthIntentController>();
  
  @override
  void onInit() {
    super.onInit();
    // 优先从UserManager的缓存加载，避免IO操作
    final cachedUserInfo = UserManager.getUserInfo();
    if (cachedUserInfo != null) {
      _currentUser.value = UserInfo.fromMap(cachedUserInfo);
    } else {
      // 缓存没有再从storage加载
      _loadUserFromStorage();
    }
    
    // 监听用户数据变化事件，实现响应式更新 - 使用 StreamController
    UserManager.userInfoStream.listen((userInfo) {
      if (userInfo != null) {
        _currentUser.value = userInfo;
      }
    });
  }
  
  /// 从storage加载用户信息
  Future<void> _loadUserFromStorage() async {
    final userInfoString = await _storage.read(key: _userInfoKey);
    if (userInfoString != null) {
      try {
        final userInfoMap = json.decode(userInfoString) as Map<String, dynamic>;
        _currentUser.value = UserInfo.fromMap(userInfoMap);
      } catch (e) {
        print('Failed to parse cached user info: $e');
      }
    }
  }
  
  
  /// 更新用户信息（供外部调用）
  void updateUserInfo(UserInfo? userInfo) {
    _currentUser.value = userInfo;
  }
  
  /// 加载用户信息的业务意图
  Future<void> handleLoadProfileIntent() async {
    // 业务逻辑：调用 UserManager 加载数据
    await UserManager.loadUserProfile();
    // 从UserManager获取最新的用户信息，更新自己的状态
    final latestUserInfo = UserManager.currentUser;
    if (latestUserInfo != null) {
      _currentUser.value = latestUserInfo;
    }
  }
  
  /// 刷新用户信息的业务意图
  Future<void> handleRefreshProfileIntent() async {
    // 业务逻辑：刷新用户数据
    await UserManager.refreshUserProfile();
    // 从UserManager获取最新的用户信息，更新自己的状态
    final latestUserInfo = UserManager.currentUser;
    if (latestUserInfo != null) {
      _currentUser.value = latestUserInfo;
    }
  }
  
  /// 登出业务意图
  Future<void> handleLogoutIntent() async {
    // 业务逻辑：清除用户数据,让AuthIntentController处理登出逻辑
    await authIntentController.handleLogoutIntent();
  }
  
  /// 导航到设置页面的意图
  void handleNavigateToSettingsIntent() {
    Get.toNamed('/settings');
  }
  
  /// 导航到编辑资料页面的意图
  void handleNavigateToEditProfileIntent() {
    Get.toNamed('/editProfile');
  }
  
  /// 加载统计数据的意图
  Future<void> handleLoadStatisticsIntent() async {
    // 业务逻辑：获取用户统计数据
    await UserManager.loadUserProfile();
  }
  
  /// 加载UGC内容的意图
  Future<void> handleLoadUGCContentIntent() async {
    // 业务逻辑：获取用户UGC内容
    await UserManager.loadUserProfile();
  }
}