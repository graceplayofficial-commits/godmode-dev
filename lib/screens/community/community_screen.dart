import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/board_service.dart';
import '../auth/auth_screen.dart';
import 'write_post_screen.dart';
import 'post_detail_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});
  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _board = BoardService();
  final _categories = ['전체', '자유', '기도요청', '말씀나눔', '간증'];
  int _catIdx = 0;
  List<Map<String, dynamic>> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final cat = _catIdx == 0 ? null : _categories[_catIdx];
    final posts = await _board.getPosts(category: cat);
    if (mounted) setState(() { _posts = posts; _loading = false; });
  }

  void _requireAuth(VoidCallback action) {
    final auth = context.read<AuthService>();
    if (auth.isLoggedIn) {
      action();
    } else {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => const AuthScreen(reason: '커뮤니티 기능을 이용하려면 로그인이 필요해요'),
      )).then((result) { if (result == true) action(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          _header(),
          _categoryBar(),
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator(color: C.lime, strokeWidth: 2))
              : _posts.isEmpty
                ? _emptyState()
                : RefreshIndicator(
                    onRefresh: _load,
                    color: C.lime,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 140),
                      itemCount: _posts.length,
                      itemBuilder: (_, i) => _postCard(_posts[i]),
                    ),
                  ),
          ),
        ]),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () => _requireAuth(_writePost),
          backgroundColor: C.lime,
          child: const Icon(Icons.edit_rounded, color: C.bg),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('COMMUNITY', style: S.label.copyWith(fontSize: 10)),
          const SizedBox(height: 2),
          Text('커뮤니티', style: S.displayMedium),
        ]),
      ]),
    );
  }

  Widget _categoryBar() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final on = i == _catIdx;
          return GestureDetector(
            onTap: () { setState(() => _catIdx = i); _load(); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on ? C.lime : C.surface,
                borderRadius: BorderRadius.circular(10),
                border: on ? null : Border.all(color: C.border),
              ),
              child: Text(_categories[i], style: S.body.copyWith(
                color: on ? C.bg : C.grey,
                fontWeight: on ? FontWeight.w700 : FontWeight.w500, fontSize: 12,
              )),
            ),
          );
        },
      ),
    );
  }

  Widget _postCard(Map<String, dynamic> post) {
    final createdAt = post['createdAt'] as Timestamp?;
    final timeAgo = createdAt != null ? _timeAgo(createdAt.toDate()) : '';

    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(
          builder: (_) => PostDetailScreen(post: post),
        ));
        _load();
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: C.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 작성자 정보
          Row(children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle, color: C.limeSoft,
                border: Border.all(color: C.lime.withAlpha(30)),
              ),
              child: Center(child: Text(post['profileEmoji'] ?? '⚡', style: const TextStyle(fontSize: 14))),
            ),
            const SizedBox(width: 8),
            Text(post['nickname'] ?? '익명', style: S.body.copyWith(fontWeight: FontWeight.w700, fontSize: 12)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: C.elevated, borderRadius: BorderRadius.circular(4)),
              child: Text(post['category'] ?? '자유', style: S.caption.copyWith(color: C.grey)),
            ),
            const Spacer(),
            Text(timeAgo, style: S.caption.copyWith(color: C.greyDark)),
          ]),
          const SizedBox(height: 10),
          // 제목
          Text(post['title'] ?? '', style: S.cardTitle),
          const SizedBox(height: 4),
          // 내용 미리보기
          Text(post['content'] ?? '', style: S.bodySmall.copyWith(color: C.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          // 좋아요 + 댓글
          Row(children: [
            Icon(Icons.favorite_outline_rounded, size: 14, color: C.greyDark),
            const SizedBox(width: 4),
            Text('${post['likeCount'] ?? 0}', style: S.caption),
            const SizedBox(width: 12),
            Icon(Icons.chat_bubble_outline_rounded, size: 14, color: C.greyDark),
            const SizedBox(width: 4),
            Text('${post['commentCount'] ?? 0}', style: S.caption),
          ]),
        ]),
      ),
    );
  }

  Widget _emptyState() {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text('✍️', style: const TextStyle(fontSize: 48)),
      const SizedBox(height: 12),
      Text('아직 게시물이 없어요', style: S.title),
      const SizedBox(height: 6),
      Text('첫 번째 글을 작성해보세요!', style: S.bodySmall),
    ]));
  }

  void _writePost() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const WritePostScreen()));
    _load();
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${dt.month}/${dt.day}';
  }
}
