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

final devConfig = EnvConfig(
  baseUrl: dotenv.get('BASE_URL'),
  envName: dotenv.get('ENV_NAME'),
  sucessCode: int.parse(dotenv.get('SUCCESS_CODE')),
);
