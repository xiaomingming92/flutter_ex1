/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-23 12:56:05
 * @LastEditors: Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime: 2025-12-15 15:47:49
 * @FilePath      : /ex1/lib/main.dart
 * @Description   : 
 * 
 */

import 'package:ex1/env/env.dart';
import 'package:flutter/material.dart';
import 'app/app.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // 初始化Flutter binding
  // WidgetsFlutterBinding.ensureInitialized();
  
  // 加载.env文件
  // await dotenv.load(fileName: '.env.$flavor.local');
  // await dotenv.load(fileName: '.env.$flavor');
  // 最后加载默认的.env.local和.env文件
  // await dotenv.load(fileName: '.env.local');
  // await dotenv.load(fileName: '.env');
  
  setEnvFun();
  runApp(const App());
}

void setEnvFun() {
  const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'DEV');
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
