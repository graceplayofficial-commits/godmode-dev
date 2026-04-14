import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ══════════════════════════════════════════
// GOD MODE — Neon Gaming Design System
// BG: #121212  Surface: #1A1A1A  Accent: #AAFF00
// ══════════════════════════════════════════

class C {
  // Backgrounds
  static const bg = Color(0xFF121212);
  static const surface = Color(0xFF1A1A1A);
  static const card = Color(0xFF1E1E1E);
  static const elevated = Color(0xFF252525);
  static const dimBg = Color(0xFF161616);

  // Neon Accent
  static const lime = Color(0xFFAAFF00);
  static const limeDim = Color(0xFF88CC00);
  static const limeSoft = Color(0x20AAFF00);
  static const limeMuted = Color(0x40AAFF00);

  // Text
  static const white = Color(0xFFFFFFFF);
  static const white90 = Color(0xE6FFFFFF);
  static const white70 = Color(0xB3FFFFFF);
  static const white40 = Color(0x66FFFFFF);
  static const grey = Color(0xFF888888);
  static const greyDark = Color(0xFF555555);

  // Border
  static const border = Color(0xFF2A2A2A);
  static const borderLight = Color(0xFF333333);

  // Status
  static const red = Color(0xFFFF4757);
  static const redSoft = Color(0x30FF4757);
  static const blue = Color(0xFF3B82F6);
  static const amber = Color(0xFFFBBF24);

  // Game accent colors
  static const noahTeal = Color(0xFF0D9488);
  static const noahTealBg = Color(0xFF0A2D2A);
  static const omokEmerald = Color(0xFF10B981);
  static const omokEmeraldBg = Color(0xFF0A2E1F);
  static const rhythmViolet = Color(0xFF8B5CF6);
  static const rhythmVioletBg = Color(0xFF1A0F33);
  static const clickerAmber = Color(0xFFF59E0B);
  static const clickerAmberBg = Color(0xFF2D1F06);
  static const gachaBlue = Color(0xFF6366F1);
  static const gachaBlueBg = Color(0xFF111133);

  static const lane1 = Color(0xFF8B5CF6);
  static const lane2 = Color(0xFF3B82F6);
  static const lane3 = Color(0xFFF59E0B);
  static const lane4 = Color(0xFFEF4444);
}

class S {
  // Typography
  static TextStyle get displayLarge => GoogleFonts.spaceGrotesk(
    fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1, height: 1.05, color: C.white,
  );
  static TextStyle get displayMedium => GoogleFonts.spaceGrotesk(
    fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5, height: 1.1, color: C.white,
  );
  static TextStyle get headline => GoogleFonts.spaceGrotesk(
    fontSize: 20, fontWeight: FontWeight.w700, height: 1.15, color: C.white,
  );
  static TextStyle get title => GoogleFonts.spaceGrotesk(
    fontSize: 17, fontWeight: FontWeight.w700, height: 1.2, color: C.white,
  );
  static TextStyle get cardTitle => GoogleFonts.spaceGrotesk(
    fontSize: 15, fontWeight: FontWeight.w700, height: 1.3, color: C.white,
  );
  static TextStyle get body => GoogleFonts.spaceGrotesk(
    fontSize: 13, fontWeight: FontWeight.w500, color: C.white,
  );
  static TextStyle get bodySmall => GoogleFonts.spaceGrotesk(
    fontSize: 12, fontWeight: FontWeight.w400, height: 1.4, color: C.grey,
  );
  static TextStyle get label => GoogleFonts.spaceGrotesk(
    fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2.0, color: C.lime,
  );
  static TextStyle get caption => GoogleFonts.spaceGrotesk(
    fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: C.greyDark,
  );
  static TextStyle get tabLabel => GoogleFonts.spaceGrotesk(
    fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8,
  );
  static TextStyle get badge => GoogleFonts.spaceGrotesk(
    fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5,
  );
}

ThemeData buildAppTheme() {
  return ThemeData(
    scaffoldBackgroundColor: C.bg,
    colorScheme: const ColorScheme.dark(primary: C.lime, surface: C.surface),
    textTheme: GoogleFonts.spaceGroteskTextTheme().apply(bodyColor: C.white, displayColor: C.white),
    appBarTheme: const AppBarTheme(backgroundColor: C.bg, elevation: 0, foregroundColor: C.white),
    dialogTheme: DialogThemeData(
      backgroundColor: C.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
