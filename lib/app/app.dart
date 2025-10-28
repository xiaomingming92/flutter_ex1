/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-23 12:56:05
 * @LastEditors   : xmm wujixmm@gmail.com
 * @LastEditTime  : 2025-10-28 15:23:20
 * @FilePath      : /ex1/lib/app/app.dart
 * @Description   : 
 * 
 */
import "package:flutter/material.dart";

import "../routes/routes.dart";
import "../theme/theme.dart" show ThemeConfig;

/**
 * @description: 这个模块主要负责整体的应用结构：materialApp级别
 * @return {*}
 */
class App extends StatelessWidget {
  const App({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "flutter_ex1",
      routes: Routes.routes,
      initialRoute: Routes.home,
      debugShowCheckedModeBanner: false,
      theme: ThemeConfig.light,
    );
  }
}
