import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_theme.dart';
import 'reels/reels_screen.dart';
import 'test/test_hub_screen.dart';
import 'games/game_hub_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _idx = 2;
  final _screens = const [ReelsScreen(), TestHubScreen(), GameHubScreen()];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            _screens[_idx],
            Positioned(left: 0, right: 0, bottom: 0, child: _tabBar()),
          ],
        ),
      ),
    );
  }

  Widget _tabBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [AppColors.bg.withAlpha(0), AppColors.bg.withAlpha(200), AppColors.bg],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 64,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surface.withAlpha(220),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.white.withAlpha(8)),
            ),
            child: Row(children: [
              _tab(Icons.play_circle_filled_rounded, 'REELS', 0),
              _tab(Icons.psychology_rounded, 'TEST', 1),
              _tab(Icons.sports_esports_rounded, 'GAMES', 2),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _tab(IconData icon, String label, int i) {
    final active = _idx == i;
    return Expanded(
      child: GestureDetector(
        onTap: () { HapticFeedback.selectionClick(); setState(() => _idx = i); },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: active ? const LinearGradient(
              colors: [Color(0xFFE8D48B), AppColors.gold],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ) : null,
            borderRadius: BorderRadius.circular(28),
            boxShadow: active ? [
              BoxShadow(color: AppColors.gold.withAlpha(50), blurRadius: 16, spreadRadius: -2),
            ] : null,
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: active ? const Color(0xFF1A1400) : AppColors.muted, size: 20),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.tabLabel.copyWith(
              color: active ? const Color(0xFF1A1400) : AppColors.muted,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            )),
          ]),
        ),
      ),
    );
  }
}
