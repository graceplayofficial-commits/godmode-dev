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
            _sectionTitle('MORE TESTS'),
            ..._testCards(context),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('TEST CENTER', style: AppTextStyles.label),
        const SizedBox(height: 4),
        Text('나를 알아가는\n신앙 테스트', style: AppTextStyles.displayLarge.copyWith(height: 1.15)),
        const SizedBox(height: 8),
        Text('테스트를 통해 나의 신앙 스타일을 발견하세요',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted)),
      ]),
    );
  }

  Widget _featured(BuildContext context) {
    return GestureDetector(
      onTap: () => _coming(context),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF2A1F05), Color(0xFF15120A), Color(0xFF0F0D08)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppColors.gold.withAlpha(25)),
          boxShadow: [BoxShadow(color: AppColors.gold.withAlpha(12), blurRadius: 30, offset: const Offset(0, 8))],
        ),
        child: Stack(children: [
          Positioned(right: -10, top: -10, child: Container(
            width: 180, height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [AppColors.gold.withAlpha(18), Colors.transparent]),
            ),
          )),
          Positioned(right: 22, top: 28, child: Text('🔮', style: TextStyle(fontSize: 80,
            shadows: [Shadow(color: Colors.black.withAlpha(80), blurRadius: 24, offset: const Offset(0, 8))],
          ))),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.gold]),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('추천', style: AppTextStyles.caption.copyWith(color: const Color(0xFF1A1400), fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 12),
              Text('신앙 성격 MBTI', style: AppTextStyles.headline),
              const SizedBox(height: 4),
              Text('나는 어떤 성경 인물 유형일까?', style: AppTextStyles.bodySmall.copyWith(color: AppColors.white50)),
              const SizedBox(height: 14),
              Row(children: [
                _infoPill('📝', '12문항'),
                const SizedBox(width: 8),
                _infoPill('⏱️', '5분'),
                const SizedBox(width: 8),
                _infoPill('🎭', '8유형'),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _infoPill(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.white.withAlpha(6)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(text, style: AppTextStyles.caption.copyWith(color: AppColors.white80)),
      ]),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
      child: Row(children: [
        Container(
          width: 3, height: 16,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.gold], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(text, style: AppTextStyles.label.copyWith(color: AppColors.secondary)),
      ]),
    );
  }

  List<Widget> _testCards(BuildContext context) {
    final tests = [
      _T('🔮', '신앙 성격 MBTI', '12문항 · 8가지 성경 인물 유형', const Color(0xFF2A1F05), AppColors.gold),
      _T('🙏', '나의 기도 스타일', '8문항 · 4가지 기도 유형', const Color(0xFF1A0A2E), AppColors.rhythmVioletAccent),
      _T('📖', '말씀 암송 레벨', '10문항 · 나의 말씀 능력 확인', const Color(0xFF0D2818), AppColors.noahGreenAccent),
      _T('🕊️', '신앙 은사 테스트', '15문항 · 7가지 은사 유형', const Color(0xFF0F0D33), AppColors.gachaIndigoAccent),
    ];
    return tests.map((t) => _TestCard(t: t, onTap: () => _coming(context))).toList();
  }

  void _coming(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('곧 준비됩니다!', style: AppTextStyles.body.copyWith(color: const Color(0xFF1A1400))),
      backgroundColor: AppColors.gold,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}

class _T {
  final String emoji, title, desc;
  final Color bg, accent;
  const _T(this.emoji, this.title, this.desc, this.bg, this.accent);
}

class _TestCard extends StatelessWidget {
  final _T t;
  final VoidCallback onTap;
  const _TestCard({required this.t, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [t.bg, Color.lerp(t.bg, AppColors.bg, 0.5)!],
            begin: Alignment.centerLeft, end: Alignment.centerRight,
          ),
          border: Border.all(color: t.accent.withAlpha(15)),
        ),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: t.accent.withAlpha(15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: t.accent.withAlpha(25)),
            ),
            child: Center(child: Text(t.emoji, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.title, style: AppTextStyles.cardTitle),
            const SizedBox(height: 4),
            Text(t.desc, style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted)),
          ])),
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: t.accent.withAlpha(12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.arrow_forward_ios_rounded, color: t.accent.withAlpha(120), size: 14),
          ),
        ]),
      ),
    );
  }
}
