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
import "../pages/FeedPage.dart";
import "../pages/GalleryPage.dart";
import "../pages/PostPage.dart";
import "../pages/Messages.dart";
import "../pages/ProfilePage.dart";
import 'package:get/get.dart';
import '../pages/LoginPage.dart';
import '../intent_controller/auth_intent_controller.dart';

class Routes {
  static const home = '/home';
  static const login = '/login';
  static const feed = '/feed';
  static const gallery = '/gallery';
  static const post = '/post/:userId'; // 这里很像navigator2.0
  static const message = '/message';
  static const profile = '/profile';

  static final List<GetPage> routes = [
    GetPage(name: login, page: () => const LoginPage()),
    GetPage(
      name: home,
      page: () => const HomePage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: feed,
      page: () => const FeedPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: gallery,
      page: () => const GalleryPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: post,
      page: () {
        final userId = int.parse(Get.parameters['userId'] ?? '0');
        return PostPage(userId: userId);
      },
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: message,
      page: () => const MessagePage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: profile,
      page: () => const ProfilePage(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final AuthIntentController authIntentController =
        Get.find<AuthIntentController>();
    return authIntentController.getLoginStatus()
        ? null
        : RouteSettings(name: Routes.login);
  }
}
