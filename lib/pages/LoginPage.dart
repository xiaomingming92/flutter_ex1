/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-28 15:24:07
 * @LastEditors   : xmm wujixmm@gmail.com
 * @LastEditTime  : 2025-10-28 15:30:06
 * @FilePath      : /ex1/lib/pages/LoginPage.dart
 * @Description   : 
 * 
 */
import 'package:flutter/material.dart';
import '../apis/index.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static Future doLogin() async {
    final userInfo = await UserApi.getUserInfo();
    print('userInfo: $userInfo');
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("登陆")),
        body: Center(child: ElevatedButton(onPressed: doLogin, child: Text("获取用户信息")))
      )
    );
  }
}