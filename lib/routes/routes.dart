import "package:flutter/material.dart";

import "../pages/HomePage.dart";

class Routes {
  static const home = '/';
  static final routes = <String, WidgetBuilder>{
    home: (context) => const HomePage(),
  };
}
