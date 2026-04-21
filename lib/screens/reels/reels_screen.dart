import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_theme.dart';
import '../../widgets/native_youtube_player.dart';

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
          .limit(30);
      if (_catIdx > 0) {
        query = query.where('category', isEqualTo: _categories[_catIdx]);
      }
      final snap = await query.get();
      debugPrint('Reels: loaded ${snap.docs.length} videos');
      final vids = snap.docs.map((d) => d.data() as Map<String, dynamic>).toList();
      if (vids.isNotEmpty) debugPrint('First videoId: ${vids[0]['videoId']}');
      setState(() {
        _videos = vids;
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
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(children: [
        // 상단 헤더 (고정)
        Container(
          padding: EdgeInsets.fromLTRB(16, topPad + 6, 16, 8),
          color: C.bg,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              RichText(text: TextSpan(children: [
                TextSpan(text: 'GOD', style: S.title.copyWith(color: C.lime, fontWeight: FontWeight.w800, fontSize: 16)),
                TextSpan(text: 'Mode', style: S.title.copyWith(fontWeight: FontWeight.w400, fontSize: 16)),
              ])),
              const SizedBox(width: 6),
              Text('릴스', style: S.caption.copyWith(color: C.white70)),
              const Spacer(),
              if (_videos.isNotEmpty)
                Text('${_currentPage + 1}/${_videos.length}', style: S.caption.copyWith(color: C.white40)),
            ]),
            const SizedBox(height: 8),
            SizedBox(
              height: 30,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                separatorBuilder: (_, __) => const SizedBox(width: 5),
                itemCount: _categories.length,
                itemBuilder: (_, i) {
                  final on = i == _catIdx;
                  return GestureDetector(
                    onTap: () { setState(() => _catIdx = i); _loadVideos(); },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: on ? C.lime : Colors.white.withAlpha(15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_categories[i], style: S.body.copyWith(
                        color: on ? Colors.black : C.white70,
                        fontWeight: on ? FontWeight.w700 : FontWeight.w500, fontSize: 12,
                      )),
                    ),
                  );
                },
              ),
            ),
          ]),
        ),

        // 영상 영역
        Expanded(
          child: _loading
            ? const Center(child: CircularProgressIndicator(color: C.lime, strokeWidth: 2))
            : _videos.isEmpty
              ? _emptyState()
              : Stack(children: [
                  PageView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: _videos.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (_, i) => _ReelPage(
                      key: ValueKey(_videos[i]['videoId']),
                      video: _videos[i],
                      isActive: i == _currentPage,
                    ),
                  ),
                  // 하단 영상 정보
                  Positioned(left: 0, right: 0, bottom: 0, child: _bottomInfo()),
                ]),
        ),
      ]),
    );
  }

  Widget _bottomInfo() {
    if (_currentPage >= _videos.length) return const SizedBox();
    final v = _videos[_currentPage];
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withAlpha(220)],
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: C.lime.withAlpha(40),
              border: Border.all(color: C.lime.withAlpha(50)),
            ),
            child: Center(child: Text(
              (v['channelName'] ?? '?')[0],
              style: S.caption.copyWith(color: C.lime, fontWeight: FontWeight.w800, fontSize: 9),
            )),
          ),
          const SizedBox(width: 6),
          Expanded(child: Text(v['channelName'] ?? '', style: S.body.copyWith(fontWeight: FontWeight.w700, fontSize: 12), overflow: TextOverflow.ellipsis)),
        ]),
        const SizedBox(height: 4),
        Text(v['title'] ?? '', style: S.body.copyWith(fontSize: 11, height: 1.3, color: C.white70), maxLines: 2, overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  Widget _emptyState() {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 64, height: 64,
        decoration: BoxDecoration(shape: BoxShape.circle, color: C.limeSoft, border: Border.all(color: C.lime.withAlpha(30))),
        child: const Icon(Icons.play_arrow_rounded, color: C.lime, size: 28),
      ),
      const SizedBox(height: 16),
      Text('영상을 불러오는 중...', style: S.body.copyWith(color: C.grey)),
    ]));
  }
}

// ══════════════════════════════════════
// 개별 릴 페이지 — 네이티브 YouTube Player
// ══════════════════════════════════════
class _ReelPage extends StatefulWidget {
  final Map<String, dynamic> video;
  final bool isActive;
  const _ReelPage({super.key, required this.video, required this.isActive});
  @override
  State<_ReelPage> createState() => _ReelPageState();
}

class _ReelPageState extends State<_ReelPage> {
  final _playerKey = GlobalKey<NativeYoutubePlayerState>();
  bool _ready = false;
  bool _hasError = false;
  String _errorCode = '';

  @override
  void didUpdateWidget(_ReelPage old) {
    super.didUpdateWidget(old);
    if (!_ready) return;
    if (widget.isActive && !old.isActive) {
      _playerKey.currentState?.play();
    } else if (!widget.isActive && old.isActive) {
      _playerKey.currentState?.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.video;
    final thumbnail = v['thumbnail'] ?? '';
    final videoId = v['videoId'] ?? '';

    return Container(
      color: Colors.black,
      child: Stack(fit: StackFit.expand, children: [
        // 배경 썸네일 (로딩/에러 시)
        if (thumbnail.isNotEmpty && (!_ready || _hasError))
          Opacity(
            opacity: 0.3,
            child: Image.network(thumbnail, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox()),
          ),

        // 네이티브 YouTube Player
        if (!_hasError)
          NativeYoutubePlayer(
            key: _playerKey,
            videoId: videoId,
            autoPlay: widget.isActive,
            onReady: () { if (mounted) setState(() => _ready = true); },
            onError: (err) {
              debugPrint('YouTube error code: $err (videoId=${widget.video['videoId']})');
              if (mounted) setState(() { _hasError = true; _errorCode = err; });
            },
          ),

        // 로딩
        if (!_ready && !_hasError)
          const Center(child: CircularProgressIndicator(color: C.lime, strokeWidth: 2)),

        // 에러 → YouTube 앱으로 열기
        if (_hasError)
          Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (thumbnail.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(thumbnail, width: 200, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox()),
              ),
            const SizedBox(height: 8),
            Text('error: $_errorCode', style: const TextStyle(color: Colors.white38, fontSize: 10)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => launchUrl(Uri.parse('https://www.youtube.com/shorts/$videoId'), mode: LaunchMode.externalApplication),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: C.lime,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.open_in_new_rounded, color: C.bg, size: 16),
                  const SizedBox(width: 8),
                  Text('YouTube에서 보기', style: S.body.copyWith(color: C.bg, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ])),
      ]),
    );
  }
}
