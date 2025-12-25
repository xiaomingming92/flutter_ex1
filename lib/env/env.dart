
import 'package:ex1/env/env.dev.dart';
import 'package:ex1/env/env.test.dart';
import 'package:ex1/env/env.uat.dart';
import 'package:ex1/env/env.prod.dart';
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
  final String devDebugSplash;
  EnvConfig({
    required this.baseUrl,
    required this.envName,
    required this.sucessCode,
    required this.devDebugSplash,
  });
}

class Env {
  static late EnvConfig current;
  static void setEnv(Environment env) {
    // 首先获取基础配置
    EnvConfig baseConfig;
    switch(env) {
      case Environment.dev:
        baseConfig = devConfig;
        break;
      case Environment.test:
        baseConfig = testConfig;
        break;
      case Environment.uat:
        baseConfig = uatConfig;
        break;
      case Environment.prod:
        baseConfig = prodConfig;
        break;
    }
    
    // 优先从dotenv获取环境变量，如果没有则使用基础配置
    current = EnvConfig(
      baseUrl: dotenv.env['BASE_URL'] ?? baseConfig.baseUrl,
      envName: dotenv.env['ENV_NAME'] ?? baseConfig.envName,
      sucessCode: int.tryParse(dotenv.env['SUCCESS_CODE'] ?? '') ?? baseConfig.sucessCode,
      devDebugSplash: dotenv.env['DEV_DEBUG_SPLASH'] ?? baseConfig.devDebugSplash,
    );
  }
  
  // 直接从dotenv获取环境变量的快捷方法
  static String getString(String key, {String defaultValue = ''}) {
    return dotenv.env[key] ?? defaultValue;
  }
  
  static int getInt(String key, {int defaultValue = 0}) {
    return int.tryParse(dotenv.env[key] ?? '') ?? defaultValue;
  }
  
  static bool getBool(String key, {bool defaultValue = false}) {
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true' || value == '1';
  }
}