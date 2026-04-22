import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

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

  void play()  => _controller.runJavaScript("document.querySelector('#yt-fs-video')?.play()");
  void pause() => _controller.runJavaScript("document.querySelector('#yt-fs-video')?.pause()");

  @override
  void initState() {
    super.initState();
    _buildController();
  }

  void _buildController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
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
        // 페이지 시작 즉시 검은 배경 (흰 화면 방지)
        onPageStarted: (_) => _controller.runJavaScript('''
          document.documentElement && (document.documentElement.style.background='#000');
          document.body && (document.body.style.cssText='background:#000!important;overflow:hidden!important');
        '''),
        onPageFinished: (_) => _injectControls(),
        onWebResourceError: (e) => debugPrint('WebView error: \${e.description}'),
      ));

    // Android 전용: 미디어 자동재생 허용
    final platform = _controller.platform;
    if (platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(false);
      platform.setMediaPlaybackRequiresUserGesture(false);
    }

    _controller.loadRequest(
      Uri.parse('https://www.youtube.com/shorts/${widget.videoId}'),
    );
  }

  Future<void> _injectControls() async {
    final shouldPlay = widget.autoPlay;
    await _controller.runJavaScript(r'''
(function() {
  'use strict';

  // ── 1. 즉시 검은 배경 ──
  document.documentElement.style.cssText = 'background:#000!important';
  document.body.style.cssText = 'background:#000!important;overflow:hidden!important;margin:0!important;padding:0!important';

  // ── 2. CSS: 기본 YouTube UI 숨김 + video 초기 세팅 ──
  var st = document.createElement('style');
  st.textContent = [
    'html,body{background:#000!important;overflow:hidden!important}',
    // 헤더
    '#masthead-container,ytd-masthead,#masthead,tp-yt-app-drawer,#guide{display:none!important}',
    // 오버레이/액션버튼
    'ytd-reel-player-overlay-renderer,.YtReelPlayerOverlayViewModelHost,[class*="reel-overlay"],[class*="reel-action"],[class*="shorts-action"],[id*="reel-overlay"]{display:none!important}',
    // 우리가 만들 전체화면 컨테이너
    '#yt-fs-wrap{position:fixed!important;top:0!important;left:0!important;width:100vw!important;height:100vh!important;background:#000!important;z-index:2147483647!important;overflow:hidden!important}',
    '#yt-fs-video{position:absolute!important;top:0!important;left:0!important;width:100%!important;height:100%!important;z-index:1!important}',
  ].join('');
  document.head.appendChild(st);

  // ── 3. video 요소 찾아서 전체화면 컨테이너로 이동 ──
  var attempts = 0;
  function hijackVideo() {
    var v = document.querySelector('video');
    if (!v) {
      if (++attempts < 40) { setTimeout(hijackVideo, 250); return; }
      Flutter.postMessage('error:timeout');
      return;
    }
    if (document.getElementById('yt-fs-wrap')) return; // 이미 처리됨

    // 전체화면 래퍼 생성
    var wrap = document.createElement('div');
    wrap.id = 'yt-fs-wrap';

    // video 복사본 생성 (src 공유)
    var nv = document.createElement('video');
    nv.id = 'yt-fs-video';
    nv.autoplay = ''' + (shouldPlay ? 'true' : 'false') + r''';
    nv.loop = true;
    nv.controls = false;
    nv.playsInline = true;
    nv.muted = false;

    // 원본 video의 소스 복사
    if (v.srcObject) {
      nv.srcObject = v.srcObject;
    } else if (v.currentSrc) {
      nv.src = v.currentSrc;
    } else {
      // src가 없으면 원본 이동
      wrap.appendChild(v);
      v.id = 'yt-fs-video';
      v.controls = false;
      v.loop = true;
      v.playsInline = true;
      document.body.appendChild(wrap);
      play(v);
      return;
    }

    // 화면 방향에 따라 object-fit 결정
    function setFit(vid) {
      vid.style.objectFit = (vid.videoWidth > 0 && vid.videoWidth > vid.videoHeight)
        ? 'contain'   // 가로 영상: 레터박스
        : 'cover';    // 세로 숏츠: 꽉 채움
    }
    nv.addEventListener('loadedmetadata', function() { setFit(nv); });

    wrap.appendChild(nv);
    document.body.appendChild(wrap);
    play(nv);
  }

  function play(vid) {
    ''' + (shouldPlay ? r'''
    vid.play()
      .then(function() { Flutter.postMessage('ready'); })
      .catch(function(e) {
        // 자동재생 실패 시 음소거 후 재시도
        vid.muted = true;
        vid.play()
          .then(function() { Flutter.postMessage('ready'); })
          .catch(function(e2) { Flutter.postMessage('error:' + e2.message); });
      });
    ''' : r'''
    Flutter.postMessage('ready');
    ''') + r'''
  }

  hijackVideo();
})();
''');
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
