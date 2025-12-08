/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-28 09:00:37
 * @LastEditors: Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime: 2025-12-08 11:21:19
 * @FilePath     : /ex1/lib/apis/auth.dart
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
  static Future login(String identifier, String passwd) async {
    final Map<String, String> params = {
      'identifier': identifier,
      'password': passwd,
    };
    print('params:::$params');
    final res = await Request.post('/auth/login', data: params);
    final resData = res.data;
    print('login response:::$resData');
    if (resData is Map && resData.containsKey('access_token') && resData.containsKey('refresh_token')) {
      await TokenManager.setTokens(resData['access_token'], resData['refresh_token']);
      return resData;
    }
    return null;
  }

  static Future refresh() async {
    final refreshToken = await TokenManager.refreshToken();
    return Request.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );
  }

  static void logOut() {
    TokenManager.clear();
  }
}
