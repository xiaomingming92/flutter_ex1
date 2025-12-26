import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

class MediaPlayPage extends StatefulWidget {
  const MediaPlayPage({Key? key}) : super(key: key);

  @override
  State<MediaPlayPage> createState() => _MediaPlayPageState();
}

class _MediaPlayPageState extends State<MediaPlayPage>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _progressController;
  late AudioPlayer _audioPlayer;
  
  bool isPlaying = false;
  double currentPosition = 0.0;
  double duration = 0.0;
  
  // 模拟歌曲数据
  final Map<String, dynamic> currentSong = {
    'title': '夜空中最亮的星',
    'artist': '邓紫棋',
    'album': '世界',
    'coverUrl': 'http://p2.music.126.net/PRHMHB5Dq-2vp43szwjwaQ==/109951169714962535.jpg?param=300x300',
    'audioUrl': 'http://music.163.com/song/media/outer/url?id=2601379905.mp3'
  };

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(); // 无限循环旋转
    _progressController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
        if (isPlaying) {
          _rotationController.repeat();
        } else {
          _rotationController.stop();
        }
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        currentPosition = position.inMilliseconds.toDouble();
      });
    });

    _audioPlayer.onDurationChanged.listen((duration_) {
      setState(() {
        duration = duration_.inMilliseconds.toDouble();
      });
    });
  }

  void _playPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(currentSong['audioUrl']));
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _progressController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航
            _buildTopBar(),
            // CD播放区域
            Expanded(child: _buildCDPlayerArea()),
            // 播放控制区域
            _buildControlPanel(),
            // 播放列表区域
            _buildPlaylistArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentSong['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  currentSong['artist'],
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // 更多选项
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCDPlayerArea() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // CD光盘背景
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const SweepGradient(
                colors: [
                  Color(0xFF2c2c2c),
                  Color(0xFF404040),
                  Color(0xFF2c2c2c),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          
          // 专辑封面
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * math.pi,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF404040), width: 2),
                    image: DecorationImage(
                      image: NetworkImage(currentSong['coverUrl']),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // CD中心点
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    final progress = duration > 0 ? currentPosition / duration : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 进度条
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF1DB954),
              inactiveTrackColor: Colors.grey,
              thumbColor: Colors.white,
              overlayColor: Colors.white.withOpacity(0.3),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              trackHeight: 4,
            ),
            child: Slider(
              value: progress,
              onChanged: (value) {
                final newPosition = value * duration;
                _audioPlayer.seek(Duration(milliseconds: newPosition.toInt()));
              },
            ),
          ),
          
          // 时间显示
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(Duration(milliseconds: currentPosition.toInt())),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  _formatTime(Duration(milliseconds: duration.toInt())),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 播放控制按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(
                icon: Icons.skip_previous,
                size: 32,
                onPressed: () {
                  // 上一首
                },
              ),
              const SizedBox(width: 32),
              
              GestureDetector(
                onTap: _playPause,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1DB954),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1DB954).withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 32),
              
              _buildControlButton(
                icon: Icons.skip_next,
                size: 32,
                onPressed: () {
                  // 下一首
                },
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 底部控制按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.favorite_border,
                color: Colors.white,
                onPressed: () {
                  // 收藏
                },
              ),
              _buildControlButton(
                icon: Icons.shuffle,
                color: Colors.grey,
                onPressed: () {
                  // 随机播放
                },
              ),
              _buildControlButton(
                icon: Icons.repeat,
                color: Colors.grey,
                onPressed: () {
                  // 循环播放
                },
              ),
              _buildControlButton(
                icon: Icons.playlist_play,
                color: Colors.white,
                onPressed: () {
                  // 播放列表
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color color = Colors.white,
    double size = 24,
  }) {
    return IconButton(
      icon: Icon(icon, color: color, size: size),
      onPressed: onPressed,
    );
  }

  Widget _buildPlaylistArea() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.queue_music, color: Colors.white.withOpacity(0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '播放列表',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '15首歌曲',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_upward,
              color: Colors.white.withOpacity(0.7),
            ),
            onPressed: () {
              // 展开播放列表
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  String _formatTime(Duration duration) {
    if (duration.inSeconds < 60) {
      return '0:${duration.inSeconds.toString().padLeft(2, '0')}';
    }
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}