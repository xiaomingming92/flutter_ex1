/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-28 15:24:07
 * @LastEditors   : xmm wujixmm@gmail.com
 * @LastEditTime  : 2025-10-31 00:02:13
 * @FilePath      : /ex1/lib/pages/LoginPage.dart
 * @Description   : 登录页
 * 
 */
import 'package:flutter/material.dart';
import '../apis/index.dart';
import 'package:get/get.dart';
import '../intent_controller/auth_intent_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static Future doLogin() async {
    final userInfo = await UserApi.getUserInfo();
    print('userInfo: $userInfo');
  }

  @override
  Widget build(BuildContext context) {
    final authIntentController = Get.put(AuthIntentController());
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("登录")),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: "用户名"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: '密码'),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => {
                authIntentController.handleLoginIntent(
                  usernameController.text,
                  passwordController.text,
                ),
              },
              child: Text("请登录"),
            ),
          ],
        ),
      ),
    );
  }
}
