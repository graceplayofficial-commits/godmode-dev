package com.example.godmode

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import com.pierfrancescosoffritti.androidyoutubeplayer.core.player.YouTubePlayer
import com.pierfrancescosoffritti.androidyoutubeplayer.core.player.listeners.AbstractYouTubePlayerListener
import com.pierfrancescosoffritti.androidyoutubeplayer.core.player.options.IFramePlayerOptions
import com.pierfrancescosoffritti.androidyoutubeplayer.core.player.views.YouTubePlayerView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class YoutubePlayerPlatformView(
    private val context: Context,
    viewId: Int,
    messenger: BinaryMessenger,
    params: Map<*, *>
) : PlatformView, MethodChannel.MethodCallHandler {

    private val container = FrameLayout(context)
    private val playerView: YouTubePlayerView
    private var youtubePlayer: YouTubePlayer? = null
    private val channel: MethodChannel
    private val videoId: String = params["videoId"] as? String ?: ""
    private val autoPlay: Boolean = params["autoPlay"] as? Boolean ?: false

    init {
        channel = MethodChannel(messenger, "youtube-player-$viewId")
        channel.setMethodCallHandler(this)

        playerView = YouTubePlayerView(context)

        val options = IFramePlayerOptions.Builder()
            .controls(0)
            .rel(0)
            .ivLoadPolicy(3)
            .ccLoadPolicy(0)
            .build()

        playerView.enableAutomaticInitialization = false
        playerView.initialize(object : AbstractYouTubePlayerListener() {
            override fun onReady(player: YouTubePlayer) {
                youtubePlayer = player
                if (autoPlay && videoId.isNotEmpty()) {
                    player.loadVideo(videoId, 0f)
                } else if (videoId.isNotEmpty()) {
                    player.cueVideo(videoId, 0f)
                }
                channel.invokeMethod("onReady", null)
            }

            override fun onError(player: YouTubePlayer, error: com.pierfrancescosoffritti.androidyoutubeplayer.core.player.PlayerConstants.PlayerError) {
                channel.invokeMethod("onError", error.name)
            }

            override fun onStateChange(player: YouTubePlayer, state: com.pierfrancescosoffritti.androidyoutubeplayer.core.player.PlayerConstants.PlayerState) {
                channel.invokeMethod("onStateChange", state.name)
                // 영상 끝나면 반복 재생
                if (state == com.pierfrancescosoffritti.androidyoutubeplayer.core.player.PlayerConstants.PlayerState.ENDED) {
                    player.seekTo(0f)
                    player.play()
                }
            }
        }, options)

        container.addView(playerView)
    }

    override fun getView(): View = container

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "play" -> { youtubePlayer?.play(); result.success(null) }
            "pause" -> { youtubePlayer?.pause(); result.success(null) }
            "loadVideo" -> {
                val id = call.argument<String>("videoId") ?: ""
                youtubePlayer?.loadVideo(id, 0f)
                result.success(null)
            }
            "seekTo" -> {
                val seconds = call.argument<Double>("seconds") ?: 0.0
                youtubePlayer?.seekTo(seconds.toFloat())
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun dispose() {
        playerView.release()
        channel.setMethodCallHandler(null)
    }
}
