/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-30 23:33:39
 * @LastEditors: Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime: 2025-12-10 09:58:39
 * @FilePath      : /ex1/lib/intent_controller/auth_intent.dart
 * @Description   : Auth Intent Controller - 处理用户认证相关的意图
 */
import 'package:get/get.dart';
import '../apis/auth.dart';
import '../network/token_manager.dart';
import '../network/dio.dart';

class AuthIntentController extends GetxController {
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  /**
   * @description   : 处理"检查登录状态"意图
   * @return         {*}
   */
  Future<void> _checkLoginStatus() async {
    final accessToken = await TokenManager.getAccessToken();
    final refreshToken = await TokenManager.getRefreshToken();
    final refreshExpiresAt = await TokenManager.getRefreshExpiresAt();
    
    if(accessToken == null || refreshToken == null || refreshExpiresAt == null) {
      isLoggedIn.value = false;
      return;
    }
    
    isLoggedIn.value = accessToken != null && refreshToken != null && refreshExpiresAt >= DateTime.now().millisecondsSinceEpoch;
  }

  /**
   * @description   : 处理"登录"意图
   * @return         {*}
   */
  Future<void> handleLoginIntent(String username, String passwd) async {
    try {
      final res = await AuthApi.login(username, passwd);
      
      if (res.code != 200) {
        Get.snackbar("登录失败", res.message);
        return;
      }
      
      print('登录响应数据: ${res}');
      print('登录响应data: ${res.data}');
      
      // res.data已经是LoginRes类型，可以直接使用
      await TokenManager.setTokens(res.data);
      
      isLoggedIn.value = true;
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar("登录失败", e.toString());
    }
  }

  /**
   * @description   : 处理"登出"意图
   * @return         {*}
   */
  Future<void> handleLogoutIntent() async {
    AuthApi.logOut();
    isLoggedIn.value = false;
    Get.offAllNamed('/login');
  }

  /**
   * @description   : 获取当前登录状态（供视图观察）
   * @return         {bool}
   */
  bool getLoginStatus() {
    return isLoggedIn.value;
  }
}
