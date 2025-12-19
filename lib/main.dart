/*
 * @Author: Z2-WIN\xmm wujixmm@gmail.com
 * @Date: 2025-12-06 16:21:07
 * @LastEditors: Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime: 2025-12-19 11:02:06
 * @FilePath: \studioProjects\ex1\lib\main.dart
 * @Description: 主入口文件
 */
import './env/env.dart';
import 'package:flutter/material.dart';
import 'app/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // 初始化Flutter binding
  WidgetsFlutterBinding.ensureInitialized();
  
  // 获取当前环境
  const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  // 加载.env文件，注意顺序：越后面加载的文件优先级越高
  // 加载当前环境的.env.$flavor文件
  await dotenv.load(fileName: '.env.$flavor');
  // 加载当前环境的.env.$flavor.local文件（优先级最高）
  if(flavor == 'dev') {
    await dotenv.load(fileName: '.env.$flavor.local');
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
