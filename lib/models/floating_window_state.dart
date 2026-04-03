import 'dart:ui';
import 'song_model.dart';

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

  Map<String, dynamic> toMap() {
    return {
      'x': position.dx,
      'y': position.dy,
      'mode': mode.name,
      'isPlaying': isPlaying,
      'song': currentSong?.toJson(),
    };
  }

  factory FloatingWindowState.fromMap(Map<String, dynamic> map) {
    return FloatingWindowState(
      position: Offset(
        (map['x'] ?? 0.0).toDouble(),
        (map['y'] ?? 0.0).toDouble(),
      ),
      mode: FloatingWindowMode.values.firstWhere(
        (e) => e.name == (map['mode'] ?? 'full'),
        orElse: () => FloatingWindowMode.full,
      ),
      isPlaying: map['isPlaying'] ?? false,
      currentSong: map['song'] != null ? Song.fromJson(map['song']) : null,
    );
  }

  FloatingWindowState copyWith({
    Offset? position,
    FloatingWindowMode? mode,
    bool? isPlaying,
    Song? currentSong,
  }) {
    return FloatingWindowState(
      position: position ?? this.position,
      mode: mode ?? this.mode,
      isPlaying: isPlaying ?? this.isPlaying,
      currentSong: currentSong ?? this.currentSong,
    );
  }
}
