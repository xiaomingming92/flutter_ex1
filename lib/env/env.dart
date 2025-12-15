/*
 * @Author: Z2-WIN\xmm wujixmm@gmail.com
 * @Date: 2025-12-06 16:21:07
 * @LastEditors: Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime: 2025-12-15 14:33:59
 * @FilePath: \studioProjects\ex1\lib\env\env.dart
 * @Description: 环境配置
 */

import 'env.dev.dart';
import 'env.test.dart';
import 'env.uat.dart';
import 'env.prod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Environment {
  dev,
  test,
  uat,
  prod
}

class EnvConfig {
  final String baseUrl;
  final String envName;
  final int sucessCode;
  const EnvConfig({
    required this.baseUrl,
    required this.envName,
    required this.sucessCode,
  });
}

class Env {
  static late EnvConfig current;
  static void setEnv(Environment env) {
    switch(env) {
      case Environment.dev:
        current = devConfig;
        break;
      case Environment.test:
        current = testConfig;
        break;
      case Environment.uat:
        current = uatConfig;
        break;
      case Environment.prod:
        current = prodConfig;
        break;
    }
  }
}

class Envv2 {
  static late EnvConfig current;
  static final flavor = const String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  static final baseUrl = const String.fromEnvironment('BASE_URL', defaultValue: 'https://');
  
}