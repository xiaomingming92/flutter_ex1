/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-23 12:56:05
 * @LastEditors   : xmm wujixmm@gmail.com
 * @LastEditTime  : 2025-10-28 15:23:03
 * @FilePath      : /ex1/lib/main.dart
 * @Description   : 
 * 
 */

import 'package:ex1/config/env.dart';
import 'package:flutter/material.dart';
import 'app/app.dart';

void main() {
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
