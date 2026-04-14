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
            SliverToBoxAdapter(child: _sectionTitle('ALL GAMES')),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.82,
                ),
                delegate: SliverChildListDelegate(_gameCards(context)),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('MINI GAMES', style: AppTextStyles.label),
            const SizedBox(height: 4),
            Text('게임 허브', style: AppTextStyles.displayLarge),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gold.withAlpha(25), AppColors.gold.withAlpha(8)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.gold.withAlpha(40)),
            ),
            child: Row(children: [
              Container(
                width: 20, height: 20,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.gold]),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.star_rounded, color: Color(0xFF1A1400), size: 14),
              ),
              const SizedBox(width: 8),
              Text('2,480', style: AppTextStyles.body.copyWith(color: AppColors.gold, fontWeight: FontWeight.w800)),
              const SizedBox(width: 2),
              Text('PT', style: AppTextStyles.caption.copyWith(color: AppColors.gold.withAlpha(150))),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _featured(BuildContext context) {
    return GestureDetector(
      onTap: () => _go(context, const NoahTetrisScreen()),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF1A4D2E), Color(0xFF0D3320), Color(0xFF0A2818)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: const Color(0xFF34D399).withAlpha(20), blurRadius: 30, offset: const Offset(0, 8)),
          ],
        ),
        child: Stack(children: [
          // Subtle radial glow
          Positioned(right: -20, top: -20, child: Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                const Color(0xFF34D399).withAlpha(20), Colors.transparent,
              ]),
            ),
          )),
          // Emoji icon large
          Positioned(right: 20, top: 20, child: Text('🚢', style: TextStyle(fontSize: 72,
            shadows: [Shadow(color: Colors.black.withAlpha(60), blurRadius: 20, offset: const Offset(0, 8))],
          ))),
          // Content
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.noahGreenAccent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('NEW', style: AppTextStyles.caption.copyWith(color: const Color(0xFF052E16), fontWeight: FontWeight.w800, letterSpacing: 1.5)),
              ),
              const SizedBox(height: 10),
              Text('노아의 방주 테트리스', style: AppTextStyles.headline.copyWith(height: 1.2)),
              const SizedBox(height: 4),
              Text('동물 블록을 방주에 채워라!', style: AppTextStyles.bodySmall.copyWith(color: AppColors.white50)),
            ]),
          ),
        ]),
      ),
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

  List<Widget> _gameCards(BuildContext context) {
    final games = [
      _G('🚢', '노아의 방주\n테트리스', '퍼즐', const Color(0xFF0D3320), AppColors.noahGreenAccent, const NoahTetrisScreen(), 'NEW'),
      _G('♟️', '예수님과\n오목', '전략 보드', const Color(0xFF0D3328), AppColors.omokEmeraldAccent, const OmokScreen(), null),
      _G('🎵', '말씀 암송\n리듬게임', '리듬 액션', const Color(0xFF1E0A3C), AppColors.rhythmVioletAccent, const RhythmScreen(), null),
      _G('⛪', '믿음의 왕국\n키우기', '방치형 클리커', const Color(0xFF2D1B06), AppColors.clickerAmberAccent, const ClickerScreen(), null),
      _G('🃏', '성경 인물\n카드 수집', '카드 가챠', const Color(0xFF0F0D33), AppColors.gachaIndigoAccent, const GachaScreen(), 'HOT'),
    ];
    return games.map((g) => _GameCard(g: g, onTap: () => _go(context, g.screen))).toList();
  }

  void _go(BuildContext context, Widget s) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => s));
}

class _G {
  final String emoji, title, genre;
  final Color bg, accent;
  final Widget screen;
  final String? badge;
  const _G(this.emoji, this.title, this.genre, this.bg, this.accent, this.screen, this.badge);
}

class _GameCard extends StatelessWidget {
  final _G g;
  final VoidCallback onTap;
  const _GameCard({required this.g, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [g.bg, Color.lerp(g.bg, Colors.black, 0.3)!],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          border: Border.all(color: g.accent.withAlpha(18)),
          boxShadow: [BoxShadow(color: g.bg.withAlpha(80), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Stack(children: [
          // Accent glow top-right
          Positioned(right: -15, top: -15, child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [g.accent.withAlpha(30), Colors.transparent]),
            ),
          )),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                // Emoji with glass bg
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: g.accent.withAlpha(18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: g.accent.withAlpha(25)),
                  ),
                  child: Center(child: Text(g.emoji, style: const TextStyle(fontSize: 26))),
                ),
                if (g.badge != null) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: g.badge == 'HOT' ? AppColors.negative.withAlpha(30) : g.accent.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: g.badge == 'HOT' ? AppColors.negative.withAlpha(60) : g.accent.withAlpha(40)),
                  ),
                  child: Text(g.badge!, style: AppTextStyles.caption.copyWith(
                    color: g.badge == 'HOT' ? AppColors.negative : g.accent, fontWeight: FontWeight.w800, letterSpacing: 1,
                  )),
                ),
              ]),
              const Spacer(),
              // Genre tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: g.accent.withAlpha(12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(g.genre.toUpperCase(), style: AppTextStyles.caption.copyWith(color: g.accent, letterSpacing: 1)),
              ),
              const SizedBox(height: 8),
              Text(g.title, style: AppTextStyles.cardTitle.copyWith(height: 1.3)),
            ]),
          ),
        ]),
      ),
    );
  }
}
