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
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            _profileBar(),
            _dailyMission(context),
            _section('이어서 플레이', trailing: '전체보기'),
            _recentlyPlayed(context),
            _section('인기 게임'),
            _featuredRow(context),
            _section('전체 게임'),
            _allGames(context),
          ],
        ),
      ),
    );
  }

  // ── 상단: 유저 인사 + 레벨 + 포인트
  Widget _profileBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(children: [
        // 아바타
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(colors: [C.lime.withAlpha(40), C.lime.withAlpha(15)]),
            border: Border.all(color: C.lime.withAlpha(40)),
          ),
          child: const Center(child: Text('⚡', style: TextStyle(fontSize: 22))),
        ),
        const SizedBox(width: 12),
        // 인사 + 레벨
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('GOD MODE', style: S.label.copyWith(fontSize: 10)),
          const SizedBox(height: 2),
          Row(children: [
            Text('게임 허브', style: S.headline),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: C.limeSoft, borderRadius: BorderRadius.circular(4)),
              child: Text('Lv.3', style: S.badge.copyWith(color: C.lime)),
            ),
          ]),
        ])),
        // 포인트
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: C.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: C.border),
          ),
          child: Row(children: [
            Icon(Icons.bolt_rounded, color: C.lime, size: 16),
            const SizedBox(width: 4),
            Text('2,480', style: S.body.copyWith(color: C.lime, fontWeight: FontWeight.w800)),
          ]),
        ),
      ]),
    );
  }

  // ── 일일 미션 카드
  Widget _dailyMission(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(colors: [C.lime.withAlpha(15), C.surface]),
        border: Border.all(color: C.lime.withAlpha(20)),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: C.limeSoft, borderRadius: BorderRadius.circular(10)),
          child: const Center(child: Text('🎯', style: TextStyle(fontSize: 20))),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('오늘의 미션', style: S.cardTitle),
          const SizedBox(height: 2),
          Text('게임 2판 플레이하고 100PT 받기', style: S.bodySmall),
        ])),
        // 진행도
        Stack(alignment: Alignment.center, children: [
          SizedBox(
            width: 40, height: 40,
            child: CircularProgressIndicator(
              value: 0.5, strokeWidth: 3,
              backgroundColor: C.border,
              valueColor: const AlwaysStoppedAnimation(C.lime),
            ),
          ),
          Text('1/2', style: S.caption.copyWith(color: C.lime, fontWeight: FontWeight.w800)),
        ]),
      ]),
    );
  }

  // ── 섹션 헤더
  Widget _section(String title, {String? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(children: [
        Container(width: 3, height: 14, decoration: BoxDecoration(color: C.lime, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: S.title),
        const Spacer(),
        if (trailing != null)
          Text(trailing, style: S.bodySmall.copyWith(color: C.lime)),
      ]),
    );
  }

  // ── 최근 플레이: 가로 스크롤 작은 카드
  Widget _recentlyPlayed(BuildContext context) {
    final recent = [
      _G('🚢', '노아 테트리스', '32,400 PT', C.noahTeal, C.noahTealBg, const NoahTetrisScreen()),
      _G('♟️', '오목', '5승 2패', C.omokEmerald, C.omokEmeraldBg, const OmokScreen()),
      _G('⛪', '믿음의 왕국', '초당 120pt', C.clickerAmber, C.clickerAmberBg, const ClickerScreen()),
    ];
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: recent.length,
        itemBuilder: (_, i) {
          final g = recent[i];
          return GestureDetector(
            onTap: () => _go(context, g.screen),
            child: Container(
              width: 200,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: g.bg,
                border: Border.all(color: g.accent.withAlpha(20)),
              ),
              child: Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: g.accent.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text(g.emoji, style: const TextStyle(fontSize: 26))),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(g.title, style: S.cardTitle),
                    const SizedBox(height: 4),
                    Text(g.stat, style: S.caption.copyWith(color: g.accent)),
                  ],
                )),
              ]),
            ),
          );
        },
      ),
    );
  }

  // ── 인기 게임: 대형 가로 스크롤 카드
  Widget _featuredRow(BuildContext context) {
    final featured = [
      _F('🚢', '노아의 방주\n테트리스', '동물 블록으로 방주를 채워라!', 'PUZZLE', 'NEW', C.noahTeal, C.noahTealBg, const NoahTetrisScreen()),
      _F('🃏', '성경 인물\n카드 수집', '전설 카드를 모아라!', 'GACHA', 'HOT', C.gachaBlue, C.gachaBlueBg, const GachaScreen()),
      _F('🎵', '말씀 암송\n리듬게임', '박자에 맞춰 말씀을 외워라!', 'RHYTHM', null, C.rhythmViolet, C.rhythmVioletBg, const RhythmScreen()),
    ];
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: featured.length,
        itemBuilder: (_, i) {
          final f = featured[i];
          return GestureDetector(
            onTap: () => _go(context, f.screen),
            child: Container(
              width: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [f.bg, Color.lerp(f.bg, C.bg, 0.5)!],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                border: Border.all(color: f.accent.withAlpha(15)),
              ),
              child: Stack(children: [
                // Glow
                Positioned(right: -20, top: -20, child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [f.accent.withAlpha(20), Colors.transparent])),
                )),
                // Emoji
                Positioned(right: 16, top: 16, child: Text(f.emoji, style: TextStyle(fontSize: 56,
                  shadows: [Shadow(color: Colors.black.withAlpha(60), blurRadius: 16)]))),
                // Content
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(color: f.accent.withAlpha(20), borderRadius: BorderRadius.circular(5)),
                        child: Text(f.genre, style: S.badge.copyWith(color: f.accent)),
                      ),
                      if (f.badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(color: C.lime, borderRadius: BorderRadius.circular(5)),
                          child: Text(f.badge!, style: S.badge.copyWith(color: C.bg)),
                        ),
                      ],
                    ]),
                    const SizedBox(height: 8),
                    Text(f.title, style: S.headline.copyWith(height: 1.25)),
                    const SizedBox(height: 4),
                    Text(f.desc, style: S.bodySmall.copyWith(color: C.white40)),
                  ]),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }

  // ── 전체 게임: 가로 전폭 리스트 카드
  Widget _allGames(BuildContext context) {
    final games = [
      _A('🚢', '노아의 방주 테트리스', 'PUZZLE', '최고 32,400pt', C.noahTeal, C.noahTealBg, const NoahTetrisScreen()),
      _A('♟️', '예수님과 오목', 'STRATEGY', '5승 2패', C.omokEmerald, C.omokEmeraldBg, const OmokScreen()),
      _A('🎵', '말씀 암송 리듬게임', 'RHYTHM', '랭크 A', C.rhythmViolet, C.rhythmVioletBg, const RhythmScreen()),
      _A('⛪', '믿음의 왕국 키우기', 'IDLE', '가나안 입성', C.clickerAmber, C.clickerAmberBg, const ClickerScreen()),
      _A('🃏', '성경 인물 카드 수집', 'GACHA', '12/17 수집', C.gachaBlue, C.gachaBlueBg, const GachaScreen()),
    ];
    return Column(
      children: games.map((a) => GestureDetector(
        onTap: () => _go(context, a.screen),
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: C.surface,
            border: Border.all(color: a.accent.withAlpha(10)),
          ),
          child: Row(children: [
            // 아이콘
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: a.bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: a.accent.withAlpha(25)),
              ),
              child: Center(child: Text(a.emoji, style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 14),
            // 정보
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.title, style: S.cardTitle),
              const SizedBox(height: 4),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: a.accent.withAlpha(15), borderRadius: BorderRadius.circular(4)),
                  child: Text(a.genre, style: S.badge.copyWith(color: a.accent)),
                ),
                const SizedBox(width: 8),
                Text(a.stat, style: S.caption.copyWith(color: C.grey)),
              ]),
            ])),
            // 플레이 버튼
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: a.accent.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.play_arrow_rounded, color: a.accent, size: 18),
            ),
          ]),
        ),
      )).toList(),
    );
  }

  void _go(BuildContext ctx, Widget s) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => s));
}

class _G {
  final String emoji, title, stat;
  final Color accent, bg;
  final Widget screen;
  const _G(this.emoji, this.title, this.stat, this.accent, this.bg, this.screen);
}

class _F {
  final String emoji, title, desc, genre;
  final String? badge;
  final Color accent, bg;
  final Widget screen;
  const _F(this.emoji, this.title, this.desc, this.genre, this.badge, this.accent, this.bg, this.screen);
}

class _A {
  final String emoji, title, genre, stat;
  final Color accent, bg;
  final Widget screen;
  const _A(this.emoji, this.title, this.genre, this.stat, this.accent, this.bg, this.screen);
}
