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
        body: Stack(children: [
          _screens[_idx],
          Positioned(left: 0, right: 0, bottom: 0, child: _tabBar()),
        ]),
      ),
    );
  }

  Widget _tabBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [C.bg.withAlpha(0), C.bg.withAlpha(230), C.bg],
          stops: const [0.0, 0.35, 1.0],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 60,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: C.surface.withAlpha(200),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: C.border),
            ),
            child: Row(children: [
              _tab(Icons.play_circle_rounded, 'REELS', 0),
              _tab(Icons.psychology_rounded, 'TEST', 1),
              _tab(Icons.sports_esports_rounded, 'GAMES', 2),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _tab(IconData icon, String label, int i) {
    final on = _idx == i;
    return Expanded(
      child: GestureDetector(
        onTap: () { HapticFeedback.selectionClick(); setState(() => _idx = i); },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: double.infinity,
          decoration: BoxDecoration(
            color: on ? C.lime : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: on ? [BoxShadow(color: C.lime.withAlpha(40), blurRadius: 16)] : null,
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: on ? C.bg : C.greyDark, size: 20),
            const SizedBox(height: 2),
            Text(label, style: S.tabLabel.copyWith(color: on ? C.bg : C.greyDark)),
          ]),
        ),
      ),
    );
  }
}
