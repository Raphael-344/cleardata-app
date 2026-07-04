import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kBg = Color(0xFF050A06);
const Color kSurface = Color(0xFF0A1A0C);
const Color kBorder = Color(0x3322C55E);
const Color kPrimary = Color(0xFF22C55E);
const Color kPrimaryDim = Color(0x2222C55E);
const Color kText = Color(0xFFE2E8F0);
const Color kTextMuted = Color(0xFF64748B);

const Map<String, Color> kGazColors = {
  'CO2': Color(0xFFF97316),
  'CH4': Color(0xFFA855F7),
  'N2O': Color(0xFF3B82F6),
  'O3': Color(0xFF06B6D4),
  'HFC': Color(0xFFEC4899),
  'SF6': Color(0xFFF59E0B),
  'NH3': Color(0xFF22C55E),
};

final ThemeData appTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: kBg,
  primaryColor: kPrimary,
  colorScheme: const ColorScheme.dark(
    primary: kPrimary,
    surface: kSurface,
    background: kBg,
  ),
  textTheme: GoogleFonts.spaceGroteskTextTheme(
    const TextTheme(
      displayLarge: TextStyle(color: kText),
      bodyMedium: TextStyle(color: kText),
    ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xEE050A06),
    elevation: 0,
    centerTitle: false,
    titleTextStyle: GoogleFonts.syne(
      color: kText,
      fontSize: 18,
      fontWeight: FontWeight.w700,
    ),
    iconTheme: const IconThemeData(color: kPrimary),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xF0050A06),
    selectedItemColor: kPrimary,
    unselectedItemColor: Color(0xFF475569),
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
);
