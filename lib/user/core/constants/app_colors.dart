import 'package:flutter/material.dart';

class AppColors {
  // ── Brand Core ────────────────────────────────────────────────────────
  static const primary = Color(0xFFC82B13); 
  static const primaryDark = Color(0xFFA61F0D);
  static const primaryLight = Color(0xFFE14A2F);
  static const primarySoft = Color(0xFFF9EAE8); // Light red for tags/labels

  // ── Secondary / Deep Teal ────────────────────────────────────────────
  static const secondary = Color(0xFF0A5959);
  static const secondaryDark = Color(0xFF084848);
  static const secondaryLight = Color(0xFF2D8B70);

  // ── Tertiary / Soft Emerald ──────────────────────────────────────────
  static const tertiary = Color(0xFF2D8B70);
  static const tertiaryLight = Color(0xFF9ED9CC);

  // ── Neutral / Clean Background ───────────────────────────────────────
  static const background = Color(0xFFFFFFFF); // Putih bersih untuk kesan modern
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSoft = Color(0xFFF8F8F8); // Background kartu yang sangat lembut
  static const surfaceGrey = Color(0xFFF2F2F2); // Untuk input fields

  // ── Text (Modern Slate) ──────────────────────────────────────────────
  static const textPrimary = Color(0xFF1A1A1A);   // Hitam empuk (tidak menusuk mata)
  static const textSecondary = Color(0xFF717171); // Abu-abu modern
  static const textHint = Color(0xFFB0B0B0);

  // ── Semantic ─────────────────────────────────────────────────────────
  static const success = Color(0xFF2D8B70);
  static const error = Color(0xFFC82B13);
  static const warning = Color(0xFFE7A64A);
  static const info = Color(0xFF4F7C82);

  // ── Membership Tiers ─────────────────────────────────────────────────
  static const bronze = Color(0xFFC18A52);
  static const silver = Color(0xFFAAA8B1);
  static const gold = Color(0xFFE7B75F);
  static const platinum = Color(0xFF7BB8D9);

  // ── Lines / Borders / Shadows ───────────────────────────────────────
  static const divider = Color(0xFFF1F1F1);
  static const cardBorder = Color(0xFFF0F0F0);
  static const shadow = Color(0x0A000000); // Ultra soft shadow

  // ── Core Gradients (Senada/Monochromatic) ────────────────────────────
  static const gradientHeader = LinearGradient(
    colors: [Color(0xFFA61F0D), Color(0xFFC82B13)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientPrimarySoft = LinearGradient(
    colors: [Color(0xFFC82B13), Color(0xFFE14A2F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientLuxury = LinearGradient(
    colors: [Color(0xFF0A5959), Color(0xFF2D8B70)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientWarmSurface = LinearGradient(
    colors: [Color(0xFFFFFDF9), Color(0xFFF8F3EE)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const gradientLoyalty = LinearGradient(
    colors: [Color(0xFFC82B13), Color(0xFF0A5959)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientQueue = LinearGradient(
    colors: [Color(0xFFA61F0D), Color(0xFF0A5959)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Tier Helpers ─────────────────────────────────────────────────────
  static LinearGradient tierGradient(String tier) {
    switch (tier.toLowerCase()) {
      case 'platinum':
        return const LinearGradient(colors: [Color(0xFF7BB8D9), Color(0xFFCFE7FA)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case 'gold':
        return const LinearGradient(colors: [Color(0xFFE7B75F), Color(0xFFFFE0A3)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case 'silver':
        return const LinearGradient(colors: [Color(0xFF8F9199), Color(0xFFD8DADF)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      default:
        return const LinearGradient(colors: [Color(0xFF9A6133), Color(0xFFC18A52)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    }
  }

  static Color tierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'platinum': return platinum;
      case 'gold': return gold;
      case 'silver': return silver;
      default: return bronze;
    }
  }

  // ── Backward Compatibility Aliases ───────────────────────────────────
  static const teal = secondary;
  static const tealMedium = secondary;
  static const tealLight = tertiaryLight;
  static const dark = textPrimary;
  static const darkCard = secondaryDark;
}