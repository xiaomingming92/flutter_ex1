/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-24 10:27:21
 * @LastEditors   : xmm wujixmm@gmail.com
 * @LastEditTime  : 2025-10-31 00:09:23
 * @FilePath      : /ex1/lib/pages/ProfilePage.dart
 * @Description   : 个人中心页
 * 
 */
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';

class ProfilePage extends StatefulWidget{ 
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("个人中心"),
          ElevatedButton(
            onPressed: () => authController.logout(),
            child: Text("登出")
          )
        ],
      )
    );
  }
}