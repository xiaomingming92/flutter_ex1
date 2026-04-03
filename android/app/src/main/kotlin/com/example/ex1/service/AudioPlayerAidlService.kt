package com.example.ex1.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.media.MediaPlayer
import android.os.*
import android.util.Log
import com.example.ex1.IAidlAudioPlayer
import com.example.ex1.IAidlPlayerCallback
import com.example.ex1.MainActivity
import com.example.ex1.R
import com.example.ex1.model.SongInfo

class AudioPlayerAidlService : Service() {
    private val TAG = "AudioPlayerAidlService"
    
    private var mediaPlayer: MediaPlayer? = null
    private var playlist: MutableList<String> = mutableListOf()
    private var currentIndex = 0
    private var isPlaying = false
    private var currentSong: SongInfo? = null
    
    private val callbacks = mutableListOf<IAidlPlayerCallback>()
    private val binder = AudioPlayerBinder()
    
    private val NOTIFICATION_CHANNEL_ID = "audio_player_channel"
    private val NOTIFICATION_ID = 1
    
    override fun onBind(intent: Intent): IBinder {
        return binder
    }
    
    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, createNotification())
    }
    
    override fun onDestroy() {
        mediaPlayer?.release()
        mediaPlayer = null
        super.onDestroy()
    }
    
    inner class AudioPlayerBinder : IAidlAudioPlayer.Stub() {
        override fun play(url: String) {
            playUrl(url)
        }
        
        override fun pause() {
            mediaPlayer?.pause()
            isPlaying = false
            updateNotification()
            notifyStateChange("paused")
        }
        
        override fun resume() {
            mediaPlayer?.start()
            isPlaying = true
            updateNotification()
            notifyStateChange("playing")
        }
        
        override fun stop() {
            mediaPlayer?.stop()
            mediaPlayer?.reset()
            isPlaying = false
            updateNotification()
            notifyStateChange("idle")
        }
        
        override fun seekTo(position: Int) {
            mediaPlayer?.seekTo(position)
        }
        
        override fun skipToNext() {
            if (playlist.isNotEmpty()) {
                currentIndex = (currentIndex + 1) % playlist.size
                playUrl(playlist[currentIndex])
            }
        }
        
        override fun skipToPrevious() {
            if (playlist.isNotEmpty()) {
                currentIndex = (currentIndex - 1 + playlist.size) % playlist.size
                playUrl(playlist[currentIndex])
            }
        }
        
        override fun setPlaylist(urls: MutableList<String>) {
            playlist = urls
        }
        
        override fun setCurrentIndex(index: Int) {
            if (index >= 0 && index < playlist.size) {
                currentIndex = index
                playUrl(playlist[currentIndex])
            }
        }
        
        override fun setRepeatMode(mode: Int) {
            // 实现重复模式
        }
        
        override fun setShuffleMode(enabled: Boolean) {
            // 实现随机播放
        }
        
        override fun getCurrentPosition(): Int {
            return mediaPlayer?.currentPosition ?: 0
        }
        
        override fun getDuration(): Int {
            return mediaPlayer?.duration ?: 0
        }
        
        override fun isPlaying(): Boolean {
            return isPlaying
        }
        
        override fun getCurrentSong(): SongInfo {
            return currentSong ?: SongInfo("", "", "", "", "", "", 0)
        }
        
        override fun getCurrentIndex(): Int {
            return currentIndex
        }
        
        override fun registerCallback(callback: IAidlPlayerCallback) {
            callbacks.add(callback)
        }
        
        override fun unregisterCallback(callback: IAidlPlayerCallback) {
            callbacks.remove(callback)
        }
    }
    
    private fun playUrl(url: String) {
        try {
            mediaPlayer?.release()
            mediaPlayer = MediaPlayer().apply {
                setDataSource(url)
                prepareAsync()
                setOnPreparedListener {
                    start()
                    isPlaying = true
                    updateNotification()
                    notifyStateChange("playing")
                    
                    // 模拟歌曲信息
                    currentSong = SongInfo(
                        "1",
                        "Test Song",
                        "Test Artist",
                        "Test Album",
                        "https://example.com/cover.jpg",
                        url,
                        duration.toLong()
                    )
                    notifySongChange(currentSong!!)
                }
                setOnCompletionListener {
                    isPlaying = false
                    updateNotification()
                    notifySongComplete()
                    notifyStateChange("completed")
                }
                setOnErrorListener { _, _, _ ->
                    notifyError("播放错误")
                    notifyStateChange("error")
                    false
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "播放错误: ${e.message}")
            notifyError(e.message ?: "播放错误")
        }
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "音频播放器",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }
    
    private fun createNotification(): Notification {
        val intent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_IMMUTABLE)
        
        return Notification.Builder(this, NOTIFICATION_CHANNEL_ID)
            .setContentTitle("音频播放器")
            .setContentText("正在播放")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(pendingIntent)
            .build()
    }
    
    private fun updateNotification() {
        val notification = createNotification()
        startForeground(NOTIFICATION_ID, notification)
    }
    
    private fun notifyStateChange(state: String) {
        callbacks.forEach { callback ->
            try {
                callback.onStateChange(state)
            } catch (e: RemoteException) {
                Log.e(TAG, "通知状态变化失败: ${e.message}")
            }
        }
    }
    
    private fun notifyPositionUpdate(position: Int) {
        callbacks.forEach { callback ->
            try {
                callback.onPositionUpdate(position)
            } catch (e: RemoteException) {
                Log.e(TAG, "通知位置更新失败: ${e.message}")
            }
        }
    }
    
    private fun notifySongComplete() {
        callbacks.forEach { callback ->
            try {
                callback.onSongComplete()
            } catch (e: RemoteException) {
                Log.e(TAG, "通知歌曲结束失败: ${e.message}")
            }
        }
    }
    
    private fun notifySongChange(song: SongInfo) {
        callbacks.forEach { callback ->
            try {
                callback.onSongChange(song)
            } catch (e: RemoteException) {
                Log.e(TAG, "通知歌曲变化失败: ${e.message}")
            }
        }
    }
    
    private fun notifyError(error: String) {
        callbacks.forEach { callback ->
            try {
                callback.onError(error)
            } catch (e: RemoteException) {
                Log.e(TAG, "通知错误失败: ${e.message}")
            }
        }
    }
}
