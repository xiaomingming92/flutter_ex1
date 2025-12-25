/*
 * @Author: Z2-WIN\xmm wujixmm@gmail.com
 * @Date: 2025-12-06 16:21:07
 * @LastEditors: Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime: 2025-12-19 11:19:35
 * @FilePath: \studioProjects\ex1\lib\env\env.prod.dart
 * @Description: prod
 */
import 'env.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 延迟初始化配置，避免在模块加载时 dotenv 还未加载
EnvConfig get prodConfig {
  return EnvConfig(
    baseUrl: dotenv.env['BASE_URL'] ?? 'https://api.example.com',
    envName: dotenv.env['ENV_NAME'] ?? 'PROD',
    sucessCode: int.tryParse(dotenv.env['SUCCESS_CODE'] ?? '200') ?? 200,
    devDebugSplash: dotenv.env['DEV_DEBUG_SPLASH'] ?? 'false',
  );
}
