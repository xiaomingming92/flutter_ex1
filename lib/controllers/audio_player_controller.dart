import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/song_model.dart';
import '../models/floating_window_state.dart';
import '../services/audio_player_service.dart';

class AudioPlayerController extends GetxController with WidgetsBindingObserver {
  final AudioPlayerService _service = AudioPlayerService();

  // 播放状态
  final playerState = PlayerState.idle.obs;
  final currentSong = Rxn<Song>();
  final currentPosition = Duration.zero.obs;
  final duration = Duration.zero.obs;
  final isPlaying = false.obs;

  // 播放列表
  final playlist = <Song>[].obs;
  final currentIndex = 0.obs;

  // 悬浮窗状态
  final floatingWindowState = FloatingWindowState(
    position: Offset(100, 300),
    mode: FloatingWindowMode.full,
    isPlaying: false,
  ).obs;

  // 生命周期状态
  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;

  @override
  void onInit() {
    super.onInit();
    _service.initialize();
    _setupListeners();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _service.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    switch (state) {
      case AppLifecycleState.paused:
        // 前台 → 后台
        _onAppPaused();
        break;
      case AppLifecycleState.resumed:
        // 后台 → 前台
        _onAppResumed();
        break;
      default:
        break;
    }
  }

  void _setupListeners() {
    _service.onStateChange = (state) {
      playerState.value = state;
      isPlaying.value = state == PlayerState.playing;
    };

    _service.onPositionUpdate = (position) {
      currentPosition.value = Duration(milliseconds: position);
    };

    _service.onSongComplete = () {
      // 处理歌曲结束逻辑
      _onSongComplete();
    };

    _service.onSongChange = (song) {
      currentSong.value = song;
    };
  }

  // 播放控制
  Future<void> play(Song song) async {
    await _service.play(song);
    currentSong.value = song;
  }

  Future<void> pause() async {
    await _service.pause();
  }

  Future<void> resume() async {
    await _service.resume();
  }

  Future<void> stop() async {
    await _service.stop();
  }

  Future<void> seekTo(Duration position) async {
    await _service.seekTo(position);
  }

  Future<void> skipToNext() async {
    await _service.skipToNext();
  }

  Future<void> skipToPrevious() async {
    await _service.skipToPrevious();
  }

  // 播放列表
  void setPlaylist(List<Song> songs) {
    playlist.value = songs;
  }

  void playAtIndex(int index) {
    if (index >= 0 && index < playlist.length) {
      currentIndex.value = index;
      play(playlist[index]);
    }
  }

  // 悬浮窗控制
  void updateFloatingWindowState(FloatingWindowState state) {
    floatingWindowState.value = state;
  }

  void toggleFloatingWindowMode() {
    final currentMode = floatingWindowState.value.mode;
    final newMode = currentMode == FloatingWindowMode.full
        ? FloatingWindowMode.mini
        : FloatingWindowMode.full;
    floatingWindowState.value = floatingWindowState.value.copyWith(mode: newMode);
  }

  void updateFloatingWindowPosition(Offset position) {
    floatingWindowState.value = floatingWindowState.value.copyWith(position: position);
  }

  // 应用生命周期处理
  Future<void> _onAppPaused() async {
    // 获取当前悬浮窗状态
    final state = floatingWindowState.value;
    
    // 显示系统悬浮窗
    await _service.showSystemFloatingWindow(state.toMap());
  }

  Future<void> _onAppResumed() async {
    // 获取系统悬浮窗状态
    final stateMap = await _service.getSystemFloatingWindowState();
    final state = FloatingWindowState.fromMap(stateMap);
    
    // 隐藏系统悬浮窗
    await _service.hideSystemFloatingWindow();
    
    // 更新悬浮窗状态
    floatingWindowState.value = state;
  }

  // 歌曲结束处理
  void _onSongComplete() {
    // 自动播放下一首
    if (currentIndex.value < playlist.length - 1) {
      playAtIndex(currentIndex.value + 1);
    }
  }

  // 从其他页面跳转播放
  void playFromOtherPage(Song song) {
    play(song);
  }
}
