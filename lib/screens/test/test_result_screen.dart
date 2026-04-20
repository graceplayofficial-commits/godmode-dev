import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_theme.dart';
import 'test_data.dart';

class TestResultScreen extends StatefulWidget {
  final TestDef test;
  final TestResult result;
  final Map<String, int> scores;
  const TestResultScreen({super.key, required this.test, required this.result, required this.scores});

  @override
  State<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends State<TestResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(children: [
          _header(),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              children: [
                _resultCard(r),
                const SizedBox(height: 16),
                _traitSection(r),
                const SizedBox(height: 16),
                _verseCard(r),
                if (!widget.test.id.contains('bible')) ...[
                  const SizedBox(height: 16),
                  _scoreBreakdown(),
                ],
                const SizedBox(height: 24),
                _actions(),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.border)),
            child: const Icon(Icons.close_rounded, size: 18, color: C.grey),
          ),
        ),
        const SizedBox(width: 12),
        Text('테스트 결과', style: S.title),
      ]),
    );
  }

  Widget _resultCard(TestResult r) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
          .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic)),
      child: FadeTransition(
        opacity: _animCtrl,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [C.lime.withAlpha(20), C.surface, C.bg],
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
            ),
            border: Border.all(color: C.lime.withAlpha(25)),
          ),
          child: Column(children: [
            // 이모지
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: C.limeSoft,
                border: Border.all(color: C.lime.withAlpha(40), width: 2),
                boxShadow: [BoxShadow(color: C.lime.withAlpha(20), blurRadius: 20)],
              ),
              child: Center(child: Text(r.emoji, style: const TextStyle(fontSize: 40))),
            ),
            const SizedBox(height: 16),
            // 타입
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: C.lime, borderRadius: BorderRadius.circular(8)),
              child: Text(r.type, style: S.body.copyWith(color: C.bg, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 12),
            // 타이틀
            Text(r.title, style: S.displayMedium),
            const SizedBox(height: 14),
            // 설명
            Text(r.description, style: S.body.copyWith(color: C.white70, height: 1.6), textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }

  Widget _traitSection(TestResult r) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: C.surface,
        border: Border.all(color: C.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('나의 특성', style: S.cardTitle),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: r.traits.map((t) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: C.limeSoft,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: C.lime.withAlpha(25)),
            ),
            child: Text(t, style: S.body.copyWith(color: C.lime)),
          )).toList(),
        ),
      ]),
    );
  }

  Widget _verseCard(TestResult r) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [C.lime.withAlpha(8), C.surface],
        ),
        border: Border.all(color: C.lime.withAlpha(15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.menu_book_rounded, color: C.lime, size: 18),
          const SizedBox(width: 8),
          Text('나의 말씀', style: S.cardTitle),
        ]),
        const SizedBox(height: 10),
        Text(r.verse, style: S.body.copyWith(color: C.white70, height: 1.5, fontStyle: FontStyle.italic)),
      ]),
    );
  }

  Widget _scoreBreakdown() {
    // 점수 정렬
    final sorted = widget.scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxScore = sorted.isEmpty ? 1 : sorted.first.value;

    // 결과 이름 매핑
    final nameMap = <String, String>{};
    for (final r in widget.test.results) {
      nameMap[r.id] = r.title;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: C.surface,
        border: Border.all(color: C.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('유형별 점수', style: S.cardTitle),
        const SizedBox(height: 14),
        ...sorted.take(5).map((e) {
          final pct = e.value / maxScore;
          final isTop = e.key == widget.result.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(nameMap[e.key] ?? e.key, style: S.body.copyWith(
                  color: isTop ? C.lime : C.grey, fontWeight: isTop ? FontWeight.w700 : FontWeight.w500))),
                Text('${e.value}점', style: S.caption.copyWith(color: isTop ? C.lime : C.greyDark)),
              ]),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: pct,
                  backgroundColor: C.elevated,
                  valueColor: AlwaysStoppedAnimation(isTop ? C.lime : C.greyDark),
                  minHeight: 6,
                ),
              ),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _actions() {
    return Column(children: [
      // 공유 버튼
      GestureDetector(
        onTap: () => _share(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: C.lime,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.share_rounded, color: C.bg, size: 18),
            const SizedBox(width: 8),
            Text('결과 공유하기', style: S.cardTitle.copyWith(color: C.bg)),
          ]),
        ),
      ),
      const SizedBox(height: 10),
      // 다시하기
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: C.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: C.border),
          ),
          child: Center(child: Text('다시 테스트하기', style: S.cardTitle.copyWith(color: C.grey))),
        ),
      ),
      const SizedBox(height: 10),
      // 돌아가기
      GestureDetector(
        onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
        child: Center(child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text('테스트 목록으로', style: S.bodySmall.copyWith(color: C.greyDark)),
        )),
      ),
    ]);
  }

  void _share() {
    final r = widget.result;
    final text = '[GOD MODE] ${widget.test.title}\n\n나의 결과: ${r.emoji} ${r.title} — ${r.type}\n\n${r.verse}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('결과가 복사되었습니다!', style: S.body.copyWith(color: C.bg)),
      backgroundColor: C.lime, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}
