/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-28 09:00:43
 * @LastEditors  : Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime : 2025-12-23 16:07:24
 * @FilePath     : \ex1\lib\apis\user.dart
 * @Description   : 用户接口
 * 
 */
import '../network/request.dart';

class UserApi {
  static Future<Map<String, dynamic>> getUserInfo() async {
    final res = await Request.get('/user/info');
    return res.data as Map<String, dynamic>;
  }

  /// 获取完整手机号
  static Future<String> getRealPhoneNumber() async {
    final res = await Request.get('/user/realphone');
    return res.data as String;
  }

  static Future updateInfo(Map<String, dynamic> info) async {
    final res = await Request.put('/usr/info', data: info);
    return res;
  }
}