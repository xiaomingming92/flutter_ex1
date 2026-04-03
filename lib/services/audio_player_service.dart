import '../platform/audio_player_channel.dart';
import '../models/song_model.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  // 播放状态回调
  Function(PlayerState)? onStateChange;
  Function(int)? onPositionUpdate;
  Function()? onSongComplete;
  Function(Song)? onSongChange;

  // 初始化服务
  void initialize() {
    // 注册事件监听
    AudioPlayerChannel.setOnStateChange((state) {
      onStateChange?.call(PlayerState.values.firstWhere(
        (e) => e.name == state,
        orElse: () => PlayerState.idle,
      ));
    });

    AudioPlayerChannel.setOnPositionUpdate((position) {
      onPositionUpdate?.call(position);
    });

    AudioPlayerChannel.setOnSongComplete(() {
      onSongComplete?.call();
    });

    AudioPlayerChannel.setOnSongChange((songData) {
      final song = Song.fromJson(songData);
      onSongChange?.call(song);
    });
  }

  // 播放控制
  Future<void> play(Song song) async {
    await AudioPlayerChannel.play(song.audioUrl);
  }

  Future<void> pause() async {
    await AudioPlayerChannel.pause();
  }

  Future<void> resume() async {
    await AudioPlayerChannel.resume();
  }

  Future<void> stop() async {
    await AudioPlayerChannel.stop();
  }

  Future<void> seekTo(Duration position) async {
    await AudioPlayerChannel.seekTo(position.inMilliseconds);
  }

  Future<void> skipToNext() async {
    await AudioPlayerChannel.skipToNext();
  }

  Future<void> skipToPrevious() async {
    await AudioPlayerChannel.skipToPrevious();
  }

  // 播放列表
  Future<void> setPlaylist(List<Song> songs) async {
    final urls = songs.map((song) => song.audioUrl).toList();
    await AudioPlayerChannel.setPlaylist(urls);
  }

  // 状态查询
  Future<bool> isPlaying() async {
    return await AudioPlayerChannel.isPlaying();
  }

  Future<Duration> getCurrentPosition() async {
    final position = await AudioPlayerChannel.getCurrentPosition();
    return Duration(milliseconds: position);
  }

  Future<Duration> getDuration() async {
    final duration = await AudioPlayerChannel.getDuration();
    return Duration(milliseconds: duration);
  }

  Future<Song?> getCurrentSong() async {
    final songData = await AudioPlayerChannel.getCurrentSong();
    if (songData != null) {
      return Song.fromJson(songData);
    }
    return null;
  }

  // 悬浮窗控制
  Future<void> showSystemFloatingWindow(Map<String, dynamic> state) async {
    await AudioPlayerChannel.showSystemFloatingWindow(state);
  }

  Future<void> hideSystemFloatingWindow() async {
    await AudioPlayerChannel.hideSystemFloatingWindow();
  }

  Future<Map<String, dynamic>> getSystemFloatingWindowState() async {
    return await AudioPlayerChannel.getSystemFloatingWindowState();
  }

  // 释放资源
  void dispose() {
    // 这里可以添加清理代码
  }
}
