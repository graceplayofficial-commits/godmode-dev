import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import 'noah_tetris/noah_tetris_screen.dart';
import 'omok/omok_screen.dart';
import 'rhythm/rhythm_screen.dart';
import 'clicker/clicker_screen.dart';
import 'gacha/gacha_screen.dart';

class GameHubScreen extends StatelessWidget {
  const GameHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _header()),
            SliverToBoxAdapter(child: _featured(context)),
            SliverToBoxAdapter(child: _section('ALL GAMES')),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.82,
                ),
                delegate: SliverChildListDelegate(_cards(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('GAMES', style: S.label),
          const SizedBox(height: 2),
          Text('게임 허브', style: S.displayLarge),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: C.limeSoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: C.lime.withAlpha(30)),
          ),
          child: Row(children: [
            Icon(Icons.bolt_rounded, color: C.lime, size: 16),
            const SizedBox(width: 4),
            Text('2,480', style: S.body.copyWith(color: C.lime, fontWeight: FontWeight.w800)),
            Text(' PT', style: S.caption.copyWith(color: C.lime.withAlpha(120))),
          ]),
        ),
      ]),
    );
  }

  Widget _featured(BuildContext context) {
    return GestureDetector(
      onTap: () => _go(context, const NoahTetrisScreen()),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        height: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF0F2E22), Color(0xFF0A1F18), C.bg],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          border: Border.all(color: C.noahTeal.withAlpha(25)),
        ),
        child: Stack(children: [
          // Glow
          Positioned(right: -30, top: -30, child: Container(
            width: 160, height: 160,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [C.noahTeal.withAlpha(25), Colors.transparent])),
          )),
          // Emoji
          Positioned(right: 20, top: 16, child: Text('🚢', style: TextStyle(fontSize: 68,
            shadows: [Shadow(color: Colors.black.withAlpha(80), blurRadius: 20)]))),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: C.lime, borderRadius: BorderRadius.circular(4)),
                child: Text('NEW', style: S.badge.copyWith(color: C.bg)),
              ),
              const SizedBox(height: 10),
              Text('노아의 방주 테트리스', style: S.headline),
              const SizedBox(height: 3),
              Text('동물 블록을 방주에 채워라!', style: S.bodySmall.copyWith(color: C.white40)),
            ]),
          ),
        ]),
      ),
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

  List<Widget> _cards(BuildContext ctx) => [
    _Card('🚢', '노아의 방주\n테트리스', 'PUZZLE', C.noahTealBg, C.noahTeal, const NoahTetrisScreen(), 'NEW'),
    _Card('♟️', '예수님과\n오목', 'STRATEGY', C.omokEmeraldBg, C.omokEmerald, const OmokScreen(), null),
    _Card('🎵', '말씀 암송\n리듬게임', 'RHYTHM', C.rhythmVioletBg, C.rhythmViolet, const RhythmScreen(), null),
    _Card('⛪', '믿음의 왕국\n키우기', 'IDLE', C.clickerAmberBg, C.clickerAmber, const ClickerScreen(), null),
    _Card('🃏', '성경 인물\n카드 수집', 'GACHA', C.gachaBlueBg, C.gachaBlue, const GachaScreen(), 'HOT'),
  ].map((c) => _buildCard(ctx, c)).toList();

  Widget _buildCard(BuildContext ctx, _Card c) {
    return GestureDetector(
      onTap: () => _go(ctx, c.screen),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(colors: [c.bg, Color.lerp(c.bg, C.bg, 0.4)!],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
          border: Border.all(color: c.accent.withAlpha(15)),
        ),
        child: Stack(children: [
          // Corner glow
          Positioned(right: -10, top: -10, child: Container(width: 60, height: 60,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [c.accent.withAlpha(20), Colors.transparent])))),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: c.accent.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: c.accent.withAlpha(25))),
                  child: Center(child: Text(c.emoji, style: const TextStyle(fontSize: 24))),
                ),
                if (c.badge != null) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: c.badge == 'HOT' ? C.redSoft : C.limeSoft,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: c.badge == 'HOT' ? C.red.withAlpha(40) : C.lime.withAlpha(30))),
                  child: Text(c.badge!, style: S.badge.copyWith(
                    color: c.badge == 'HOT' ? C.red : C.lime)),
                ),
              ]),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: c.accent.withAlpha(12), borderRadius: BorderRadius.circular(5)),
                child: Text(c.genre, style: S.caption.copyWith(color: c.accent, letterSpacing: 1.2)),
              ),
              const SizedBox(height: 6),
              Text(c.title, style: S.cardTitle),
            ]),
          ),
        ]),
      ),
    );
  }

  void _go(BuildContext ctx, Widget s) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => s));
}

class _Card {
  final String emoji, title, genre;
  final Color bg, accent;
  final Widget screen;
  final String? badge;
  const _Card(this.emoji, this.title, this.genre, this.bg, this.accent, this.screen, this.badge);
}
