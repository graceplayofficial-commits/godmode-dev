import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/board_service.dart';

class WritePostScreen extends StatefulWidget {
  const WritePostScreen({super.key});
  @override
  State<WritePostScreen> createState() => _WritePostScreenState();
}

class _WritePostScreenState extends State<WritePostScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _board = BoardService();
  String _category = '자유';
  bool _posting = false;
  final _cats = ['자유', '기도요청', '말씀나눔', '간증'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty || _contentCtrl.text.trim().isEmpty) return;
    final auth = context.read<AuthService>();
    setState(() => _posting = true);

    await _board.createPost(
      uid: auth.uid,
      nickname: auth.nickname,
      profileEmoji: auth.profileEmoji,
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      category: _category,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
                child: const Icon(Icons.close_rounded, size: 18, color: C.grey),
              ),
            ),
            const SizedBox(width: 12),
            Text('글 작성', style: S.title),
            const Spacer(),
            GestureDetector(
              onTap: _posting ? null : _submit,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _posting ? C.greyDark : C.lime,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _posting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: C.bg))
                  : Text('완료', style: S.body.copyWith(color: C.bg, fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        // 카테고리 선택
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemCount: _cats.length,
            itemBuilder: (_, i) {
              final on = _category == _cats[i];
              return GestureDetector(
                onTap: () => setState(() => _category = _cats[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: on ? C.lime : C.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: on ? null : Border.all(color: C.border),
                  ),
                  child: Text(_cats[i], style: S.body.copyWith(
                    color: on ? C.bg : C.grey, fontWeight: on ? FontWeight.w700 : FontWeight.w500, fontSize: 12)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // 제목
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: _titleCtrl,
            style: S.headline,
            decoration: InputDecoration(
              hintText: '제목을 입력하세요',
              hintStyle: S.headline.copyWith(color: C.greyDark),
              border: InputBorder.none,
            ),
          ),
        ),
        Divider(color: C.border, indent: 20, endIndent: 20),
        // 내용
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _contentCtrl,
              style: S.body.copyWith(height: 1.6),
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: '내용을 입력하세요...',
                hintStyle: S.body.copyWith(color: C.greyDark),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ])),
    );
  }
}
