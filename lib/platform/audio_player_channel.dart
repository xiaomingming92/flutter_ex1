import 'package:flutter/services.dart';

class AudioPlayerChannel {
  static const MethodChannel _channel = MethodChannel('com.example.ex1/audio');
  static const EventChannel _eventChannel = EventChannel('com.example.ex1/audio_events');

  // 音频控制
  static Future<void> play(String url) async {
    await _channel.invokeMethod('play', {'url': url});
  }

  static Future<void> pause() async {
    await _channel.invokeMethod('pause');
  }

  static Future<void> resume() async {
    await _channel.invokeMethod('resume');
  }

  static Future<void> stop() async {
    await _channel.invokeMethod('stop');
  }

  static Future<void> seekTo(int position) async {
    await _channel.invokeMethod('seek', {'position': position});
  }

  static Future<void> skipToNext() async {
    await _channel.invokeMethod('skipToNext');
  }

  static Future<void> skipToPrevious() async {
    await _channel.invokeMethod('skipToPrevious');
  }

  // 播放列表
  static Future<void> setPlaylist(List<String> urls) async {
    await _channel.invokeMethod('setPlaylist', {'urls': urls});
  }

  // 状态查询
  static Future<bool> isPlaying() async {
    return await _channel.invokeMethod('isPlaying') ?? false;
  }

  static Future<int> getCurrentPosition() async {
    return await _channel.invokeMethod('getCurrentPosition') ?? 0;
  }

  static Future<int> getDuration() async {
    return await _channel.invokeMethod('getDuration') ?? 0;
  }

  static Future<Map<String, dynamic>?> getCurrentSong() async {
    return await _channel.invokeMethod('getCurrentSong');
  }

  // 悬浮窗控制
  static Future<void> showSystemFloatingWindow(Map<String, dynamic> state) async {
    await _channel.invokeMethod('showSystemFloatingWindow', state);
  }

  static Future<void> hideSystemFloatingWindow() async {
    await _channel.invokeMethod('hideSystemFloatingWindow');
  }

  static Future<Map<String, dynamic>> getSystemFloatingWindowState() async {
    return await _channel.invokeMethod('getSystemFloatingWindowState') ?? {};
  }

  // 回调监听
  static void setOnPositionUpdate(Function(int) callback) {
    _eventChannel.receiveBroadcastStream('position').listen((data) {
      if (data is int) {
        callback(data);
      }
    });
  }

  static void setOnStateChange(Function(String) callback) {
    _eventChannel.receiveBroadcastStream('state').listen((data) {
      if (data is String) {
        callback(data);
      }
    });
  }

  static void setOnSongComplete(Function() callback) {
    _eventChannel.receiveBroadcastStream('complete').listen((_) {
      callback();
    });
  }

  static void setOnSongChange(Function(Map<String, dynamic>) callback) {
    _eventChannel.receiveBroadcastStream('songChange').listen((data) {
      if (data is Map) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }
}
