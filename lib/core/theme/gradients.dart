import 'package:flutter/material.dart';
import 'colors.dart';

class TGradients {
  TGradients._();

  static const gradTeal = LinearGradient(
    colors: [TColors.teal700, TColors.teal500, TColors.blue500],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradBlue = LinearGradient(
    colors: [TColors.blue700, TColors.blue500, TColors.teal300],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradGreen = LinearGradient(
    colors: [TColors.teal500, TColors.green500, TColors.green300],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradPink = LinearGradient(
    colors: [TColors.pink700, TColors.pink500, TColors.pink300],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradSoft = LinearGradient(
    colors: [Color(0xFFF8F8FF), Color(0xFFE0F7F7), Color(0xFFE3F2FD)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const gradEmergency = LinearGradient(
    colors: [Color(0xFFC0392B), Color(0xFFE74C3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradGold = LinearGradient(
    colors: [Color(0xFFF9A825), Color(0xFFFFD54F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
