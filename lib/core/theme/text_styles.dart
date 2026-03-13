import 'package:flutter/material.dart';
import 'colors.dart';

class TTextStyles {
  TTextStyles._();

  static const displayLarge = TextStyle(
    fontSize: 36, fontWeight: FontWeight.w700,
    color: TColors.dark, letterSpacing: -0.5,
  );

  static const displayMedium = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w700,
    color: TColors.dark,
  );

  static const headlineLarge = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w700,
    color: TColors.dark,
  );

  static const headlineMedium = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600,
    color: TColors.dark,
  );

  static const headlineSmall = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600,
    color: TColors.dark,
  );

  static const bodyLarge = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w400,
    color: TColors.mid,
  );

  static const bodyMedium = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w400,
    color: TColors.mid,
  );

  static const bodySmall = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w400,
    color: TColors.gray,
  );

  static const labelLarge = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600,
    color: TColors.dark, letterSpacing: 0.3,
  );

  static const labelMedium = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w600,
    color: TColors.gray, letterSpacing: 0.5,
  );

  static const white = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w500,
    color: TColors.white,
  );

  static const whiteBold = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w700,
    color: TColors.white,
  );
}
