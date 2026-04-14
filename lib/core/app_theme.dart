import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFF0B0B0F);
  static const surface = Color(0xFF151519);
  static const elevated = Color(0xFF1C1C22);
  static const card = Color(0xFF13131A);

  static const gold = Color(0xFFD4AF37);
  static const goldLight = Color(0xFFE8D48B);
  static const goldDark = Color(0xFF8B7420);
  static const goldSoft = Color(0x18D4AF37);

  static const white = Color(0xFFFFFFFF);
  static const white80 = Color(0xCCFFFFFF);
  static const white50 = Color(0x80FFFFFF);
  static const secondary = Color(0xFF8A8A9A);
  static const muted = Color(0xFF55556A);

  static const border = Color(0xFF22222E);
  static const borderLight = Color(0xFF2E2E3A);

  static const positive = Color(0xFF4ADE80);
  static const negative = Color(0xFFEF4444);

  // Game accent pairs [dark, light]
  static const noahGreen = Color(0xFF0D3320);
  static const noahGreenAccent = Color(0xFF34D399);
  static const omokEmerald = Color(0xFF0D3328);
  static const omokEmeraldAccent = Color(0xFF6EE7B7);
  static const rhythmViolet = Color(0xFF1E0A3C);
  static const rhythmVioletAccent = Color(0xFFA78BFA);
  static const clickerAmber = Color(0xFF2D1B06);
  static const clickerAmberAccent = Color(0xFFFBBF24);
  static const gachaIndigo = Color(0xFF0F0D33);
  static const gachaIndigoAccent = Color(0xFF818CF8);

  static const lane1 = Color(0xFF7B3FE4);
  static const lane2 = Color(0xFF3F8FE4);
  static const lane3 = Color(0xFFE4943F);
  static const lane4 = Color(0xFFE43F6F);
}

class AppTextStyles {
  static TextStyle get displayLarge => GoogleFonts.spaceGrotesk(
    fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1.2, height: 1.1, color: AppColors.white,
  );
  static TextStyle get displayMedium => GoogleFonts.spaceGrotesk(
    fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5, height: 1.15, color: AppColors.white,
  );
  static TextStyle get headline => GoogleFonts.spaceGrotesk(
    fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.white,
  );
  static TextStyle get title => GoogleFonts.spaceGrotesk(
    fontSize: 17, fontWeight: FontWeight.w700, height: 1.2, color: AppColors.white,
  );
  static TextStyle get cardTitle => GoogleFonts.spaceGrotesk(
    fontSize: 15, fontWeight: FontWeight.w700, height: 1.3, color: AppColors.white,
  );
  static TextStyle get body => GoogleFonts.spaceGrotesk(
    fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.white,
  );
  static TextStyle get bodySmall => GoogleFonts.spaceGrotesk(
    fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.secondary,
  );
  static TextStyle get label => GoogleFonts.spaceGrotesk(
    fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: AppColors.gold,
  );
  static TextStyle get caption => GoogleFonts.spaceGrotesk(
    fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 0.8, color: AppColors.muted,
  );
  static TextStyle get tabLabel => GoogleFonts.spaceGrotesk(
    fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.6,
  );
}

ThemeData buildAppTheme() {
  return ThemeData(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(primary: AppColors.gold, surface: AppColors.surface),
    textTheme: GoogleFonts.spaceGroteskTextTheme().apply(bodyColor: AppColors.white, displayColor: AppColors.white),
    appBarTheme: const AppBarTheme(backgroundColor: AppColors.bg, elevation: 0, foregroundColor: AppColors.white),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
