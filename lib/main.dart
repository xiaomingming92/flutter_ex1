/*
 * @Author       : Z2-WIN\xmm wujixmm@gmail.com
 * @Date         : 2025-12-06 16:21:07
 * @LastEditors  : Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime : 2025-12-25 19:02:49
 * @FilePath     : \ex1\lib\main.dart
 * @Description  : 项目入口
 */

import 'dart:io';

import './env/env.dart';
import 'package:flutter/material.dart';
import 'app/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // 初始化Flutter binding
  WidgetsFlutterBinding.ensureInitialized();
  
  // 获取当前环境
  const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev'); 
  // 获取编译时传递的BASE_URL参数
  const baseUrlFromCompile = String.fromEnvironment('BASE_URL');
  // print('Flavor from compile-time: $flavor');
  // print('BaseUrl from compile-time: $baseUrlFromCompile');
  
  // 加载当前环境的.env.$flavor文件
  try {
    await dotenv.load(fileName: '.env.$flavor');
    // 将编译时参数注入到dotenv环境变量中
    if (baseUrlFromCompile.isNotEmpty) {
      dotenv.env['BASE_URL'] = baseUrlFromCompile;
    }
    // print('Loaded environment variables:');
    // print('DEV_DEBUG_SPLASH: ${dotenv.env['DEV_DEBUG_SPLASH']}');
    // print('BASE_URL: ${dotenv.env['BASE_URL']}');
  } catch (e) {
    // .local 文件不存在时忽略错误（这是正常的，用于本地配置覆盖）
    print('Error loading .env files: $e');
  }

  setEnvFun();
  runApp(const App());
}

void setEnvFun() {
  const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  switch (flavor) {
    case 'test':
      {
        Env.setEnv(Environment.test);
        break;
      }
    case 'uat':
      Env.setEnv(Environment.uat);
      break;
    case 'prod':
      Env.setEnv(Environment.prod);
      break;
    default:
      Env.setEnv(Environment.dev);
      break;
  }
}
