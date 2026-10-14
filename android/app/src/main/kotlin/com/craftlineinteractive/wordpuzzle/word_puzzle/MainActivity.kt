package com.craftlineinteractive.wordsearch

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.craftline.wordsearch/haptics"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "vibrate" -> {
                    val duration = (call.argument<Int>("duration") ?: 30).toLong()
                    val amplitude = call.argument<Int>("amplitude") ?: -1
                    triggerVibration(duration, amplitude)
                    result.success(true)
                }
                "impact" -> {
                    val style = call.argument<String>("style") ?: "light"
                    when (style) {
                        "light" -> triggerVibration(25, 100)
                        "medium" -> triggerVibration(45, 180)
                        "heavy" -> triggerVibration(80, 255)
                        else -> triggerVibration(30, -1)
                    }
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun triggerVibration(durationMs: Long, amplitude: Int) {
        try {
            val vibrator: Vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
                vibratorManager.defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            }

            if (vibrator.hasVibrator()) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    val clampedAmp = if (amplitude in 1..255) amplitude else VibrationEffect.DEFAULT_AMPLITUDE
                    val effect = VibrationEffect.createOneShot(durationMs, clampedAmp)
                    vibrator.vibrate(effect)
                } else {
                    @Suppress("DEPRECATION")
                    vibrator.vibrate(durationMs)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
