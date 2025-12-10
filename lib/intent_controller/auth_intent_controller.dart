/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-30 23:33:39
 * @LastEditors: Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime: 2025-12-10 11:41:42
 * @FilePath      : /ex1/lib/intent_controller/auth_intent.dart
 * @Description   : Auth Intent Controller - 处理用户认证相关的意图
 */
import 'package:get/get.dart';
import '../apis/auth.dart';
import '../network/token_manager.dart';

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
      return;
    }
    
    isLoggedIn.value = accessToken != null && refreshToken != null && refreshExpiresAt >= DateTime.now().millisecondsSinceEpoch;
  }

  Future<void> handleLoginIntent(String username, String passwd) async {
    try {
      // 直接获取包装后的响应数据（自动解析为DioResponseData<LoginRes>）
      final response = await AuthApi.login(username, passwd);
      final res = response.data;

      if(res == null) {
        Get.snackbar("登录失败", "响应数据为空");
        return;
      }
      // if (res.code != 200) {
      //   Get.snackbar("登录失败", res.message);
      //   return;
      // }
      
      // print('登录响应数据: $res');
      // print('登录响应data: ${res.data}');
      
      // 直接使用LoginRes类型的data
      // await TokenManager.setTokens(res);
      
      // isLoggedIn.value = true;
      // Get.offAllNamed('/home');
    } catch (e) {
      print('登录异常: $e');
      Get.snackbar("登录失败", e.toString());
    }
  }

  Future<void> handleLogoutIntent() async {
    await TokenManager.clear(); // 补充清除token逻辑
    isLoggedIn.value = false;
    Get.offAllNamed('/login');
  }

  bool getLoginStatus() {
    return isLoggedIn.value;
  }
}