/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-28 09:00:43
 * @LastEditors   : xmm wujixmm@gmail.com
 * @LastEditTime  : 2025-10-28 15:18:00
 * @FilePath      : /ex1/lib/apis/user.dart
 * @Description   : 用户接口
 * 
 */
import '../network/request.dart';

class UserApi {
  static Future getUserInfo() async {
    final res = await Request.get('/user/info', );
    return res.data;
  }

  static Future updateInfo(Map<String, dynamic> info) async {
    final res = await Request.put('/usr/info', data: info);
    return res;
  }
}