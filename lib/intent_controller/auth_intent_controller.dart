/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-30 23:33:39
 * @LastEditors: Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime: 2025-12-15 10:54:30
 * @FilePath     : \ex1\lib\intent_controller\auth_intent_controller.dart
 * @Description   : Auth Intent Controller - 处理用户认证相关的意图
 */
import 'package:get/get.dart';
import '../apis/auth.dart';
import '../apis/user.dart';
import '../network/token_manager.dart';
import '../network/user_manager.dart';

class AuthIntentController extends GetxController {
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final accessToken = await TokenManager.getAccessToken();
    final refreshToken = await TokenManager.getRefreshToken();
    final refreshExpiresAt = await TokenManager.getRefreshExpiresAt();
    
    if(accessToken == null || refreshToken == null || refreshExpiresAt == null) {
      isLoggedIn.value = false;
      await UserManager.clear();
      return;
    }
    
    final isValid = accessToken != null && refreshToken != null && refreshExpiresAt >= DateTime.now().millisecondsSinceEpoch;
    isLoggedIn.value = isValid;
    
    // 如果token有效，尝试恢复用户信息缓存
    if (isValid && !UserManager.hasUserInfo()) {
      try {
        final userInfo = await UserApi.getUserInfo();
        if (userInfo.isNotEmpty) {
          await UserManager.setUserInfo(userInfo);
        }
      } catch (e) {
        print('Failed to restore user info: $e');
      }
    }
  }

  Future<void> handleLoginIntent(String username, String passwd) async {
    try {
      // 直接获取包装后的响应数据（自动解析为DioResponseData<LoginRes>）
      final response = await AuthApi.login(username, passwd);
      
      // 直接使用LoginRes类型的data，已经自动转换，无需断言和属性非空判断
      final loginData = response.data;
      if(loginData != null) {
        await TokenManager.setTokens(loginData);
        
        // 优先从登录响应中获取用户信息
        await UserManager.setUserInfoFromLogin(loginData.userInfo);
        
        // 如果登录响应中没有用户信息，则调用API获取
        if (!UserManager.hasUserInfo()) {
          try {
            final userInfo = await UserApi.getUserInfo();
            if (userInfo.isNotEmpty) {
              await UserManager.setUserInfo(userInfo);
            }
          } catch (e) {
            print('Failed to get user info: $e');
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
}