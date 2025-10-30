/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-28 09:00:37
 * @LastEditors   : xmm wujixmm@gmail.com
 * @LastEditTime  : 2025-10-30 23:42:58
 * @FilePath      : /ex1/lib/apis/auth.dart
 * @Description   : 
 * 
 */
import '../network/request.dart';
import '../network/token_manager.dart';

class AuthApi {
  // /**
  //  * @description   : 登录
  //  * @return         {*}
  //  */
  static Future login(String username, String passwd) async {
    final Map<String, String> params = {
      'username': username,
      'password': passwd
    };
    final res = await Request.post('/auth/login', data: params);
    final resData = res.data;
    if(resData) {
      await TokenManager.setTokens(resData.access_token, resData.refresh_token);
      return resData;
    }
  }

  static Future refresh() async {
    return Request.post('/auth/refresh', data: {
      'refresh_token': await TokenManager.refreshToken()
    });
  }

  static void logOut() {
    TokenManager.clear();
  }
}