import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
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
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        // Video feed
        if (_loading)
          const Center(child: CircularProgressIndicator(color: C.lime, strokeWidth: 2))
        else if (_videos.isEmpty)
          _emptyState()
        else
          _videoFeed(),

        // Header overlay
        Positioned(left: 0, right: 0, top: 0, child: _headerOverlay()),
      ]),
    );
  }

  Widget _headerOverlay() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 8, 20, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [C.bg.withAlpha(200), C.bg.withAlpha(0)],
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Logo row
        Row(children: [
          RichText(text: TextSpan(children: [
            TextSpan(text: 'GOD', style: S.headline.copyWith(color: C.lime, fontWeight: FontWeight.w800)),
            TextSpan(text: 'Mode', style: S.headline.copyWith(fontWeight: FontWeight.w400)),
          ])),
          const Spacer(),
          _iconBtn(Icons.search_rounded),
          const SizedBox(width: 8),
          _iconBtn(Icons.notifications_none_rounded),
        ]),
        const SizedBox(height: 12),
        // Category pills
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemCount: _categories.length,
            itemBuilder: (_, i) {
              final on = i == _catIdx;
              return GestureDetector(
                onTap: () { setState(() => _catIdx = i); _loadVideos(); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: on ? C.lime : C.white.withAlpha(12),
                    borderRadius: BorderRadius.circular(10),
                    border: on ? null : Border.all(color: C.white.withAlpha(8)),
                  ),
                  child: Text(_categories[i], style: S.body.copyWith(
                    color: on ? C.bg : C.white70,
                    fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                  )),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ]),
    );
  }

  Widget _iconBtn(IconData icon) {
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: C.white.withAlpha(10), borderRadius: BorderRadius.circular(10),
        border: Border.all(color: C.white.withAlpha(8)),
      ),
      child: Icon(icon, color: C.white70, size: 18),
    );
  }

  Widget _videoFeed() {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: _videos.length,
      onPageChanged: (i) => setState(() => _currentPage = i),
      itemBuilder: (ctx, i) => _ReelPage(video: _videos[i], isActive: i == _currentPage),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: C.limeSoft,
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
  late YoutubePlayerController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = YoutubePlayerController.fromVideoId(
      videoId: widget.video['videoId'] ?? '',
      autoPlay: widget.isActive,
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        loop: true,
        mute: false,
        playsInline: true,
      ),
    );
  }

  @override
  void didUpdateWidget(_ReelPage old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _ctrl.playVideo();
    } else if (!widget.isActive && old.isActive) {
      _ctrl.pauseVideo();
    }
  }

  @override
  void dispose() {
    _ctrl.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.video;
    return Stack(children: [
      // Full-screen YouTube player
      Positioned.fill(
        child: YoutubePlayer(controller: _ctrl),
      ),

      // Bottom gradient
      Positioned(left: 0, right: 0, bottom: 0, child: Container(
        height: 200,
        decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.transparent, C.bg.withAlpha(200), C.bg.withAlpha(240)],
        )),
      )),

      // Video info
      Positioned(
        left: 16, right: 80, bottom: 100,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Channel
          Row(children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: C.lime.withAlpha(30),
                border: Border.all(color: C.lime.withAlpha(40)),
              ),
              child: Center(child: Text(
                (v['channelName'] ?? '?')[0],
                style: S.caption.copyWith(color: C.lime, fontWeight: FontWeight.w800),
              )),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(
              v['channelName'] ?? '',
              style: S.body.copyWith(fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            )),
          ]),
          const SizedBox(height: 8),
          // Title
          Text(
            v['title'] ?? '',
            style: S.cardTitle.copyWith(height: 1.4),
            maxLines: 2, overflow: TextOverflow.ellipsis,
          ),
        ]),
      ),

      // Right side actions
      Positioned(
        right: 12, bottom: 110,
        child: Column(children: [
          _actionBtn(Icons.favorite_outline_rounded, '좋아요'),
          const SizedBox(height: 16),
          _actionBtn(Icons.chat_bubble_outline_rounded, '댓글'),
          const SizedBox(height: 16),
          _actionBtn(Icons.share_rounded, '공유'),
          const SizedBox(height: 16),
          _actionBtn(Icons.bookmark_outline_rounded, '저장'),
        ]),
      ),
    ]);
  }

  Widget _actionBtn(IconData icon, String label) {
    return Column(children: [
      Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: C.white.withAlpha(15),
          border: Border.all(color: C.white.withAlpha(10)),
        ),
        child: Icon(icon, color: C.white, size: 20),
      ),
      const SizedBox(height: 4),
      Text(label, style: S.caption.copyWith(color: C.white70)),
    ]);
  }
}
