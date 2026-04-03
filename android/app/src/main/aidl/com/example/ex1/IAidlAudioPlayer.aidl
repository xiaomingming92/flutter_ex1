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
