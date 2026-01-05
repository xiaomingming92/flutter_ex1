/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-30 23:33:39
 * @LastEditors  : Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime : 2026-01-05 16:48:27
 * @FilePath     : \ex1\lib\intent_controller\auth_intent_controller.dart
 * @Description   : Auth Intent Controller - 处理用户认证相关的意图
 */
import 'package:ex1/env/env.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../apis/auth.dart';
import '../apis/user.dart';
import '../network/token_manager.dart';
import '../network/user_manager.dart';



class AuthIntentController extends GetxController {
  // 单例模式
  static AuthIntentController getInstance() {
    if (Get.isRegistered<AuthIntentController>()) {
      return Get.find<AuthIntentController>();
    } else {
      return Get.put(AuthIntentController());
    }
  }
  
  final RxBool isLoggedIn = false.obs;
  final RxBool isColdStart = true.obs;  // 改为响应式变量，支持 GetX 监听
  bool _shouldPreventNavigation = false;
  AppLifecycleListener? _lifeHookListener;
  @override
  void onInit() {
    super.onInit();

    // 检测热重载
    if(Env.current.envName == 'dev') {
      _detectHotReload();
    }
    // 初始化时检查登录状态
    _checkLoginStatus();
    // 恢复前台时检查登录状态
    _setupLifeHookListener();
    // 监听登录状态变化
    _watchLoggedIn();
  }
  
  void _detectHotReload() {
    // 如果控制器已经被实例化过，说明是热重载
    if (Get.isRegistered<AuthIntentController>()) {
      _shouldPreventNavigation = true;

      // 3秒后允许正常导航（给热重载足够的时间完成）
      Future.delayed(const Duration(seconds: 3), () {
        _shouldPreventNavigation = false;
      });
    }
  }
  @override
  void dispose() {
    // 移除生命周期监听
    _lifeHookListener?.dispose();
    super.dispose();
  }
  void _setupLifeHookListener() {
    _lifeHookListener = AppLifecycleListener(
      onStateChange: _handleStateChange,
    );
  }
  void _handleStateChange(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLoginStatus();
    }
  }
  void _watchLoggedIn() {
    ever(isLoggedIn, (value) {
      if (isColdStart.value) {
        // 冷启动时不跳转，由 SplashIntentController 控制跳转
        return;
      } else if (_shouldPreventNavigation) {
        // 热重载期间不执行跳转
        return;
      } else if (Env.current.devDebugSplash == 'true') {
        // 调试模式下不执行跳转
        return;
      } else {
        if (!value) {
          // 获取当前路由
          final currentRoute = Get.currentRoute;
          // 检查当前是否已经在登录页，避免重复跳转
          if (currentRoute == '/login') {
            return;
          }
          // 检查是否在豁免页面（不需要登录的页面）
          final exemptRoutes = ['/register', '/forgot_password', '/splash'];
          if (exemptRoutes.contains(currentRoute)) {
            return;
          }
          // 执行跳转
          Get.offAllNamed('/login');
        } else {

        }
      }
    });
  }
  Future<void> _checkLoginStatus() async {

    
    final [accessToken, refreshToken, refreshExpiresAt] = await Future.wait([
      TokenManager.getAccessToken(),
      TokenManager.getRefreshToken(),
      TokenManager.getRefreshExpiresAt(),
    ]);
    

    
    if ([accessToken, refreshToken, refreshExpiresAt].any((e) => e == null)) {

      isLoggedIn.value = false;
      await UserManager.clear();
      isColdStart.value = false;
      return;
    }

    final isValid = (refreshExpiresAt as int) >= DateTime.now().millisecondsSinceEpoch;

    
    isLoggedIn.value = isValid;
    isColdStart.value = false;
    // 此处放弃副作用
    // 如果token有效，尝试恢复用户信息缓存
    if (isValid && !UserManager.hasUserInfo() && UserManager.currentUser?.id != null) {
      // try {
      //   final userInfo = await UserApi.getUserInfo();
      //   final userInfoData = userInfo.data?.data;
      //  if (userInfoData != null) {
      //     await UserManager.setUserInfo(userInfoData);
      //   }
      // } catch (e) {
      //   // 获取用户信息失败，不影响登录状态检查
      // }
    }
    

  }

  Future<void> handleLoginIntent(String username, String passwd) async {
    try {
      // 直接获取包装后的响应数据（自动解析为DioResponseData<LoginRes>）
      final response = await AuthApi.login(username, passwd);

      // 直接使用LoginRes类型的data，已经自动转换，无需断言和属性非空判断
      final loginData = response.data;
      if (loginData != null) {
        await TokenManager.setTokens(loginData);

        // 优先从登录响应中获取用户信息
        await UserManager.setUserKeyInfoFromLogin(loginData.userKeyInfo);

        // 如果登录响应中没有用户信息，则调用API获取
        if (!UserManager.hasUserInfo()) {
          try {
            final userInfo = await UserApi.getUserInfoMap();
            final userInfoData = userInfo.data;
            if (userInfoData != null) {
              await UserManager.setUserInfo(userInfoData);
            }
          } catch (e) {
            // 即使获取用户信息失败，也不影响登录流程
          }
        }

        isLoggedIn.value = true;
        Get.offAllNamed('/home');
      } else {
        Get.snackbar("登录失败", "登录数据为空");
      }
    } catch (e) {
      // print('登录异常: $e');
      Get.snackbar("登录失败", e.toString());
    }
  }

  Future<void> handleLogoutIntent() async {
    await TokenManager.clear();
    await UserManager.clear();
    isLoggedIn.value = false;
    Get.offAllNamed('/login');
  }

  bool getLoginStatus() {
    return isLoggedIn.value;
  }

  Future<void> handleSendCodeIntent(String phone) async {
    try {
      final response = await AuthApi.sendCode(phone);
      if (response.data != null) {
        Get.snackbar("成功", "验证码已发送");
      } else {
        throw Exception("发送验证码失败");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> handleSmsLoginIntent(String phone, String code) async {
    try {
      final response = await AuthApi.smsLogin(phone, code);
      final loginData = response.data;
      if (loginData != null) {
        await TokenManager.setTokens(loginData);

        await UserManager.setUserKeyInfoFromLogin(loginData.userKeyInfo);

        if (!UserManager.hasUserInfo()) {
          try {
            final userInfo = await UserApi.getUserInfoMap();
            final userInfoData = userInfo.data;
            if (userInfoData != null) {
              await UserManager.setUserInfo(userInfoData);
            }
          } catch (e) {
            // 获取用户信息失败，但不影响登录流程
          }
        }

        isLoggedIn.value = true;
        Get.offAllNamed('/home');
      } else {
        Get.snackbar("登录失败", "登录数据为空");
      }
    } catch (e) {
      rethrow;
    }
  }
}
