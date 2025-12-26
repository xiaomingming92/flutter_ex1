/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-12-26 10:00:00
 * @FilePath     : \ex1\lib\intent_controller\personal_center_intent_controller.dart
 * @Description   : 个人中心操作意图控制器
 */
import 'package:ex1/intent_controller/auth_intent_controller.dart';
import 'package:get/get.dart';
import '../network/user_manager.dart';

class PersonalCenterController extends GetxController {
  /// 用户中心操作意图控制：
  /// - 不直接维护GUI状态，GUI状态由Widget内部处理
  /// - 专注于业务意图的处理和触发
  
  // 不直接持有数据，通过 UserManager 获取
  UserInfo? get currentUser => UserManager.currentUser;
  AuthIntentController authIntentController = Get.find<AuthIntentController>();
  
  /// 加载用户信息的业务意图
  Future<void> handleLoadProfileIntent() async {
    // 业务逻辑：调用 UserManager 加载数据
    await UserManager.loadUserProfile();
    // GUI状态更新由Widget内部的State处理
  }
  
  /// 刷新用户信息的业务意图
  Future<void> handleRefreshProfileIntent() async {
    // 业务逻辑：刷新用户数据
    await UserManager.refreshUserProfile();
    // GUI状态更新由Widget内部的State处理
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