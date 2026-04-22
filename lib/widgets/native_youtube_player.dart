import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NativeYoutubePlayer extends StatefulWidget {
  final String videoId;
  final bool autoPlay;
  final VoidCallback? onReady;
  final ValueChanged<String>? onError;

  const NativeYoutubePlayer({
    super.key,
    required this.videoId,
    this.autoPlay = false,
    this.onReady,
    this.onError,
  });

  @override
  State<NativeYoutubePlayer> createState() => NativeYoutubePlayerState();
}

class NativeYoutubePlayerState extends State<NativeYoutubePlayer> {
  late final WebViewController _controller;

  void play()  => _controller.runJavaScript("document.querySelector('video')?.play()");
  void pause() => _controller.runJavaScript("document.querySelector('video')?.pause()");

  @override
  void initState() {
    super.initState();
    _buildController();
  }

  void _buildController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      // 실제 모바일 Chrome 처럼 보이게 UA 설정
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 12; Pixel 6) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/120.0.6099.230 Mobile Safari/537.36',
      )
      ..addJavaScriptChannel(
        'Flutter',
        onMessageReceived: (msg) {
          final data = msg.message;
          debugPrint('YT bridge: $data (${widget.videoId})');
          if (data == 'ready') {
            widget.onReady?.call();
          } else if (data.startsWith('error:')) {
            widget.onError?.call(data.substring(6));
          }
        },
      )
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => _injectControls(),
        onWebResourceError: (e) {
          debugPrint('WebView resource error: ${e.description}');
        },
      ))
      ..loadRequest(
        Uri.parse('https://www.youtube.com/shorts/${widget.videoId}'),
      );
  }

  Future<void> _injectControls() async {
    final shouldPlay = widget.autoPlay;
    await _controller.runJavaScript('''
(function() {
  // ── CSS: YouTube UI 숨기고 video만 전체화면 ──
  var s = document.createElement('style');
  s.textContent = `
    * { box-sizing: border-box; }
    body {
      background: #000 !important;
      overflow: hidden !important;
      margin: 0 !important;
      padding: 0 !important;
    }
    video {
      position: fixed !important;
      top: 0 !important; left: 0 !important;
      width: 100vw !important; height: 100vh !important;
      object-fit: cover !important;
      z-index: 2147483647 !important;
    }
    /* YouTube Shorts 오버레이 UI 숨기기 */
    ytd-masthead,
    #masthead-container,
    tp-yt-app-drawer,
    #mini-guide,
    ytd-mini-guide-renderer,
    ytd-reel-player-overlay-renderer,
    .YtReelPlayerOverlayViewModelHost,
    .reel-player-overlay-actions,
    #above-the-fold,
    ytd-shorts { background: #000 !important; }
  `;
  document.head.appendChild(s);

  // ── video 요소 찾아서 제어 ──
  var attempts = 0;
  function setupVideo() {
    var v = document.querySelector('video');
    if (!v && attempts < 20) {
      attempts++;
      setTimeout(setupVideo, 500);
      return;
    }
    if (!v) {
      Flutter.postMessage('error:video_not_found');
      return;
    }

    v.loop = true;
    v.controls = false;
    v.playsInline = true;

    if (${shouldPlay ? 'true' : 'false'}) {
      v.play()
        .then(function() { Flutter.postMessage('ready'); })
        .catch(function(e) { Flutter.postMessage('error:' + e.message); });
    } else {
      Flutter.postMessage('ready');
    }
  }
  setupVideo();
})();
''');
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
