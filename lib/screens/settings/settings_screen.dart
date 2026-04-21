import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../services/auth_service.dart';
import '../auth/auth_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 140),
          children: [
            _header(),
            const SizedBox(height: 20),
            // 프로필 카드
            auth.isLoggedIn ? _profileCard(context, auth) : _loginPrompt(context),
            const SizedBox(height: 24),
            _section('앱 설정'),
            _tile(Icons.notifications_none_rounded, '알림 설정', () {}),
            _tile(Icons.palette_outlined, '테마', subtitle: '다크 모드', () {}),
            _tile(Icons.language_rounded, '언어', subtitle: '한국어', () {}),
            const SizedBox(height: 16),
            _section('정보'),
            _tile(Icons.info_outline_rounded, '앱 버전', subtitle: '1.0.0', () {}),
            _tile(Icons.description_outlined, '이용약관', () {}),
            _tile(Icons.shield_outlined, '개인정보 처리방침', () {}),
            _tile(Icons.mail_outline_rounded, '문의하기', () {}),
            if (auth.isLoggedIn) ...[
              const SizedBox(height: 24),
              _section('계정'),
              _tile(Icons.logout_rounded, '로그아웃', textColor: C.red, () => _logout(context, auth)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('SETTINGS', style: S.label.copyWith(fontSize: 10)),
        const SizedBox(height: 2),
        Text('설정', style: S.displayMedium),
      ]),
    );
  }

  Widget _profileCard(BuildContext context, AuthService auth) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [C.lime.withAlpha(15), C.surface]),
        border: Border.all(color: C.lime.withAlpha(20)),
      ),
      child: Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: C.limeSoft,
            border: Border.all(color: C.lime.withAlpha(40), width: 2),
          ),
          child: Center(child: Text(auth.profileEmoji, style: const TextStyle(fontSize: 28))),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(auth.nickname, style: S.headline),
          const SizedBox(height: 2),
          Text(auth.user?.email ?? '', style: S.bodySmall.copyWith(color: C.greyDark)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: C.elevated, borderRadius: BorderRadius.circular(8)),
          child: Text('편집', style: S.caption.copyWith(color: C.grey)),
        ),
      ]),
    );
  }

  Widget _loginPrompt(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen())),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: C.surface,
          border: Border.all(color: C.border),
        ),
        child: Row(children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: C.elevated,
              border: Border.all(color: C.border),
            ),
            child: const Icon(Icons.person_outline_rounded, color: C.greyDark, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('로그인하기', style: S.headline),
            const SizedBox(height: 2),
            Text('게임 기록, 테스트 결과, 커뮤니티를 이용하세요', style: S.bodySmall.copyWith(color: C.greyDark)),
          ])),
          Icon(Icons.arrow_forward_ios_rounded, color: C.lime, size: 16),
        ]),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Row(children: [
        Container(width: 3, height: 14, decoration: BoxDecoration(color: C.lime, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: S.title.copyWith(fontSize: 15)),
      ]),
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap, {String? subtitle, Color? textColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Icon(icon, color: textColor ?? C.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: S.body.copyWith(color: textColor ?? C.white))),
          if (subtitle != null)
            Text(subtitle, style: S.caption.copyWith(color: C.greyDark)),
          const SizedBox(width: 4),
          Icon(Icons.arrow_forward_ios_rounded, color: C.greyDark, size: 12),
        ]),
      ),
    );
  }

  void _logout(BuildContext context, AuthService auth) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: C.surface,
      title: Text('로그아웃', style: S.title),
      content: Text('정말 로그아웃하시겠습니까?', style: S.bodySmall),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('취소', style: S.body.copyWith(color: C.grey))),
        TextButton(onPressed: () { Navigator.pop(context); auth.signOut(); }, child: Text('로그아웃', style: S.body.copyWith(color: C.red))),
      ],
    ));
  }
}
