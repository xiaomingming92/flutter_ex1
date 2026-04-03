package com.example.ex1

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.example.ex1.plugin.AudioPlayerChannelPlugin

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // 注册 Platform Channel 插件
        AudioPlayerChannelPlugin().onAttachedToEngine(flutterEngine.plugins)
    }
}

