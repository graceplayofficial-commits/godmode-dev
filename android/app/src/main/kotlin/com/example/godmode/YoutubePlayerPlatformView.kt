package com.example.godmode

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.view.View
import android.webkit.CookieManager
import android.webkit.JavascriptInterface
import android.webkit.WebChromeClient
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
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

    private val webView: WebView
    private val channel: MethodChannel
    private val videoId: String
    private val autoPlay: Boolean
    private val mainHandler = Handler(Looper.getMainLooper())

    init {
        videoId = params["videoId"]?.toString() ?: ""
        autoPlay = params["autoPlay"] == true
        android.util.Log.d("YTPlayer", "init videoId=$videoId autoPlay=$autoPlay")

        channel = MethodChannel(messenger, "youtube-player-$viewId")
        channel.setMethodCallHandler(this)

        // 쿠키 허용 (YouTube 재생에 필수)
        val cookieManager = CookieManager.getInstance()
        cookieManager.setAcceptCookie(true)

        webView = WebView(context).apply {
            settings.apply {
                javaScriptEnabled = true
                domStorageEnabled = true
                mediaPlaybackRequiresUserGesture = false
                cacheMode = WebSettings.LOAD_DEFAULT
                allowFileAccess = false
                // 브라우저처럼 보이게 UA 설정 (YouTube가 WebView UA 차단하는 경우 대비)
                userAgentString = "Mozilla/5.0 (Linux; Android 12; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.230 Mobile Safari/537.36"
            }
            setBackgroundColor(0xFF000000.toInt())
            webViewClient = WebViewClient()
            webChromeClient = WebChromeClient()
            addJavascriptInterface(PlayerBridge(), "Android")
        }

        // 써드파티 쿠키 허용 (YouTube iframe 필수)
        cookieManager.setAcceptThirdPartyCookies(webView, true)

        loadPlayer()
    }

    inner class PlayerBridge {
        @JavascriptInterface
        fun postMessage(msg: String) {
            android.util.Log.d("YTPlayer", "bridge msg=$msg videoId=$videoId")
            mainHandler.post {
                when {
                    msg == "ready" -> channel.invokeMethod("onReady", null)
                    msg.startsWith("state:") -> channel.invokeMethod("onStateChange", msg.drop(6))
                    msg.startsWith("error:") -> channel.invokeMethod("onError", msg.drop(6))
                }
            }
        }
    }

    private fun loadPlayer() {
        if (videoId.isEmpty()) return
        val autoPlayNum = if (autoPlay) 1 else 0
        val html = """<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1">
<style>
*{margin:0;padding:0;box-sizing:border-box;background:#000;overflow:hidden}
html,body{width:100%;height:100%}
#player{position:absolute;top:0;left:0;width:100%;height:100%}
</style>
</head>
<body>
<div id="player"></div>
<script src="https://www.youtube.com/iframe_api"></script>
<script>
var player;
function onYouTubeIframeAPIReady(){
    Android.postMessage('api_ready');
    player=new YT.Player('player',{
        videoId:'$videoId',
        playerVars:{
            controls:0,rel:0,showinfo:0,modestbranding:1,
            iv_load_policy:3,playsinline:1,
            autoplay:$autoPlayNum,loop:1,playlist:'$videoId',
            origin:'https://www.youtube.com'
        },
        events:{
            onReady:function(e){
                Android.postMessage('ready');
            },
            onStateChange:function(e){
                Android.postMessage('state:'+e.data);
                if(e.data===0){player.seekTo(0);player.playVideo();}
            },
            onError:function(e){
                Android.postMessage('error:'+e.data);
            }
        }
    });
}
window.onerror=function(msg,src,line){
    Android.postMessage('jserror:'+msg);
};
function playVideo(){if(player&&player.playVideo)player.playVideo();}
function pauseVideo(){if(player&&player.pauseVideo)player.pauseVideo();}
function loadNewVideo(id){if(player&&player.loadVideoById)player.loadVideoById(id);}
function seekTo(s){if(player&&player.seekTo)player.seekTo(s,true);}
</script>
</body>
</html>"""
        webView.loadDataWithBaseURL(
            "https://www.youtube.com",
            html,
            "text/html",
            "UTF-8",
            null
        )
    }

    override fun getView(): View = webView

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "play" -> {
                webView.evaluateJavascript("playVideo()", null)
                result.success(null)
            }
            "pause" -> {
                webView.evaluateJavascript("pauseVideo()", null)
                result.success(null)
            }
            "loadVideo" -> {
                val id = call.argument<String>("videoId") ?: ""
                webView.evaluateJavascript("loadNewVideo('$id')", null)
                result.success(null)
            }
            "seekTo" -> {
                val seconds = call.argument<Double>("seconds") ?: 0.0
                webView.evaluateJavascript("seekTo($seconds)", null)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun dispose() {
        channel.setMethodCallHandler(null)
        webView.destroy()
    }
}
