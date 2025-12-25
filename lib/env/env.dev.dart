/*
 * @Author: Z2-WIN\xmm wujixmm@gmail.com
 * @Date: 2025-12-06 16:21:07
 * @LastEditors: Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime: 2025-12-19 11:18:58
 * @FilePath: \studioProjects\ex1\lib\env\env.dev.dart
 * @Description: 开发环境配置
 */
import 'env.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 延迟初始化配置，避免在模块加载时 dotenv 还未加载
EnvConfig get devConfig {
  return EnvConfig(
    baseUrl: String.fromEnvironment("BASE_URL") ?? 'http://10.0.2.2:3000/ex1/api',
    envName: dotenv.env['ENV_NAME'] ?? 'DEV',
    sucessCode: int.tryParse(dotenv.env['SUCCESS_CODE'] ?? '200') ?? 200,
    devDebugSplash: dotenv.env['DEV_DEBUG_SPLASH'] ?? 'false',
  );
}
