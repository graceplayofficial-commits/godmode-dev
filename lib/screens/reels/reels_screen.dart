import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' hide Video;
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
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
          .limit(30);
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
    final topPad = MediaQuery.of(context).padding.top;
    // 상단 헤더 높이(~80) + 하단 탭바(~96)를 고려한 영상 영역
    const headerH = 80.0;
    const tabBarH = 96.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(children: [
        // ── 상단 헤더 (고정) ──
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
                    onTap: () { setState(() { _catIdx = i; }); _loadVideos(); },
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

        // ── 영상 영역 (남은 공간, 하단 탭바 높이만큼 빼기) ──
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
                  // 하단 영상 정보 (탭바 위에)
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
// 개별 릴 페이지
// ══════════════════════════════════════
class _ReelPage extends StatefulWidget {
  final Map<String, dynamic> video;
  final bool isActive;
  const _ReelPage({super.key, required this.video, required this.isActive});
  @override
  State<_ReelPage> createState() => _ReelPageState();
}

class _ReelPageState extends State<_ReelPage> {
  Player? _player;
  VideoController? _videoCtrl;
  bool _loading = true;
  bool _hasError = false;
  final _yt = YoutubeExplode();

  @override
  void initState() {
    super.initState();
    if (widget.isActive) _loadVideo();
  }

  @override
  void didUpdateWidget(_ReelPage old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      if (_player == null) {
        _loadVideo();
      } else {
        _player!.play();
      }
    } else if (!widget.isActive && old.isActive) {
      _player?.pause();
    }
  }

  Future<void> _loadVideo() async {
    final videoId = widget.video['videoId'] ?? '';
    if (videoId.isEmpty) return;

    setState(() { _loading = true; _hasError = false; });

    try {
      final manifest = await _yt.videos.streams.getManifest(videoId);

      // Muxed 스트림 중 720p 이하 최고 화질 (에뮬레이터 호환성)
      final streams = manifest.muxed.toList()
        ..sort((a, b) => (b.videoResolution?.height ?? 0).compareTo(a.videoResolution?.height ?? 0));

      if (streams.isEmpty) {
        setState(() { _hasError = true; _loading = false; });
        return;
      }

      // 720p 이하로 선택 (에뮬레이터 안정성)
      final selected = streams.firstWhere(
        (s) => (s.videoResolution?.height ?? 0) <= 720,
        orElse: () => streams.last,
      );

      final streamUrl = selected.url.toString();

      _player = Player();
      _videoCtrl = VideoController(_player!);

      await _player!.open(Media(streamUrl));
      _player!.setPlaylistMode(PlaylistMode.single);

      if (mounted) setState(() => _loading = false);
    } catch (e) {
      debugPrint('Video load error: $e');
      if (mounted) setState(() { _hasError = true; _loading = false; });
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    _yt.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thumbnail = widget.video['thumbnail'] ?? '';

    return Container(
      color: Colors.black,
      child: Stack(fit: StackFit.expand, children: [
        // 배경 썸네일
        if (thumbnail.isNotEmpty && (_loading || _hasError))
          Opacity(
            opacity: _loading ? 0.4 : 0.3,
            child: Image.network(thumbnail, fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox()),
          ),

        // 네이티브 비디오 — contain으로 비율 유지
        if (_videoCtrl != null && !_hasError)
          Video(
            controller: _videoCtrl!,
            fit: BoxFit.contain,
            controls: NoVideoControls,
          ),

        // 로딩
        if (_loading)
          const Center(child: CircularProgressIndicator(color: C.lime, strokeWidth: 2)),

        // 에러
        if (_hasError)
          Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (thumbnail.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(thumbnail, width: 200, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox()),
              ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(color: C.white.withAlpha(10), borderRadius: BorderRadius.circular(8)),
              child: Text('재생 불가', style: S.bodySmall.copyWith(color: C.white40)),
            ),
          ])),
      ]),
    );
  }
}

Widget NoVideoControls(VideoState state) => const SizedBox.shrink();
