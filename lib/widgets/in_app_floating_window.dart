import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/audio_player_controller.dart';
import '../models/floating_window_state.dart';
import '../models/song_model.dart';

class InAppFloatingWindow extends StatefulWidget {
  const InAppFloatingWindow({super.key});

  @override
  State<InAppFloatingWindow> createState() => _InAppFloatingWindowState();
}

class _InAppFloatingWindowState extends State<InAppFloatingWindow> {
  final _controller = Get.find<AudioPlayerController>();
  Offset _currentPosition = Offset(100, 300);
  bool _isDragging = false;
  Offset _offset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _currentPosition = _controller.floatingWindowState.value.position;
  }

  void _onPanStart(DragStartDetails details) {
    _isDragging = true;
    _offset = details.localPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isDragging) {
      setState(() {
        _currentPosition += details.delta;
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;
    _controller.updateFloatingWindowPosition(_currentPosition);
  }

  void _toggleMode() {
    _controller.toggleFloatingWindowMode();
  }

  void _playPause() {
    if (_controller.isPlaying.value) {
      _controller.pause();
    } else {
      _controller.resume();
    }
  }

  void _skipToNext() {
    _controller.skipToNext();
  }

  void _skipToPrevious() {
    _controller.skipToPrevious();
  }

  void _close() {
    // 隐藏悬浮窗逻辑
  }

  void _goToPlayerPage() {
    Get.toNamed('/MediaPlayPage');
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.floatingWindowState.value;
    final currentSong = _controller.currentSong.value;

    if (currentSong == null) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      final isPlaying = _controller.isPlaying.value;
      final mode = state.mode;

      return Positioned(
        left: _currentPosition.dx,
        top: _currentPosition.dy,
        child: GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          onDoubleTap: _toggleMode,
          child: mode == FloatingWindowMode.full
              ? _buildFullMode(currentSong, isPlaying)
              : _buildMiniMode(isPlaying),
        ),
      );
    });
  }

  Widget _buildFullMode(Song song, bool isPlaying) {
    return Container(
      width: 300,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          // 封面
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                song.coverUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 歌曲信息
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${song.artist} - ${song.album}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // 控制按钮
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: _playPause,
              ),
            ],
          ),

          IconButton(
            icon: const Icon(Icons.skip_next, color: Colors.white),
            onPressed: _skipToNext,
          ),

          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _close,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMode(bool isPlaying) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 30,
        ),
        onPressed: _playPause,
      ),
    );
  }
}
