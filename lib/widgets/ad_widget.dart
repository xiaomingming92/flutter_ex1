import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../intent_controller/splash_intent_controller.dart';

class AdWidget extends StatefulWidget {
  const AdWidget({super.key});

  @override
  State<AdWidget> createState() => _AdWidgetState();
}

class _AdWidgetState extends State<AdWidget> {
  final controller = Get.find<SplashIntentController>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.wallet_giftcard, size: 100),
              SizedBox(height: 20),
              Text('广告页占位', style: TextStyle(fontSize: 24)),
            ],
          ),
        ),
        Positioned(
          top: 50,
          right: 20,
          child: Obx(() {
            return ElevatedButton(
              onPressed: controller.adCountdown.value > 0 
                ? controller.skipAd 
                : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.adCountdown.value > 0 
                  ? Colors.grey 
                  : Colors.blue,
              ),
              child: Text(
                controller.adCountdown.value > 0 
                  ? '跳过 ${controller.adCountdown.value}s' 
                  : '跳过',
                style: TextStyle(color: Colors.white),
              ),
            );
          }),
        ),
      ],
    );
  }
}