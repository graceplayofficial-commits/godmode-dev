import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/app_theme.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});
  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final _categories = ['전체', '찬양', '말씀', '간증', '기도'];
  int _catIdx = 0;
  List<Map<String, dynamic>> _videos = [];
  bool _loading = true;
  int _currentPage = 0;
  bool _headerVisible = true;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() => _loading = true);
    try {
      Query query = FirebaseFirestore.instance
          .collection('videos')
          .orderBy('publishedAt', descending: true)
          .limit(50);
      if (_catIdx > 0) {
        query = query.where('category', isEqualTo: _categories[_catIdx]);
      }
      final snap = await query.get();
      setState(() {
        _videos = snap.docs.map((d) => d.data() as Map<String, dynamic>).toList();
        _loading = false;
        _currentPage = 0;
      });
    } catch (e) {
      debugPrint('Firestore error: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        // Video feed
        if (_loading)
          const Center(child: CircularProgressIndicator(color: C.lime, strokeWidth: 2))
        else if (_videos.isEmpty)
          _emptyState()
        else
          _videoFeed(),

        // 탭 시 헤더 토글
        if (!_loading && _videos.isNotEmpty)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => setState(() => _headerVisible = !_headerVisible),
              child: const SizedBox(),
            ),
          ),

        // Header — 탭하면 숨김/표시
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          left: 0, right: 0,
          top: _headerVisible ? 0 : -120,
          child: _header(),
        ),
      ]),
    );
  }

  Widget _header() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 6, 16, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.black.withAlpha(180), Colors.black.withAlpha(80), Colors.transparent],
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Logo row — 컴팩트
        Row(children: [
          RichText(text: TextSpan(children: [
            TextSpan(text: 'GOD', style: S.title.copyWith(color: C.lime, fontWeight: FontWeight.w800, fontSize: 16)),
            TextSpan(text: 'Mode', style: S.title.copyWith(fontWeight: FontWeight.w400, fontSize: 16)),
          ])),
          const SizedBox(width: 6),
          Text('릴스', style: S.caption.copyWith(color: C.white70)),
          const Spacer(),
          Text('${_currentPage + 1}/${_videos.length}', style: S.caption.copyWith(color: C.white40)),
        ]),
        const SizedBox(height: 8),
        // Categories — 컴팩트
        SizedBox(
          height: 30,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            separatorBuilder: (_, __) => const SizedBox(width: 5),
            itemCount: _categories.length,
            itemBuilder: (_, i) {
              final on = i == _catIdx;
              return GestureDetector(
                onTap: () { setState(() { _catIdx = i; _headerVisible = true; }); _loadVideos(); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: on ? C.lime : Colors.white.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_categories[i], style: S.body.copyWith(
                    color: on ? Colors.black : C.white70,
                    fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 12,
                  )),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _videoFeed() {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: _videos.length,
      onPageChanged: (i) => setState(() { _currentPage = i; _headerVisible = false; }),
      itemBuilder: (ctx, i) => _ReelPage(video: _videos[i], isActive: i == _currentPage),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle, color: C.limeSoft,
            border: Border.all(color: C.lime.withAlpha(30)),
          ),
          child: const Icon(Icons.play_arrow_rounded, color: C.lime, size: 28),
        ),
        const SizedBox(height: 16),
        Text('영상을 불러오는 중...', style: S.body.copyWith(color: C.grey)),
      ]),
    );
  }
}

class _ReelPage extends StatefulWidget {
  final Map<String, dynamic> video;
  final bool isActive;
  const _ReelPage({required this.video, required this.isActive});
  @override
  State<_ReelPage> createState() => _ReelPageState();
}

class _ReelPageState extends State<_ReelPage> {
  WebViewController? _ctrl;
  bool _loaded = false;

  // YouTube Shorts를 깔끔하게 보여주기 위한 CSS/JS 주입
  static const _injectedCSS = '''
    /* YouTube 상단 내비게이션 숨김 */
    #header, ytm-mobile-topbar-renderer, .mobile-topbar-header,
    .ytm-autonav-bar, header, .player-controls-top,
    ytm-pivot-bar-renderer, .pivot-bar {
      display: none !important;
    }
    /* YouTube 하단 내비게이션 숨김 */
    ytm-bottom-bar-container, .bottom-bar-container,
    .ytm-bottom-sheet-overlay {
      display: none !important;
    }
    /* 전체화면 느낌 */
    body { background: black !important; overflow: hidden !important; }
    .player-container { margin-top: 0 !important; }
  ''';

  static const _injectScript = '''
    var style = document.createElement('style');
    style.textContent = `$_injectedCSS`;
    document.head.appendChild(style);

    // 반복 주입 (YouTube SPA 대응)
    var observer = new MutationObserver(function() {
      if (!document.querySelector('#godmode-style')) {
        var s = document.createElement('style');
        s.id = 'godmode-style';
        s.textContent = `$_injectedCSS`;
        document.head.appendChild(s);
      }
    });
    observer.observe(document.body, {childList: true, subtree: true});
  ''';

  @override
  void initState() {
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      _initWebView();
    }
  }

  void _initWebView() {
    final videoId = widget.video['videoId'] ?? '';
    _ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          // CSS 주입
          _ctrl?.runJavaScript(_injectScript);
          if (mounted) setState(() => _loaded = true);
        },
      ))
      ..setUserAgent('Mozilla/5.0 (Linux; Android 13; SM-G991B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36')
      ..loadRequest(Uri.parse('https://www.youtube.com/shorts/$videoId'));
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.video;
    final thumbnail = v['thumbnail'] ?? '';

    return Container(
      color: Colors.black,
      child: Stack(children: [
        // WebView (모바일)
        if (_ctrl != null)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: _loaded ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              child: WebViewWidget(controller: _ctrl!),
            ),
          ),

        // 데스크톱 fallback — 썸네일
        if (_ctrl == null)
          Positioned.fill(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (thumbnail.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(thumbnail, width: 300, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox()),
                ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(v['title'] ?? '', style: S.cardTitle, textAlign: TextAlign.center),
              ),
              const SizedBox(height: 8),
              Text(v['channelName'] ?? '', style: S.bodySmall),
            ]),
          ),

        // 로딩 — 썸네일 배경 + 스피너
        if (_ctrl != null && !_loaded)
          Positioned.fill(child: Container(
            color: Colors.black,
            child: Stack(children: [
              if (thumbnail.isNotEmpty)
                Center(child: Opacity(
                  opacity: 0.3,
                  child: Image.network(thumbnail, width: 250, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox()),
                )),
              const Center(child: CircularProgressIndicator(color: C.lime, strokeWidth: 2)),
            ]),
          )),
      ]),
    );
  }
}
