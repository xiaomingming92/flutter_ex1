package com.example.ex1.service

import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.*
import android.view.*
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import android.util.Log
import com.example.ex1.IAidlAudioPlayer
import com.example.ex1.IAidlPlayerCallback
import com.example.ex1.MainActivity
import com.example.ex1.R
import com.example.ex1.model.SongInfo

class FloatingWindowService : Service() {
    private val TAG = "FloatingWindowService"
    
    private lateinit var windowManager: WindowManager
    private lateinit var floatingView: View
    private lateinit var params: WindowManager.LayoutParams
    
    private var isDragging = false
    private var initialX = 0
    private var initialY = 0
    private var initialTouchX = 0f
    private var initialTouchY = 0f
    
    private var isFullMode = true
    private var isPlaying = false
    
    private var audioService: IAidlAudioPlayer? = null
    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, binder: IBinder?) {
            audioService = IAidlAudioPlayer.Stub.asInterface(binder)
            registerCallback()
            updatePlaybackStatus()
        }
        
        override fun onServiceDisconnected(name: ComponentName?) {
            audioService = null
        }
    }
    
    private val callback = object : IAidlPlayerCallback.Stub() {
        override fun onPositionUpdate(position: Int) {
            // 更新播放进度
        }
        
        override fun onStateChange(state: String) {
            isPlaying = state == "playing"
            updatePlayButton()
        }
        
        override fun onSongComplete() {
            // 处理歌曲结束
        }
        
        override fun onSongChange(song: SongInfo) {
            updateSongInfo(song)
        }
        
        override fun onError(error: String) {
            Log.e(TAG, "播放错误: $error")
        }
    }
    
    override fun onBind(intent: Intent): IBinder? {
        return null
    }
    
    override fun onCreate() {
        super.onCreate()
        initializeFloatingWindow()
        bindAudioService()
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val state = intent?.getBundleExtra("state")
        state?.let {
            val x = it.getDouble("x", 100.0)
            val y = it.getDouble("y", 300.0)
            val mode = it.getString("mode", "full")
            
            params.x = x.toInt()
            params.y = y.toInt()
            isFullMode = mode == "full"
            updateWindowMode()
        }
        
        return START_STICKY
    }
    
    override fun onDestroy() {
        windowManager.removeView(floatingView)
        unbindService(serviceConnection)
        super.onDestroy()
    }
    
    private fun initializeFloatingWindow() {
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        
        params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                WindowManager.LayoutParams.TYPE_PHONE
            },
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
            PixelFormat.TRANSLUCENT
        )
        
        params.gravity = Gravity.TOP or Gravity.LEFT
        params.x = 100
        params.y = 300
        
        floatingView = LayoutInflater.from(this).inflate(R.layout.floating_window, null)
        
        // 设置触摸监听
        floatingView.setOnTouchListener {
            _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    isDragging = true
                    initialX = params.x
                    initialY = params.y
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    if (isDragging) {
                        params.x = initialX + (event.rawX - initialTouchX).toInt()
                        params.y = initialY + (event.rawY - initialTouchY).toInt()
                        windowManager.updateViewLayout(floatingView, params)
                    }
                    true
                }
                MotionEvent.ACTION_UP -> {
                    isDragging = false
                    // 处理点击事件
                    if (event.eventTime - event.downTime < 200) {
                        handleTap(event)
                    }
                    true
                }
                else -> false
            }
        }
        
        // 播放/暂停按钮
        floatingView.findViewById<ImageView>(R.id.btn_play_pause).setOnClickListener {
            togglePlayPause()
        }
        
        // 下一首按钮
        floatingView.findViewById<ImageView>(R.id.btn_next).setOnClickListener {
            audioService?.skipToNext()
        }
        
        // 关闭按钮
        floatingView.findViewById<ImageView>(R.id.btn_close).setOnClickListener {
            stopSelf()
        }
        
        // 双击切换模式
        floatingView.setOnClickListener {
            // 处理点击事件
        }
        
        floatingView.setOnLongClickListener {
            // 长按菜单
            true
        }
        
        windowManager.addView(floatingView, params)
    }
    
    private fun handleTap(event: MotionEvent) {
        // 处理点击事件
        val view = floatingView.hitTest(event.x, event.y)
        if (view !is ImageView) {
            // 点击空白区域，跳转到播放页
            startPlayerActivity()
        }
    }
    
    private fun bindAudioService() {
        val intent = Intent(this, AudioPlayerAidlService::class.java)
        bindService(intent, serviceConnection, BIND_AUTO_CREATE)
    }
    
    private fun registerCallback() {
        audioService?.registerCallback(callback)
    }
    
    private fun togglePlayPause() {
        if (isPlaying) {
            audioService?.pause()
        } else {
            audioService?.resume()
        }
    }
    
    private fun updatePlayButton() {
        val playButton = floatingView.findViewById<ImageView>(R.id.btn_play_pause)
        if (isPlaying) {
            playButton.setImageResource(android.R.drawable.ic_media_pause)
        } else {
            playButton.setImageResource(android.R.drawable.ic_media_play)
        }
    }
    
    private fun updateSongInfo(song: SongInfo) {
        val titleText = floatingView.findViewById<TextView>(R.id.tv_title)
        val artistText = floatingView.findViewById<TextView>(R.id.tv_artist)
        
        titleText.text = song.title
        artistText.text = song.artist
    }
    
    private fun updatePlaybackStatus() {
        audioService?.let {
            try {
                isPlaying = it.isPlaying
                updatePlayButton()
                
                val song = it.currentSong
                updateSongInfo(song)
            } catch (e: RemoteException) {
                Log.e(TAG, "更新播放状态失败: ${e.message}")
            }
        }
    }
    
    private fun updateWindowMode() {
        val fullModeLayout = floatingView.findViewById<LinearLayout>(R.id.layout_full_mode)
        val miniModeLayout = floatingView.findViewById<LinearLayout>(R.id.layout_mini_mode)
        
        if (isFullMode) {
            fullModeLayout.visibility = View.VISIBLE
            miniModeLayout.visibility = View.GONE
        } else {
            fullModeLayout.visibility = View.GONE
            miniModeLayout.visibility = View.VISIBLE
        }
    }
    
    private fun startPlayerActivity() {
        val intent = Intent(this, MainActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        intent.putExtra("open_player", true)
        startActivity(intent)
    }
}
