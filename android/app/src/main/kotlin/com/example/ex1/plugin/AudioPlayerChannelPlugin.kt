package com.example.ex1.plugin

import android.app.Activity
import android.content.Intent
import android.content.ServiceConnection
import android.os.*
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import com.example.ex1.IAidlAudioPlayer
import com.example.ex1.service.AudioPlayerAidlService
import com.example.ex1.service.FloatingWindowService

class AudioPlayerChannelPlugin : FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    private val TAG = "AudioPlayerChannelPlugin"
    
    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var eventSink: EventSink? = null
    private var activity: Activity? = null
    
    private var audioService: IAidlAudioPlayer? = null
    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, binder: IBinder?) {
            audioService = IAidlAudioPlayer.Stub.asInterface(binder)
        }
        
        override fun onServiceDisconnected(name: ComponentName?) {
            audioService = null
        }
    }
    
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.example.ex1/audio")
        methodChannel?.setMethodCallHandler(this)
        
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "com.example.ex1/audio_events")
        eventChannel?.setStreamHandler(this)
    }
    
    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel?.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
    }
    
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        bindAudioService()
    }
    
    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }
    
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }
    
    override fun onDetachedFromActivity() {
        activity = null
        unbindAudioService()
    }
    
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        when (call.method) {
            "play" -> {
                val url = call.argument<String>("url")
                audioService?.play(url)
                result.success(null)
            }
            "pause" -> {
                audioService?.pause()
                result.success(null)
            }
            "resume" -> {
                audioService?.resume()
                result.success(null)
            }
            "stop" -> {
                audioService?.stop()
                result.success(null)
            }
            "seek" -> {
                val position = call.argument<Int>("position")
                audioService?.seekTo(position!!)
                result.success(null)
            }
            "skipToNext" -> {
                audioService?.skipToNext()
                result.success(null)
            }
            "skipToPrevious" -> {
                audioService?.skipToPrevious()
                result.success(null)
            }
            "setPlaylist" -> {
                val urls = call.argument<List<String>>("urls")
                audioService?.setPlaylist(urls!!.toMutableList())
                result.success(null)
            }
            "isPlaying" -> {
                val isPlaying = audioService?.isPlaying ?: false
                result.success(isPlaying)
            }
            "getCurrentPosition" -> {
                val position = audioService?.currentPosition ?: 0
                result.success(position)
            }
            "getDuration" -> {
                val duration = audioService?.duration ?: 0
                result.success(duration)
            }
            "getCurrentSong" -> {
                val song = audioService?.currentSong
                val songMap = song?.let {
                    mapOf(
                        "id" to it.id,
                        "title" to it.title,
                        "artist" to it.artist,
                        "album" to it.album,
                        "coverUrl" to it.coverUrl,
                        "audioUrl" to it.audioUrl,
                        "duration" to it.duration
                    )
                }
                result.success(songMap)
            }
            "showSystemFloatingWindow" -> {
                val state = call.arguments as Map<*, *>
                val intent = Intent(activity, FloatingWindowService::class.java)
                val bundle = Bundle()
                bundle.putDouble("x", state["x"] as Double)
                bundle.putDouble("y", state["y"] as Double)
                bundle.putString("mode", state["mode"] as String)
                intent.putExtra("state", bundle)
                activity?.startService(intent)
                result.success(null)
            }
            "hideSystemFloatingWindow" -> {
                val intent = Intent(activity, FloatingWindowService::class.java)
                activity?.stopService(intent)
                result.success(null)
            }
            "getSystemFloatingWindowState" -> {
                // 返回默认状态
                val state = mapOf(
                    "x" to 100.0,
                    "y" to 300.0,
                    "mode" to "full",
                    "isPlaying" to (audioService?.isPlaying ?: false)
                )
                result.success(state)
            }
            else -> result.notImplemented()
        }
    }
    
    override fun onListen(arguments: Any?, events: EventSink?) {
        eventSink = events
    }
    
    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
    
    private fun bindAudioService() {
        activity?.let {
            val intent = Intent(it, AudioPlayerAidlService::class.java)
            it.bindService(intent, serviceConnection, Activity.BIND_AUTO_CREATE)
        }
    }
    
    private fun unbindAudioService() {
        activity?.unbindService(serviceConnection)
    }
}
