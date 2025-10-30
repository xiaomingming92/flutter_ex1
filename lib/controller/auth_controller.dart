/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-30 23:33:39
 * @LastEditors   : xmm wujixmm@gmail.com
 * @LastEditTime  : 2025-10-30 23:43:22
 * @FilePath      : /ex1/lib/controller/auth_controller.dart
 * @Description   : 
 * 
 */
import 'package:get/get.dart';
import '../apis/auth.dart';
import '../network/token_manager.dart';

class AuthController  extends GetxController{
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  /**
   * @description   : 检查登录状态
   * @return         {*}
   */
  Future <void> checkLoginStatus() async {
    final token = await TokenManager.getAccessToken();
    isLoggedIn.value = token != null;
  }

  /**
   * @description   : 登录
   * @return         {*}
   */
  Future<void> login(String username, String passwd) async {
    try {
      final res = await AuthApi.login(username, passwd);
      if(res) {
        isLoggedIn.value = true;
        Get.offAllNamed('/home');
      }
    } catch(e) {
      Get.snackbar("登录失败: ", e.toString());
    }
  }

  /**
   * @description   : 登出
   * @return         {*}
   */
  Future<void> logout() async {
     AuthApi.logOut();
    isLoggedIn.value = false;
    Get.offAllNamed('/login');
  }
}