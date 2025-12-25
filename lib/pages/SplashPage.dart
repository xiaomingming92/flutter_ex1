/*
 * @Author       : Z2-WIN\xmm wujixmm@gmail.com
 * @Date         : 2025-12-25 09:21:19
 * @LastEditors  : Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime : 2025-12-25 16:41:19
 * @FilePath     : \ex1\lib\pages\SplashPage.dart
 * @Description  : 启动过渡页
 */

import 'package:ex1/env/env.dart';
import 'package:ex1/intent_controller/splash_intent_controller.dart';
import 'package:ex1/widgets/ad_widget.dart';
import 'package:ex1/widgets/splash_static_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final controller = Get.put(SplashIntentController());

  @override
  void initState() {
    super.initState();
    // _initSplash();
  }

  // Future<void> _initSplash() async {
  //   // do some work
  //   await Future.delayed(Duration(seconds: 2), () {
  //     Get.offAllNamed('/home');
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final devDebugSplash = Env.current.devDebugSplash;
    
    return Scaffold(
      body: Stack(
        children: [
          // 正常的启动页内容
          Obx(() {
            switch(controller.mode.value) {
              case SplashMode.static:
                return FirstScreenStatic();
              case SplashMode.ad:
                return AdWidget();
            }
          }),
          
          // 调试模式下显示控制按钮
          if (devDebugSplash == 'true') Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () => controller.manualNavigate(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('手动跳转', style: TextStyle(fontSize: 18),),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        controller.mode.value = SplashMode.static;
                      },
                      child: const Text('静态页'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        controller.mode.value = SplashMode.ad;
                      },
                      child: const Text('广告页'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}