import 'env.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 延迟初始化配置，避免在模块加载时 dotenv 还未加载
EnvConfig get testConfig {
  return EnvConfig(
    baseUrl: dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:3000/ex1/api',
    envName: dotenv.env['ENV_NAME'] ?? 'TEST',
    sucessCode: int.tryParse(dotenv.env['SUCCESS_CODE'] ?? '200') ?? 200,
    devDebugSplash: dotenv.env['DEV_DEBUG_SPLASH'] ?? 'false',
  );
}
