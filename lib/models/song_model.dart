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

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      album: json['album'] ?? '',
      coverUrl: json['coverUrl'] ?? '',
      audioUrl: json['audioUrl'] ?? '',
      duration: json['duration'] != null ? Duration(milliseconds: json['duration']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'coverUrl': coverUrl,
      'audioUrl': audioUrl,
      'duration': duration?.inMilliseconds,
    };
  }
}

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
