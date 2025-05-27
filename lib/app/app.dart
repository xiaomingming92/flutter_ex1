import "package:flutter/material.dart";

import "../routes/routes.dart";
import "../theme/theme.dart" show ThemeConfig;

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "flutter_ex1",
      initialRoute: Routes.home,
      routes: Routes.routes,
      debugShowCheckedModeBanner: false,
      theme: ThemeConfig.light,
    );
  }
}
