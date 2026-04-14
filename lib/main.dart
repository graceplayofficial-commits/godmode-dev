import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/app_theme.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase: Android/iOS만 설정됨 — 그 외 플랫폼은 skip
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('Firebase init skipped on this platform: $e');
  }
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const GodModeApp());
}

class GodModeApp extends StatelessWidget {
  const GodModeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GODMode',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const MainScreen(),
    );
  }
}
