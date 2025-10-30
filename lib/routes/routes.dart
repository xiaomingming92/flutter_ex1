/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-23 12:56:05
 * @LastEditors   : xmm wujixmm@gmail.com
 * @LastEditTime  : 2025-10-30 23:54:10
 * @FilePath      : /ex1/lib/routes/routes.dart
 * @Description   : 路由管理
 * 
 */

import "package:flutter/material.dart";

// import "../pages/HomePage.dart";
import "../pages/HomePage.custom.dart";
import 'package:get/get.dart';
import '../pages/LoginPage.dart';
import '../controller/auth_controller.dart';

class Routes {
  static const home = '/home';
  static const login = '/login';
  static const fedd = '/feed';
  static const gallery = 'gallery';
  static const post = '/post';
  static const message = '/message';
  static const profile = '.profile';
  
  // static final routes = <String, WidgetBuilder>{
  //   home: (context) => const HomePage(),
  // };
  static final List<GetPage> routes = [
    GetPage(name: login, page:  () => const LoginPage()),
    GetPage(
      name: home, 
      page:() => const HomePage(), 
      middlewares: [AuthMiddleware()]
    )
  ];
}

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final AuthController authController = Get.find<AuthController>();
    return authController.isLoggedIn.value ? null : RouteSettings(name: Routes.login);
    
  }
}
