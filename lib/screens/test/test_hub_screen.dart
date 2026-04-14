import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class TestHubScreen extends StatelessWidget {
  const TestHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 140),
          children: [
            _header(),
            _featured(context),
            _section('MORE TESTS'),
            ..._tests(context),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('TEST', style: S.label),
        const SizedBox(height: 2),
        Text('나를 알아가는\n신앙 테스트', style: S.displayLarge.copyWith(height: 1.15)),
        const SizedBox(height: 8),
        Text('테스트를 통해 나의 신앙 스타일을 발견하세요', style: S.bodySmall.copyWith(color: C.greyDark)),
      ]),
    );
  }

  Widget _featured(BuildContext context) {
    return GestureDetector(
      onTap: () => _coming(context),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        height: 190,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [C.lime.withAlpha(20), C.surface, C.bg],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          border: Border.all(color: C.lime.withAlpha(20)),
        ),
        child: Stack(children: [
          Positioned(right: -10, top: -10, child: Container(width: 150, height: 150,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [C.lime.withAlpha(12), Colors.transparent])))),
          Positioned(right: 20, top: 24, child: Text('🔮', style: TextStyle(fontSize: 72,
            shadows: [Shadow(color: Colors.black.withAlpha(80), blurRadius: 20)]))),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: C.lime, borderRadius: BorderRadius.circular(4)),
                child: Text('추천', style: S.badge.copyWith(color: C.bg)),
              ),
              const SizedBox(height: 10),
              Text('신앙 성격 MBTI', style: S.headline),
              const SizedBox(height: 4),
              Text('나는 어떤 성경 인물 유형일까?', style: S.bodySmall.copyWith(color: C.white40)),
              const SizedBox(height: 12),
              Row(children: [
                _pill('📝', '12문항'), const SizedBox(width: 6),
                _pill('⏱️', '5분'), const SizedBox(width: 6),
                _pill('🎭', '8유형'),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _pill(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: C.white.withAlpha(8), borderRadius: BorderRadius.circular(6),
        border: Border.all(color: C.white.withAlpha(6))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 11)),
        const SizedBox(width: 3),
        Text(text, style: S.caption.copyWith(color: C.white70)),
      ]),
    );
  }

  Widget _section(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(children: [
        Container(width: 3, height: 14, decoration: BoxDecoration(
          color: C.lime, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(text, style: S.label.copyWith(color: C.grey)),
      ]),
    );
  }

  List<Widget> _tests(BuildContext ctx) {
    final list = [
      _T('🔮', '신앙 성격 MBTI', '12문항 · 8가지 성경 인물 유형', C.lime),
      _T('🙏', '나의 기도 스타일', '8문항 · 4가지 기도 유형', C.rhythmViolet),
      _T('📖', '말씀 암송 레벨', '10문항 · 나의 말씀 능력 확인', C.noahTeal),
      _T('🕊️', '신앙 은사 테스트', '15문항 · 7가지 은사 유형', C.gachaBlue),
    ];
    return list.map((t) => _testCard(ctx, t)).toList();
  }

  Widget _testCard(BuildContext ctx, _T t) {
    return GestureDetector(
      onTap: () => _coming(ctx),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: C.surface,
          border: Border.all(color: t.accent.withAlpha(12)),
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: t.accent.withAlpha(15), borderRadius: BorderRadius.circular(12),
              border: Border.all(color: t.accent.withAlpha(20))),
            child: Center(child: Text(t.emoji, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.title, style: S.cardTitle),
            const SizedBox(height: 3),
            Text(t.desc, style: S.bodySmall.copyWith(color: C.greyDark)),
          ])),
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: t.accent.withAlpha(10), borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.arrow_forward_ios_rounded, color: t.accent.withAlpha(100), size: 12),
          ),
        ]),
      ),
    );
  }

  void _coming(BuildContext ctx) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text('곧 준비됩니다!', style: S.body.copyWith(color: C.bg)),
      backgroundColor: C.lime, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}

class _T {
  final String emoji, title, desc;
  final Color accent;
  const _T(this.emoji, this.title, this.desc, this.accent);
}
