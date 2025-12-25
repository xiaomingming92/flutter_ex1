package com.example.ex1

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() 
// {
//     override fun onCreate(savedInstanceState: android.os.Bundle?) {
//         // 针对 Android 12+（API31+，含API36）禁用系统启动屏
//         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//             // 安装 splash screen 并立即隐藏
//             val splashScreen = installSplashScreen()
//             // 强制系统启动屏不显示（直接进入 Flutter 渲染）
//             splashScreen.setKeepOnScreenCondition { false }
//         }
//         super.onCreate(savedInstanceState)
//     }
// }
