/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-23 12:56:05
 * @LastEditors: Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime: 2025-12-26 11:00:00
 * @FilePath: \studioProjects\ex1\lib\routes\routes.dart
 * @Description   : 路由管理
 * 
 */

import "package:flutter/material.dart";
import '../intent_controller/auth_intent_controller.dart';

// import "../pages/HomePage.dart";
import "../pages/HomePage.custom.dart";
// import "../pages/HomePage.tabcontroller.dart";
import "../pages/FeedPage.dart";
import "../pages/GalleryPage1.dart";
import "../pages/PostPage1.dart";
import "../pages/Messages.dart";
import "../pages/PersonalCenterPage.dart";
import "../pages/SettingsPage.dart";
import "../pages/AboutPage.dart";
import "../widgets/dialogs/VersionCheckDialog.dart";
import "../widgets/dialogs/DownloadProgressDialog.dart";
import 'package:get/get.dart';
import '../pages/LoginPage.dart';
import '../pages/SplashPage.dart';
import '../pages/MediaPlayPage.dart';
class Routes {
  static const home = '/home';
  static const login = '/login';
  static const feed = '/feed';
  static const gallery = '/gallery';
  static const post = '/post/:userId'; // 这里很像navigator2.0
  static const message = '/message';
  static const profile = '/profile';
  static const personalCenter = '/personalCenter';
  static const settings = '/settings';
  static const about = '/about';
  static const versionCheck = '/versionCheck';
  static const downloadProgress = '/downloadProgress';
  static const accountSecurity = '/accountSecurity';
  static const generalSettings = '/generalSettings';
  static const notificationSettings = '/notificationSettings';
  static const privacySettings = '/privacySettings';
  static const help = '/help';
  static const editProfile = '/editProfile';
  static const splash = '/splash';
  static const mediaplay = '/MediaPlayPage';

  static final List<GetPage> routes = [
    GetPage(name: splash, page: () => const SplashPage()),
    GetPage(name: login, page: () => const LoginPage()),
    GetPage(
      name: home,
      page: () => const HomePage(),
      // page: () => const HomePageTabController(),
      // middlewares: [AuthMiddleware()],
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: feed,
      page: () => const FeedPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: gallery,
      page: () => const GalleryPage1(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: post,
      page: () {
        // final userId = Get.parameters['userId'] ?? '0';
        return PostPage1();
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
      page: () => const PersonalCenterPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: personalCenter,
      page: () => const PersonalCenterPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: settings,
      page: () => const SettingsPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: about,
      page: () => const AboutPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: versionCheck,
      page: () => const VersionCheckDialog(),
    ),
    GetPage(
      name: downloadProgress,
      page: () => const DownloadProgressDialog(),
    ),
    GetPage(
      name: accountSecurity,
      page: () => const SettingsPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: generalSettings,
      page: () => const SettingsPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: notificationSettings,
      page: () => const SettingsPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: privacySettings,
      page: () => const SettingsPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: help,
      page: () => const SettingsPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: editProfile,
      page: () => const SettingsPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: mediaplay,
      page: () => const MediaPlayPage(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}

/**
 * @description  : 认证中间件，用于判断用户是否登录
 * @return        {*}
 */
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // 只有在 AuthIntentController 已经初始化的情况下才进行检查
    if (Get.isRegistered<AuthIntentController>()) {
      final AuthIntentController authIntentController = Get.find<AuthIntentController>();
      return authIntentController.getLoginStatus()
          ? null
          : RouteSettings(name: Routes.login);
    }
    // 未初始化时不进行重定向检查
    return null;
  }
}
