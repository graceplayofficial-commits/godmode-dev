import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  final String? reason;
  const AuthScreen({super.key, this.reason});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _loading = false;
  String? _error;
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _nickCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _nickCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthService>();
    setState(() { _loading = true; _error = null; });

    String? err;
    if (_isLogin) {
      err = await auth.signIn(email: _emailCtrl.text.trim(), password: _pwCtrl.text);
    } else {
      if (_nickCtrl.text.trim().length < 2) {
        setState(() { _error = '닉네임은 2자 이상이어야 합니다'; _loading = false; });
        return;
      }
      err = await auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _pwCtrl.text,
        nickname: _nickCtrl.text.trim(),
      );
    }

    if (!mounted) return;
    if (err != null) {
      setState(() { _error = err; _loading = false; });
    } else {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          children: [
            // 닫기
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.border)),
                  child: const Icon(Icons.close_rounded, size: 18, color: C.grey),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // 로고
            Text('⚡', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            RichText(text: TextSpan(children: [
              TextSpan(text: 'GOD', style: S.displayLarge.copyWith(color: C.lime)),
              TextSpan(text: 'Mode', style: S.displayLarge),
            ])),
            const SizedBox(height: 8),
            if (widget.reason != null)
              Text(widget.reason!, style: S.bodySmall.copyWith(color: C.grey))
            else
              Text(_isLogin ? '다시 돌아오셨네요!' : '갓모드를 켜보세요', style: S.bodySmall.copyWith(color: C.grey)),
            const SizedBox(height: 32),

            // 닉네임 (회원가입만)
            if (!_isLogin) ...[
              _label('닉네임'),
              _input(_nickCtrl, '닉네임을 입력하세요', icon: Icons.person_outline_rounded),
              const SizedBox(height: 16),
            ],
            // 이메일
            _label('이메일'),
            _input(_emailCtrl, 'email@example.com', icon: Icons.email_outlined, keyboard: TextInputType.emailAddress),
            const SizedBox(height: 16),
            // 비밀번호
            _label('비밀번호'),
            _input(_pwCtrl, '6자 이상', icon: Icons.lock_outline_rounded, obscure: true),

            // 에러
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: C.red.withAlpha(15), borderRadius: BorderRadius.circular(10), border: Border.all(color: C.red.withAlpha(30))),
                child: Row(children: [
                  Icon(Icons.error_outline_rounded, color: C.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: S.bodySmall.copyWith(color: C.red))),
                ]),
              ),
            ],

            const SizedBox(height: 24),
            // 제출 버튼
            GestureDetector(
              onTap: _loading ? null : _submit,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _loading ? C.greyDark : C.lime,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: _loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: C.bg))
                  : Text(_isLogin ? '로그인' : '회원가입', style: S.cardTitle.copyWith(color: C.bg)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 전환
            GestureDetector(
              onTap: () => setState(() { _isLogin = !_isLogin; _error = null; }),
              child: Center(child: RichText(text: TextSpan(children: [
                TextSpan(text: _isLogin ? '계정이 없으신가요? ' : '이미 계정이 있으신가요? ',
                    style: S.bodySmall.copyWith(color: C.grey)),
                TextSpan(text: _isLogin ? '회원가입' : '로그인',
                    style: S.body.copyWith(color: C.lime)),
              ]))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: S.caption.copyWith(color: C.grey, letterSpacing: 1)),
    );
  }

  Widget _input(TextEditingController ctrl, String hint, {
    IconData? icon, bool obscure = false, TextInputType? keyboard,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.border),
      ),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboard,
        style: S.body,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: S.body.copyWith(color: C.greyDark),
          prefixIcon: icon != null ? Icon(icon, color: C.greyDark, size: 18) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
