# 媒体播放功能架构设计文档

## 1. 概述

### 1.1 目标
实现一个完整的媒体播放系统，支持：
- 完整的媒体库列表
- 独立的播放组件
- 双模式悬浮窗（应用内 + 系统级）
- 全局播放状态管理
- 前后台状态保持
- 跨页面跳转指定播放

### 1.2 技术栈
- **状态管理**: GetX
- **音频播放**: audioplayers + AIDL 服务
- **跨平台通信**: Platform Channel (MethodChannel + EventChannel)
- **后台播放**: Android Service + AIDL
- **悬浮窗**: 应用内 Flutter Widget + 系统级 WindowManager

---

## 2. 架构设计

### 2.1 整体架构

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Flutter 层                                      │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         UI 层                                        │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌────────────┐ │   │
│  │  │  广告页     │  │  媒体库页    │  │  播放页      │  │ 其他页面    │ │   │
│  │  │  (AdPage)   │  │  (Library)  │  │  (Player)   │  │            │ │   │
│  │  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └─────┬──────┘ │   │
│  │         │                │                │               │        │   │
│  │         └────────────────┴────────────────┴───────────────┘        │   │
│  │                              │                                      │   │
│  │                              ▼                                      │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │              AudioPlayerController (GetX)                   │   │   │
│  │  │  - 播放状态管理                                              │   │   │
│  │  │  - 悬浮窗状态管理                                            │   │   │
│  │  │  - 生命周期监听                                              │   │   │
│  │  └──────────────────────────┬──────────────────────────────────┘   │   │
│  │                             │                                       │   │
│  │  ┌──────────────────────────┴──────────────────────────────────┐   │   │
│  │  │              InAppFloatingWindow (应用内悬浮窗)              │   │   │
│  │  │  - 可拖拽                                                    │   │   │
│  │  │  - 2档模式（完整/迷你）                                       │   │   │
│  │  │  - 状态管理（位置、模式）                                     │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│  ┌─────────────────────────────────┴─────────────────────────────────────┐ │
│  │                      Platform Channel 层                               │ │
│  │  ┌─────────────────────────┐  ┌─────────────────────────────────────┐ │ │
│  │  │  AudioPlayerChannel     │  │  AdPlatformChannel                  │ │ │
│  │  │  - 音频控制              │  │  - 广告加载/展示                     │ │ │
│  │  │  - 悬浮窗控制            │  │  - 事件上报                          │ │ │
│  │  │  - 状态同步              │  │                                     │ │ │
│  │  └─────────────────────────┘  └─────────────────────────────────────┘ │ │
│  └───────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
                                            │
                                            │ MethodChannel / EventChannel
                                            ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Android 原生层                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    MainActivity (FlutterActivity)                   │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │              PlatformChannelPlugin                           │   │   │
│  │  │  - AudioPlayerChannel: 音频控制、悬浮窗控制、状态同步         │   │   │
│  │  │  - AdPlatformChannel: 广告相关接口                           │   │   │
│  │  └────────────────────────┬────────────────────────────────────┘   │   │
│  └───────────────────────────┼────────────────────────────────────────┘   │
│                              │                                             │
│                              ▼                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    AudioPlayerAidlService (AIDL)                    │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │  IAidlAudioPlayer.aidl                                       │   │   │
│  │  │  - play(String url)                                          │   │   │
│  │  │  - pause() / resume() / stop()                               │   │   │
│  │  │  - seekTo(int position)                                      │   │   │
│  │  │  - getCurrentPosition() / getDuration()                      │   │   │
│  │  │  - getCurrentSong()                                          │   │   │
│  │  │  - isPlaying()                                               │   │   │
│  │  │  - setPlaylist(List<String> urls)                            │   │   │
│  │  │  - skipToNext() / skipToPrevious()                           │   │   │
│  │  │  - registerCallback(IAidlPlayerCallback)                     │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  │                                                                     │   │
│  │  - MediaPlayer 实例管理                                             │   │
│  │  - 播放状态管理                                                      │   │
│  │  - 通知栏控制                                                        │   │
│  │  - 播放进度回调                                                      │   │
│  └───────────────────────────┬─────────────────────────────────────────┘   │
│                              │                                             │
│                              ▼                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    FloatingWindowService (系统悬浮窗)               │   │
│  │                                                                     │   │
│  │  - WindowManager 管理                                               │   │
│  │  - 可拖拽移动                                                       │   │
│  │  - 2档模式（完整/迷你）                                              │   │
│  │  - 与 AIDL 服务绑定通信                                              │   │
│  │  - 接收播放状态更新                                                  │   │
│  │  - 点击跳转播放页                                                    │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. 模块详细设计

### 3.1 数据模型

#### 3.1.1 Song 模型
```dart
class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String coverUrl;
  final String audioUrl;
  final Duration? duration;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.coverUrl,
    required this.audioUrl,
    this.duration,
  });

  factory Song.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}
```

#### 3.1.2 播放状态
```dart
enum PlayerState {
  idle,
  loading,
  playing,
  paused,
  completed,
  error,
}

enum RepeatMode {
  none,
  one,
  all,
}
```

#### 3.1.3 悬浮窗模式
```dart
enum FloatingWindowMode {
  full,   // 完整模式：封面 + 歌名 + 控制按钮
  mini,   // 迷你模式：仅主按钮
}

class FloatingWindowState {
  final Offset position;
  final FloatingWindowMode mode;
  final bool isPlaying;
  final Song? currentSong;

  FloatingWindowState({
    required this.position,
    required this.mode,
    required this.isPlaying,
    this.currentSong,
  });

  Map<String, dynamic> toMap() => {
    'x': position.dx,
    'y': position.dy,
    'mode': mode.name,
    'isPlaying': isPlaying,
    'song': currentSong?.toJson(),
  };

  factory FloatingWindowState.fromMap(Map<String, dynamic> map) => ...
}
```

---

### 3.2 Platform Channel 设计

#### 3.2.1 AudioPlayerChannel
```dart
class AudioPlayerChannel {
  static const MethodChannel _channel = 
    MethodChannel('com.example.ex1/audio');

  // 音频控制
  static Future<void> play(String url) => ...
  static Future<void> pause() => ...
  static Future<void> resume() => ...
  static Future<void> stop() => ...
  static Future<void> seekTo(int position) => ...
  static Future<void> skipToNext() => ...
  static Future<void> skipToPrevious() => ...

  // 播放列表
  static Future<void> setPlaylist(List<String> urls) => ...

  // 状态查询
  static Future<bool> isPlaying() => ...
  static Future<int> getCurrentPosition() => ...
  static Future<int> getDuration() => ...
  static Future<Map<String, dynamic>?> getCurrentSong() => ...

  // 悬浮窗控制
  static Future<void> showSystemFloatingWindow(Map<String, dynamic> state) => ...
  static Future<void> hideSystemFloatingWindow() => ...
  static Future<Map<String, dynamic>> getSystemFloatingWindowState() => ...

  // 回调监听
  static void setOnPositionUpdate(Function(int) callback) => ...
  static void setOnStateChange(Function(String) callback) => ...
  static void setOnSongComplete(Function() callback) => ...
}
```

#### 3.2.2 AdPlatformChannel
```dart
class AdPlatformChannel {
  static const MethodChannel _channel = 
    MethodChannel('com.example.ex1/ad');

  // 广告加载
  static Future<Map<String, dynamic>> loadAd(String adId) => ...

  // 事件上报
  static Future<void> reportAdEvent(String event, Map<String, dynamic> params) => ...

  // 回调监听
  static void setOnAdLoaded(Function(Map<String, dynamic>) callback) => ...
  static void setOnAdError(Function(String) callback) => ...
}
```

---

### 3.3 AIDL 接口设计

#### 3.3.1 IAidlAudioPlayer.aidl
```aidl
// IAidlAudioPlayer.aidl
package com.example.ex1;

import com.example.ex1.IAidlPlayerCallback;
import com.example.ex1.SongInfo;

interface IAidlAudioPlayer {
    // 播放控制
    void play(String url);
    void pause();
    void resume();
    void stop();
    void seekTo(int position);
    
    // 切歌
    void skipToNext();
    void skipToPrevious();
    void setPlaylist(in List<String> urls);
    void setCurrentIndex(int index);
    
    // 播放模式
    void setRepeatMode(int mode);
    void setShuffleMode(boolean enabled);
    
    // 状态查询
    int getCurrentPosition();
    int getDuration();
    boolean isPlaying();
    SongInfo getCurrentSong();
    int getCurrentIndex();
    
    // 回调注册
    void registerCallback(IAidlPlayerCallback callback);
    void unregisterCallback(IAidlPlayerCallback callback);
}
```

#### 3.3.2 IAidlPlayerCallback.aidl
```aidl
// IAidlPlayerCallback.aidl
package com.example.ex1;

import com.example.ex1.SongInfo;

interface IAidlPlayerCallback {
    void onPositionUpdate(int position);
    void onStateChange(String state);
    void onSongComplete();
    void onSongChange(in SongInfo song);
    void onError(String error);
}
```

#### 3.3.3 SongInfo.aidl
```aidl
// SongInfo.aidl
package com.example.ex1;

parcelable SongInfo {
    String id;
    String title;
    String artist;
    String album;
    String coverUrl;
    String audioUrl;
    long duration;
}
```

---

### 3.4 悬浮窗切换流程

#### 3.4.1 前台 -> 后台
```
1. AppLifecycleState.paused 触发
   │
   ▼
2. AudioPlayerController.onAppPaused()
   │
   ├─ 获取应用内悬浮窗当前状态
   │  FloatingWindowState state = inAppFloatingWindow.getState()
   │
   ├─ 隐藏应用内悬浮窗
   │  inAppFloatingWindow.hide()
   │
   └─ 传递状态并显示系统悬浮窗
      AudioPlayerChannel.showSystemFloatingWindow(state.toMap())
      │
      ▼
      Android 端:
      - 接收状态参数
      - 启动 FloatingWindowService
      - 根据状态初始化悬浮窗 UI
      - 绑定 AIDL 服务获取播放状态
      - 显示悬浮窗
```

#### 3.4.2 后台 -> 前台
```
1. AppLifecycleState.resumed 触发
   │
   ▼
2. AudioPlayerController.onAppResumed()
   │
   ├─ 获取系统悬浮窗当前状态
   │  Map state = AudioPlayerChannel.getSystemFloatingWindowState()
   │
   ├─ 隐藏系统悬浮窗
   │  AudioPlayerChannel.hideSystemFloatingWindow()
   │
   ├─ 检查当前路由
   │  if (Get.currentRoute == Routes.mediaPlay) return
   │
   └─ 应用内悬浮窗根据状态恢复并显示
      inAppFloatingWindow.showWithState(FloatingWindowState.fromMap(state))
      │
      ▼
      Flutter 端:
      - 根据状态设置位置和模式
      - 从 AIDL 获取当前播放状态
      - 更新 UI 并显示
```

---

### 3.5 悬浮窗交互设计

#### 3.5.1 应用内悬浮窗
```
┌─────────────────────────────────────────────┐
│                                             │
│         ┌─────────────────────────┐         │
│         │  [封面] 歌曲名 - 歌手   │         │
│         │     ▶    ⏭    ✕       │         │
│         └─────────────────────────┘         │
│              完整模式 (full)                │
│                                             │
│              双击切换 ⬇️                    │
│                                             │
│              ┌─────┐                        │
│              │  ▶  │                        │
│              └─────┘                        │
│              迷你模式 (mini)                │
│              （仅播放/暂停按钮）             │
│                                             │
└─────────────────────────────────────────────┘

交互:
- 拖拽: 移动悬浮窗位置
- 单击: 播放/暂停 或 对应按钮功能
- 双击: 切换完整/迷你模式
- 长按: 显示菜单（关闭、跳转播放页）
```

#### 3.5.2 系统悬浮窗
```
┌─────────────────────────────────────────────┐
│                                             │
│     ┌─────────────────────────┐             │
│     │  [封面] 歌曲名 - 歌手   │             │
│     │     ▶    ⏭    ✕       │             │
│     └─────────────────────────┘             │
│          可在屏幕任意位置拖拽               │
│                                             │
└─────────────────────────────────────────────┘

交互:
- 拖拽: 移动悬浮窗位置
- 单击按钮: 对应功能
- 双击: 切换完整/迷你模式
- 点击歌曲信息区域: 跳转播放页
```

---

## 4. 文件结构

### 4.1 Flutter 层
```
lib/
├── models/
│   ├── song_model.dart
│   └── floating_window_state.dart
├── platform/
│   ├── audio_player_channel.dart
│   └── ad_platform_channel.dart
├── services/
│   └── audio_player_service.dart
├── controllers/
│   └── audio_player_controller.dart
├── widgets/
│   ├── in_app_floating_window.dart
│   ├── floating_window_handler.dart
│   └── mini_player.dart
├── pages/
│   ├── media_library_page.dart
│   └── media_play_page.dart
└── routes/
    └── routes.dart
```

### 4.2 Android 原生层
```
android/app/src/main/
├── kotlin/com/example/ex1/
│   ├── MainActivity.kt
│   ├── plugin/
│   │   ├── AudioPlayerChannelPlugin.kt
│   │   └── AdPlatformChannelPlugin.kt
│   ├── service/
│   │   ├── AudioPlayerAidlService.kt
│   │   └── FloatingWindowService.kt
│   └── model/
│       └── SongInfo.kt
└── aidl/com/example/ex1/
    ├── IAidlAudioPlayer.aidl
    ├── IAidlPlayerCallback.aidl
    └── SongInfo.aidl
```

---

## 5. 权限配置

### 5.1 AndroidManifest.xml
```xml
<!-- 悬浮窗权限 -->
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />

<!-- 前台服务权限 -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />

<!-- 通知权限 -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

<application>
    <!-- AIDL 音频服务 -->
    <service
        android:name=".service.AudioPlayerAidlService"
        android:enabled="true"
        android:exported="false"
        android:foregroundServiceType="mediaPlayback" />
    
    <!-- 系统悬浮窗服务 -->
    <service
        android:name=".service.FloatingWindowService"
        android:enabled="true"
        android:exported="false" />
</application>
```

---

## 6. 状态管理流程

### 6.1 播放状态流转
```
[idle] --play()--> [loading] --onPrepared--> [playing]
   │                    │
   │                    ├--pause()--> [paused]
   │                    │               │
   │                    │               └--resume()--> [playing]
   │                    │
   │                    └--onComplete--> [completed]
   │                                    │
   │                                    ├--next()--> [loading]
   │                                    └--stop()--> [idle]
   │
   └--error--> [error] --retry()--> [loading]
```

### 6.2 悬浮窗状态同步
```
┌─────────────────┐     保存状态      ┌─────────────────┐
│  应用内悬浮窗    │ ◄──────────────► │  SharedPreferences
│  (Flutter)      │                  │  (本地存储)
└─────────────────┘                  └─────────────────┘
         │
         │ 切换前后台时同步
         ▼
┌─────────────────┐     保存状态      ┌─────────────────┐
│  系统悬浮窗      │ ◄──────────────► │  SharedPreferences
│  (Android)      │                  │  (本地存储)
└─────────────────┘                  └─────────────────┘
```

---

## 7. 接口清单

### 7.1 Dart 接口
| 接口 | 功能 |
|------|------|
| `AudioPlayerController.play(Song song)` | 播放指定歌曲 |
| `AudioPlayerController.pause()` | 暂停播放 |
| `AudioPlayerController.resume()` | 恢复播放 |
| `AudioPlayerController.seekTo(Duration position)` | 跳转到指定位置 |
| `AudioPlayerController.skipToNext()` | 下一首 |
| `AudioPlayerController.skipToPrevious()` | 上一首 |
| `AudioPlayerController.setPlaylist(List<Song> songs)` | 设置播放列表 |
| `InAppFloatingWindow.show()` | 显示应用内悬浮窗 |
| `InAppFloatingWindow.hide()` | 隐藏应用内悬浮窗 |
| `InAppFloatingWindow.getState()` | 获取当前状态 |

### 7.2 Platform Channel 接口
| 接口 | 功能 |
|------|------|
| `audio/play` | 播放音频 |
| `audio/pause` | 暂停音频 |
| `audio/resume` | 恢复音频 |
| `audio/seek` | 跳转位置 |
| `audio/showSystemFloatingWindow` | 显示系统悬浮窗 |
| `audio/hideSystemFloatingWindow` | 隐藏系统悬浮窗 |
| `audio/getSystemFloatingWindowState` | 获取系统悬浮窗状态 |
| `ad/loadAd` | 加载广告 |
| `ad/reportEvent` | 上报广告事件 |

### 7.3 AIDL 接口
| 接口 | 功能 |
|------|------|
| `play(String url)` | 播放 |
| `pause()` | 暂停 |
| `resume()` | 恢复 |
| `seekTo(int position)` | 跳转 |
| `getCurrentPosition()` | 获取当前位置 |
| `getDuration()` | 获取总时长 |
| `isPlaying()` | 是否正在播放 |
| `getCurrentSong()` | 获取当前歌曲 |

---

## 8. 注意事项

### 8.1 性能优化
- 悬浮窗使用 `RepaintBoundary` 减少重绘
- 播放进度更新使用节流（throttle）
- 图片使用缓存

### 8.2 内存管理
- 页面销毁时取消监听
- 服务绑定使用 `bindService` + `unbindService`
- 及时释放 MediaPlayer 资源

### 8.3 兼容性
- Android 6.0+ 动态申请悬浮窗权限
- Android 8.0+ 前台服务通知适配
- Android 10+ 后台启动 Activity 限制

---

## 9. 后续扩展

- [ ] 歌词显示
- [ ] 均衡器
- [ ] 睡眠定时
- [ ] 播放速度调节
- [ ] 音频可视化

---

文档版本: 1.0
更新日期: 2026-04-01
