import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const display = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
    height: 1.2,
  );

  static const heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.3,
  );

  static const heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.4,
    height: 1.3,
  );

  static const heading3 = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.6, // Legible spacing
  );

  static const bodyMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const bodySecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const captionBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const label = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    letterSpacing: 1.0,
    height: 1.2,
  );

  static const price = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    letterSpacing: -0.2,
  );

  static const priceLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: AppColors.primary,
    letterSpacing: -0.4,
  );

  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: 0.5,
    height: 1.1,
  );
}