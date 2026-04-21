import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/board_service.dart';
import '../auth/auth_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;
  const PostDetailScreen({super.key, required this.post});
  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _board = BoardService();
  final _commentCtrl = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _loadingComments = true;
  late Map<String, dynamic> _post;

  @override
  void initState() {
    super.initState();
    _post = Map.from(widget.post);
    _loadComments();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final comments = await _board.getComments(_post['docId']);
    if (mounted) setState(() { _comments = comments; _loadingComments = false; });
  }

  void _requireAuth(VoidCallback action) {
    final auth = context.read<AuthService>();
    if (auth.isLoggedIn) {
      action();
    } else {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => const AuthScreen(reason: '로그인이 필요해요'),
      )).then((result) { if (result == true) action(); });
    }
  }

  Future<void> _submitComment() async {
    if (_commentCtrl.text.trim().isEmpty) return;
    final auth = context.read<AuthService>();
    await _board.addComment(
      postId: _post['docId'],
      uid: auth.uid,
      nickname: auth.nickname,
      profileEmoji: auth.profileEmoji,
      content: _commentCtrl.text.trim(),
    );
    _commentCtrl.clear();
    _post['commentCount'] = (_post['commentCount'] ?? 0) + 1;
    _loadComments();
    FocusScope.of(context).unfocus();
  }

  Future<void> _toggleLike() async {
    final auth = context.read<AuthService>();
    await _board.toggleLike(_post['docId'], auth.uid);
    final likedBy = List<String>.from(_post['likedBy'] ?? []);
    if (likedBy.contains(auth.uid)) {
      likedBy.remove(auth.uid);
      _post['likeCount'] = (_post['likeCount'] ?? 1) - 1;
    } else {
      likedBy.add(auth.uid);
      _post['likeCount'] = (_post['likeCount'] ?? 0) + 1;
    }
    _post['likedBy'] = likedBy;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final liked = auth.isLoggedIn && (List<String>.from(_post['likedBy'] ?? [])).contains(auth.uid);
    final createdAt = _post['createdAt'] as Timestamp?;
    final dateStr = createdAt != null
        ? '${createdAt.toDate().month}/${createdAt.toDate().day} ${createdAt.toDate().hour}:${createdAt.toDate().minute.toString().padLeft(2, '0')}'
        : '';

    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(child: Column(children: [
        // 헤더
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.border)),
                child: const Icon(Icons.arrow_back_ios_rounded, size: 16, color: C.grey),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(_post['category'] ?? '자유', style: S.title)),
            // 삭제 (본인 글만)
            if (auth.isLoggedIn && _post['uid'] == auth.uid)
              GestureDetector(
                onTap: () async {
                  await _board.deletePost(_post['docId']);
                  if (mounted) Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: C.red.withAlpha(15), borderRadius: BorderRadius.circular(8)),
                  child: Text('삭제', style: S.caption.copyWith(color: C.red)),
                ),
              ),
          ]),
        ),

        // 본문
        Expanded(child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          children: [
            // 작성자
            Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(shape: BoxShape.circle, color: C.limeSoft, border: Border.all(color: C.lime.withAlpha(30))),
                child: Center(child: Text(_post['profileEmoji'] ?? '⚡', style: const TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_post['nickname'] ?? '익명', style: S.cardTitle),
                Text(dateStr, style: S.caption),
              ]),
            ]),
            const SizedBox(height: 16),
            // 제목
            Text(_post['title'] ?? '', style: S.headline),
            const SizedBox(height: 12),
            // 내용
            Text(_post['content'] ?? '', style: S.body.copyWith(height: 1.7, color: C.white70)),
            const SizedBox(height: 20),
            // 좋아요 버튼
            GestureDetector(
              onTap: () => _requireAuth(_toggleLike),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: liked ? C.lime.withAlpha(15) : C.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: liked ? C.lime.withAlpha(30) : C.border),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(liked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                    size: 16, color: liked ? C.lime : C.grey),
                  const SizedBox(width: 6),
                  Text('${_post['likeCount'] ?? 0}', style: S.body.copyWith(color: liked ? C.lime : C.grey)),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            Divider(color: C.border),
            const SizedBox(height: 12),
            // 댓글 헤더
            Text('댓글 ${_post['commentCount'] ?? 0}', style: S.cardTitle),
            const SizedBox(height: 12),
            // 댓글 목록
            if (_loadingComments)
              const Center(child: CircularProgressIndicator(color: C.lime, strokeWidth: 2))
            else if (_comments.isEmpty)
              Center(child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('첫 댓글을 남겨보세요!', style: S.bodySmall),
              ))
            else
              ..._comments.map(_commentTile),
          ],
        )),

        // 댓글 입력
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          decoration: BoxDecoration(color: C.surface, border: Border(top: BorderSide(color: C.border))),
          child: Row(children: [
            Expanded(child: Container(
              decoration: BoxDecoration(color: C.elevated, borderRadius: BorderRadius.circular(10)),
              child: TextField(
                controller: _commentCtrl,
                style: S.body,
                decoration: InputDecoration(
                  hintText: '댓글을 입력하세요...',
                  hintStyle: S.body.copyWith(color: C.greyDark),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            )),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _requireAuth(_submitComment),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: C.lime, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.send_rounded, color: C.bg, size: 18),
              ),
            ),
          ]),
        ),
      ])),
    );
  }

  Widget _commentTile(Map<String, dynamic> comment) {
    final createdAt = comment['createdAt'] as Timestamp?;
    final timeStr = createdAt != null ? _timeAgo(createdAt.toDate()) : '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(shape: BoxShape.circle, color: C.elevated),
          child: Center(child: Text(comment['profileEmoji'] ?? '⚡', style: const TextStyle(fontSize: 13))),
        ),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(comment['nickname'] ?? '익명', style: S.body.copyWith(fontWeight: FontWeight.w700, fontSize: 12)),
            const SizedBox(width: 6),
            Text(timeStr, style: S.caption.copyWith(color: C.greyDark)),
          ]),
          const SizedBox(height: 3),
          Text(comment['content'] ?? '', style: S.body.copyWith(color: C.white70, height: 1.4)),
        ])),
      ]),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }
}
