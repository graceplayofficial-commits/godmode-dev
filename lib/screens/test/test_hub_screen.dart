import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import 'test_data.dart';
import 'test_screen.dart';

class TestHubScreen extends StatelessWidget {
  const TestHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            _header(),
            _heroTest(context),
            _section('빠른 테스트'),
            _quickTests(context),
            _section('내 결과'),
            _myResults(),
            _section('전체 테스트'),
            ..._fullList(context),
          ],
        ),
      ),
    );
  }

  // ── 상단 헤더: 타이틀 + 완료 카운터
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('TEST', style: S.label.copyWith(fontSize: 10)),
          const SizedBox(height: 2),
          Text('신앙 테스트', style: S.displayLarge),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: C.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: C.border),
          ),
          child: Column(children: [
            Text('0/4', style: S.title.copyWith(color: C.lime)),
            Text('완료', style: S.caption),
          ]),
        ),
      ]),
    );
  }

  // ── 히어로 테스트: 큰 카드, 캐릭터 일러스트 영역, CTA 버튼
  Widget _heroTest(BuildContext context) {
    return GestureDetector(
      onTap: () => _goTest(context, mbtiTest),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [C.lime.withAlpha(18), C.surface, C.bg],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          border: Border.all(color: C.lime.withAlpha(18)),
        ),
        child: Column(children: [
          // 상단: 이모지 + 배지 영역
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.8,
                colors: [C.lime.withAlpha(12), Colors.transparent],
              ),
            ),
            child: Stack(children: [
              Center(child: Text('🔮', style: TextStyle(fontSize: 72,
                shadows: [Shadow(color: C.lime.withAlpha(40), blurRadius: 30)]))),
              Positioned(left: 16, top: 16, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: C.lime, borderRadius: BorderRadius.circular(6)),
                child: Text('MOST POPULAR', style: S.badge.copyWith(color: C.bg)),
              )),
            ]),
          ),
          // 하단: 정보 + CTA
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('신앙 성격 MBTI', style: S.headline),
              const SizedBox(height: 6),
              Text('나는 다윗형? 바울형? 에스더형?\n12개 질문으로 나의 신앙 유형을 알아보세요', style: S.bodySmall.copyWith(height: 1.5)),
              const SizedBox(height: 14),
              Row(children: [
                _infoPill('📝 12문항'), const SizedBox(width: 8),
                _infoPill('⏱️ 5분'), const SizedBox(width: 8),
                _infoPill('🎭 8유형'),
              ]),
              const SizedBox(height: 16),
              // CTA 버튼
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: C.lime,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text('테스트 시작하기', style: S.cardTitle.copyWith(color: C.bg))),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _infoPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: C.white.withAlpha(6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: C.white.withAlpha(6)),
      ),
      child: Text(text, style: S.caption.copyWith(color: C.white70)),
    );
  }

  // ── 섹션 헤더
  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
      child: Row(children: [
        Container(width: 3, height: 14, decoration: BoxDecoration(color: C.lime, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: S.title),
      ]),
    );
  }

  // ── 빠른 테스트: 가로 스크롤 정사각형 카드
  Widget _quickTests(BuildContext context) {
    final tests = [
      _Q('🙏', '기도 스타일', '4유형', C.rhythmViolet, prayerTest),
      _Q('📖', '암송 레벨', '5단계', C.noahTeal, bibleTest),
      _Q('🕊️', '은사 테스트', '7유형', C.gachaBlue, giftTest),
    ];
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: tests.length,
        itemBuilder: (_, i) {
          final q = tests[i];
          return GestureDetector(
            onTap: () => _goTest(context, q.testDef, isBible: q.testDef.id == 'bible'),
            child: Container(
              width: 130,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: C.surface,
                border: Border.all(color: q.accent.withAlpha(15)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(q.emoji, style: const TextStyle(fontSize: 30)),
                const Spacer(),
                Text(q.title, style: S.cardTitle),
                const SizedBox(height: 2),
                Text(q.result, style: S.caption.copyWith(color: q.accent)),
              ]),
            ),
          );
        },
      ),
    );
  }

  // ── 내 결과: 아직 없을 때
  Widget _myResults() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: C.surface,
        border: Border.all(color: C.border),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: C.limeSoft, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.assessment_outlined, color: C.lime, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('아직 완료한 테스트가 없어요', style: S.cardTitle),
          const SizedBox(height: 2),
          Text('테스트를 완료하면 여기서 결과를 확인할 수 있어요', style: S.bodySmall),
        ])),
      ]),
    );
  }

  // ── 전체 테스트 리스트
  List<Widget> _fullList(BuildContext context) {
    final tests = [
      _T('🔮', '신앙 성격 MBTI', '12문항 · 8가지 유형', '1.2K명 참여', C.lime, mbtiTest, false),
      _T('🙏', '나의 기도 스타일', '8문항 · 4가지 유형', '843명 참여', C.rhythmViolet, prayerTest, false),
      _T('📖', '말씀 암송 레벨', '10문항 · 5단계', '621명 참여', C.noahTeal, bibleTest, true),
      _T('🕊️', '신앙 은사 테스트', '15문항 · 7가지 유형', '458명 참여', C.gachaBlue, giftTest, false),
    ];
    return tests.map((t) => GestureDetector(
      onTap: () => _goTest(context, t.testDef, isBible: t.isBible),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: C.surface,
          border: Border.all(color: t.accent.withAlpha(10)),
        ),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: t.accent.withAlpha(15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: t.accent.withAlpha(20)),
            ),
            child: Center(child: Text(t.emoji, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.title, style: S.cardTitle),
            const SizedBox(height: 4),
            Text(t.desc, style: S.bodySmall),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.people_outline_rounded, size: 12, color: t.accent.withAlpha(150)),
              const SizedBox(width: 4),
              Text(t.social, style: S.caption.copyWith(color: t.accent)),
            ]),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: t.accent.withAlpha(12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('시작', style: S.body.copyWith(color: t.accent, fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
    )).toList();
  }

  void _goTest(BuildContext ctx, TestDef test, {bool isBible = false}) {
    Navigator.push(ctx, MaterialPageRoute(
      builder: (_) => TestScreen(test: test, isBibleTest: isBible),
    ));
  }
}

class _Q {
  final String emoji, title, result;
  final Color accent;
  final TestDef testDef;
  const _Q(this.emoji, this.title, this.result, this.accent, this.testDef);
}

class _T {
  final String emoji, title, desc, social;
  final Color accent;
  final TestDef testDef;
  final bool isBible;
  const _T(this.emoji, this.title, this.desc, this.social, this.accent, this.testDef, this.isBible);
}
