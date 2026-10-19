package com.craftlineinteractive.wordsearch

import android.content.Context
import android.media.AudioAttributes
import android.os.Build
import android.os.VibrationAttributes
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.craftline.wordsearch/haptics"

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            splashScreen.setOnExitAnimationListener { splashScreenView ->
                splashScreenView.remove()
            }
        }
    }

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
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    val clampedAmp = if (amplitude in 1..255) amplitude else VibrationEffect.DEFAULT_AMPLITUDE
                    val effect = VibrationEffect.createOneShot(durationMs, clampedAmp)
                    val attributes = VibrationAttributes.Builder()
                        .setUsage(VibrationAttributes.USAGE_TOUCH)
                        .build()
                    vibrator.vibrate(effect, attributes)
                } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    val clampedAmp = if (amplitude in 1..255) amplitude else VibrationEffect.DEFAULT_AMPLITUDE
                    val effect = VibrationEffect.createOneShot(durationMs, clampedAmp)
                    val audioAttributes = AudioAttributes.Builder()
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .setUsage(AudioAttributes.USAGE_ASSISTANCE_SONIFICATION)
                        .build()
                    vibrator.vibrate(effect, audioAttributes)
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
