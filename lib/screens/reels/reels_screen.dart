import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});
  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> with SingleTickerProviderStateMixin {
  int _selectedCat = 0;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          _header(),
          _categories(),
          Expanded(child: _emptyState()),
        ]),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(children: [
        RichText(text: TextSpan(children: [
          TextSpan(text: 'GOD', style: AppTextStyles.headline.copyWith(color: AppColors.gold, fontWeight: FontWeight.w800)),
          TextSpan(text: 'Mode', style: AppTextStyles.headline.copyWith(fontWeight: FontWeight.w400)),
        ])),
        const Spacer(),
        _headerIcon(Icons.search_rounded),
        const SizedBox(width: 12),
        _headerIcon(Icons.notifications_none_rounded),
      ]),
    );
  }

  Widget _headerIcon(IconData icon) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(icon, color: AppColors.secondary, size: 20),
    );
  }

  Widget _categories() {
    final cats = ['전체', '찬양', '말씀', '간증', '기도'];
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: cats.length,
        itemBuilder: (_, i) {
          final active = i == _selectedCat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCat = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                gradient: active ? const LinearGradient(colors: [AppColors.goldLight, AppColors.gold]) : null,
                color: active ? null : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: active ? null : Border.all(color: AppColors.border),
              ),
              child: Text(cats[i], style: AppTextStyles.body.copyWith(
                color: active ? const Color(0xFF1A1400) : AppColors.secondary,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              )),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Animated pulsing icon
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, child) => Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.gold.withAlpha((15 + 15 * _pulseCtrl.value).round()), Colors.transparent],
                  radius: 1.2 + 0.3 * _pulseCtrl.value,
                ),
              ),
              child: child,
            ),
            child: Container(
              width: 72, height: 72,
              margin: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.gold.withAlpha(20), AppColors.gold.withAlpha(8)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                border: Border.all(color: AppColors.gold.withAlpha(30)),
              ),
              child: const Icon(Icons.play_arrow_rounded, color: AppColors.gold, size: 32),
            ),
          ),
          const SizedBox(height: 24),
          Text('기독교 릴스', style: AppTextStyles.title),
          const SizedBox(height: 8),
          Text('YouTube 기반 기독교 쇼츠가\n곧 준비됩니다',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted, height: 1.5),
              textAlign: TextAlign.center),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gold.withAlpha(18), AppColors.gold.withAlpha(8)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withAlpha(35)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withAlpha(150),
                  boxShadow: [BoxShadow(color: AppColors.gold.withAlpha(80), blurRadius: 6)],
                ),
              ),
              const SizedBox(width: 10),
              Text('COMING SOON', style: AppTextStyles.label.copyWith(fontSize: 12)),
            ]),
          ),
        ]),
      ),
    );
  }
}
