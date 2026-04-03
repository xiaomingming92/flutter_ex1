import 'package:flutter/services.dart';

class AdPlatformChannel {
  static const MethodChannel _channel = MethodChannel('com.example.ex1/ad');
  static const EventChannel _eventChannel = EventChannel('com.example.ex1/ad_events');

  // 广告加载
  static Future<Map<String, dynamic>> loadAd(String adId) async {
    return await _channel.invokeMethod('loadAd', {'adId': adId}) ?? {};
  }

  // 事件上报
  static Future<void> reportAdEvent(String event, Map<String, dynamic> params) async {
    await _channel.invokeMethod('reportEvent', {
      'event': event,
      'params': params,
    });
  }

  // 回调监听
  static void setOnAdLoaded(Function(Map<String, dynamic>) callback) {
    _eventChannel.receiveBroadcastStream('loaded').listen((data) {
      if (data is Map) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  static void setOnAdError(Function(String) callback) {
    _eventChannel.receiveBroadcastStream('error').listen((data) {
      if (data is String) {
        callback(data);
      }
    });
  }

  static void setOnAdClick(Function() callback) {
    _eventChannel.receiveBroadcastStream('click').listen((_) {
      callback();
    });
  }

  static void setOnAdClose(Function() callback) {
    _eventChannel.receiveBroadcastStream('close').listen((_) {
      callback();
    });
  }
}
