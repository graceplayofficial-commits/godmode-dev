import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/app_theme.dart';
import 'services/auth_service.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
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
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'GODMode',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const MainScreen(),
      ),
    );
  }
}
