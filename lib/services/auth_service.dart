import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  User? get user => _auth.currentUser;
  bool get isLoggedIn => user != null;
  String get uid => user?.uid ?? '';

  Map<String, dynamic>? _profile;
  Map<String, dynamic>? get profile => _profile;

  AuthService() {
    _auth.authStateChanges().listen((u) {
      if (u != null) _loadProfile();
      notifyListeners();
    });
  }

  // ── 회원가입 (이메일, 인증 없음)
  Future<String?> signUp({
    required String email,
    required String password,
    required String nickname,
  }) async {
    try {
      // 닉네임 중복 체크
      final nickCheck = await _db.collection('users')
          .where('nickname', isEqualTo: nickname).limit(1).get();
      if (nickCheck.docs.isNotEmpty) return '이미 사용 중인 닉네임입니다';

      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _db.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'email': email,
        'nickname': nickname,
        'createdAt': FieldValue.serverTimestamp(),
        'profileEmoji': '⚡',
      });
      await _loadProfile();
      return null; // 성공
    } on FirebaseAuthException catch (e) {
      return switch (e.code) {
        'email-already-in-use' => '이미 가입된 이메일입니다',
        'weak-password' => '비밀번호가 너무 짧습니다 (6자 이상)',
        'invalid-email' => '이메일 형식이 올바르지 않습니다',
        _ => e.message ?? '회원가입 실패',
      };
    } catch (e) {
      return e.toString();
    }
  }

  // ── 로그인
  Future<String?> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _loadProfile();
      return null;
    } on FirebaseAuthException catch (e) {
      return switch (e.code) {
        'user-not-found' => '가입되지 않은 이메일입니다',
        'wrong-password' => '비밀번호가 틀렸습니다',
        'invalid-credential' => '이메일 또는 비밀번호가 틀렸습니다',
        _ => e.message ?? '로그인 실패',
      };
    } catch (e) {
      return e.toString();
    }
  }

  // ── 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
    _profile = null;
    notifyListeners();
  }

  // ── 프로필 로드
  Future<void> _loadProfile() async {
    if (user == null) return;
    final doc = await _db.collection('users').doc(uid).get();
    _profile = doc.data();
    notifyListeners();
  }

  String get nickname => _profile?['nickname'] ?? '게스트';
  String get profileEmoji => _profile?['profileEmoji'] ?? '⚡';
}
