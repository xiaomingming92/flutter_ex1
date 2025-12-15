/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-23 12:56:05
 * @LastEditors: Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime: 2025-12-15 14:38:02
 * @FilePath      : /ex1/lib/app/app.dart
 * @Description   : 
 * 
 */
import "package:flutter/material.dart";
import "../routes/routes.dart";
import "../theme/theme.dart" show ThemeConfig;
import "package:get/get.dart";
import '../intent_controller/auth_intent_controller.dart';

/**
 * @description: 这个模块主要负责整体的应用结构：materialApp级别
 * @return {*}
 */
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AuthIntentController());

    return GetMaterialApp(
      title: "flutter_ex1",
      // routes: Routes.routes,
      initialRoute: Routes.home,
      getPages: Routes.routes,
      debugShowCheckedModeBanner: false,
      theme: ThemeConfig.light,
    );
  }
}
