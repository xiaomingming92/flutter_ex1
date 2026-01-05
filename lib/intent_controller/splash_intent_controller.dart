/*
 * @Author       : Z2-WIN\xmm wujixmm@gmail.com
 * @Date         : 2025-12-25 09:39:27
 * @LastEditors  : Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime : 2025-12-25 18:00:09
 * @FilePath     : \ex1\lib\intent_controller\splash_intent_controller.dart
 * @Description  : 处理启动页意图
 */
import 'dart:async';
import 'package:ex1/env/env.dart';
import 'package:ex1/network/user_manager.dart';
import 'package:get/get.dart';
import 'auth_intent_controller.dart';

enum SplashMode {
  static,  // 静态启动页
  ad,      // 广告页
}

class SplashIntentController extends GetxController {
  final Rx<SplashMode> mode = SplashMode.static.obs;
  final RxBool canNavigate = false.obs;
  final RxInt adCountdown = 5.obs;
  DateTime? _adStartTime;
  DateTime? _adEndTime;
  static const int _adDurationSeconds = 5;
  final RxBool _isSkiped = false.obs;
  @override
  void onInit() {
    super.onInit(); 

    // 判断展示模式
    _decideSplashMode();
  }
  
  @override
  void dispose() {
    //
    super.dispose();
  }
  
  Future<void> _decideSplashMode() async {

    final mode = await _computeSplashMode();

    this.mode.value = mode;
    
    // 检查是否开启调试模式
    final devDebugSplash = Env.current.devDebugSplash;
    if (devDebugSplash == 'true') {
      // 调试模式：不自动跳转，允许手动控制
      canNavigate.value = false;
      return;
    }
    
    // 正常模式：根据模式决定何时允许跳转
    if (mode == SplashMode.static) {
      // 静态模式：等待 AuthIntentController 完成检查后立即跳转
  
      _waitForAuthCheck();
    } else {
      // 广告模式：等待倒计时结束或用户关闭广告
  
      _startAdCountdown();
    }
  }
  
  Future<SplashMode> _computeSplashMode() async {
    final userInfo = await UserManager.getUserInfoAsync();
    
    // 1. 检查是否首次登录
    if (userInfo == null || userInfo.isEmpty) {
      return SplashMode.ad;  // 无用户信息，强制展示广告
    }
    
    final isNewUser = userInfo['isNewUser'] ?? false;
    if (isNewUser) {
      return SplashMode.ad;  // 首次登录，强制展示广告
    }
    
    // 2. 检查是否有 VIP 权限
    final permissions = userInfo['permissions'] as List<dynamic>?;
    if (permissions == null || permissions.isEmpty) {
      return SplashMode.static;  // 无权限列表，展示静态页
    }
    
    // 3. 检查是否有 vip.splash.showAd 权限
    final hasShowAdPermission = permissions.contains('vip.splash.showAd');
    
    return hasShowAdPermission ? SplashMode.ad : SplashMode.static;
  }
  
  void _waitForAuthCheck() {
    // 确保 AuthIntentController 已初始化
    final authCtl = Get.find<AuthIntentController>();
    final currentColdStart = authCtl.isColdStart.value;

    
    // 如果认证检查已经完成（冷启动状态已经是 false），立即跳转
    if (!currentColdStart) {

      canNavigate.value = true;
      _navigateToTarget();
      return;
    }
    
    // 使用 GetX 响应式监听，isColdStart 现在已经是 RxBool

    ever(authCtl.isColdStart, (value) {

      if (!value) {
        // 检查完成，允许跳转

        canNavigate.value = true;
        _navigateToTarget();
      }
    });
  }
  
  void _startAdCountdown() async {
    _adStartTime = DateTime.now();
    _adEndTime = _adStartTime?.add(Duration(seconds: _adDurationSeconds));

    while (_adEndTime?.isAfter(DateTime.now()) ?? false) {
      final remainingSeconds = _adEndTime!.difference(DateTime.now()).inSeconds;
      adCountdown.value = remainingSeconds;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    _onAdFinished();
  }
  
  void skipAd() {
    // 用户手动跳过广告
    if (_isSkiped.value) return; // 防止多次调用
    _isSkiped.value = true;
    _onAdFinished();
  }
  
  void _onAdFinished() {
    canNavigate.value = true;
    _navigateToTarget();
  }
  
  // 添加手动跳转方法供调试使用
  void manualNavigate() {
    _navigateToTarget(manual: true);
  }

  void _navigateToTarget({bool manual = false}) {
    // 检查是否开启调试模式
    final devDebugSplash = Env.current.devDebugSplash;
    if (devDebugSplash == 'true' && !manual) {
      // 调试模式：不自动跳转.但是手动点击还是可以跳转
      if(!_isSkiped.value) {
        canNavigate.value = false;
        return;
      }
    }
    // 确保 AuthIntentController 已初始化
    final authController = Get.find<AuthIntentController>();
    final isLoggedIn = authController.isLoggedIn.value;

    
    if (isLoggedIn) {

      Get.offAllNamed('/home');
    } else {

      Get.offAllNamed('/login');
    }
  }
}
