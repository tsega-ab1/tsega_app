import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../core/theme/gradients.dart';

// ─── XP + LEVEL ──────────────────────────────────────────────────
class TsegaLevel {
  final int level;
  final String nameEn;
  final String nameAm;
  final int xpRequired;
  final int xpMax;
  final LinearGradient gradient;
  final IconData icon;
  final List<String> unlocksEn;
  final List<String> unlocksAm;

  const TsegaLevel({
    required this.level, required this.nameEn, required this.nameAm,
    required this.xpRequired, required this.xpMax,
    required this.gradient, required this.icon,
    required this.unlocksEn, required this.unlocksAm,
  });

  static const levels = [
    TsegaLevel(
      level: 1, nameEn: 'Seed', nameAm: 'ዘር',
      xpRequired: 0, xpMax: 200,
      gradient: LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF81C784)]),
      icon: Icons.eco_rounded,
      unlocksEn: ['Basic health tips', 'Daily logging'],
      unlocksAm: ['መሠረታዊ ጤና ምክሮች', 'ዕለታዊ ምዝገባ'],
    ),
    TsegaLevel(
      level: 2, nameEn: 'Bloom', nameAm: 'አበባ',
      xpRequired: 201, xpMax: 500,
      gradient: LinearGradient(colors: [Color(0xFFE91E63), Color(0xFFF06292)]),
      icon: Icons.local_florist_rounded,
      unlocksEn: ['Health summary PDF', 'Cycle predictions'],
      unlocksAm: ['የጤና ማጠቃለያ PDF', 'ዑደት ትንበያ'],
    ),
    TsegaLevel(
      level: 3, nameEn: 'Health Scholar', nameAm: 'የጤና ምሁር',
      xpRequired: 501, xpMax: 1000,
      gradient: LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF42A5F5)]),
      icon: Icons.school_rounded,
      unlocksEn: ['Offline course packs', 'Advanced AI chat'],
      unlocksAm: ['ከመስመር ውጭ ኮርሶች', 'የላቀ AI ውይይት'],
    ),
    TsegaLevel(
      level: 4, nameEn: 'Wellness Guide', nameAm: 'የጤናማነት መሪ',
      xpRequired: 1001, xpMax: 2000,
      gradient: LinearGradient(colors: [Color(0xFF009999), Color(0xFF4DC4C4)]),
      icon: Icons.self_improvement_rounded,
      unlocksEn: ['Partner education pack', 'Premium certificates'],
      unlocksAm: ['የሸሪካ ትምህርት', 'ፕሪሚየም የምስክር ወረቀቶች'],
    ),
    TsegaLevel(
      level: 5, nameEn: 'Tsega Champion', nameAm: 'የጸጋ ሻምፒዮን',
      xpRequired: 2001, xpMax: 999999,
      gradient: LinearGradient(colors: [Color(0xFFFF6B00), Color(0xFFFFD700)]),
      icon: Icons.emoji_events_rounded,
      unlocksEn: ['All features unlocked', 'Physical partner rewards'],
      unlocksAm: ['ሁሉም ባህሪዎች', 'አካላዊ ሽልማቶች'],
    ),
  ];

  static TsegaLevel fromXp(int xp) {
    for (var i = levels.length - 1; i >= 0; i--) {
      if (xp >= levels[i].xpRequired) return levels[i];
    }
    return levels[0];
  }

  double progressWithin(int xp) {
    if (level == 5) return 1.0;
    final progress = (xp - xpRequired) / (xpMax - xpRequired);
    return progress.clamp(0.0, 1.0);
  }
}

// ─── REWARD ──────────────────────────────────────────────────────
enum RewardType { inApp, digital, physical }

class TsegaReward {
  final String id;
  final String titleEn, titleAm;
  final String descEn, descAm;
  final int cost; // in Tsega Coins (100 XP = 1 TC)
  final RewardType type;
  final IconData icon;
  final Color color;
  final int minLevel;
  final bool available;

  const TsegaReward({
    required this.id, required this.titleEn, required this.titleAm,
    required this.descEn, required this.descAm, required this.cost,
    required this.type, required this.icon, required this.color,
    this.minLevel = 1, this.available = true,
  });

  static const rewards = [
    // ── IN-APP REWARDS ────────────────────────────────────────────
    TsegaReward(
      id: 'unlock_module', titleEn: 'Unlock Module',
      titleAm: 'ክፍል ክፈት',
      descEn: 'Unlock any locked education module immediately',
      descAm: 'ማንኛውንም ቁልፍ ያለበት ክፍል ወዲያውኑ ይክፈቱ',
      cost: 50, type: RewardType.inApp,
      icon: Icons.lock_open_rounded, color: Color(0xFF009999),
    ),
    TsegaReward(
      id: 'health_pdf', titleEn: 'Health Summary PDF',
      titleAm: 'የጤና ማጠቃለያ PDF',
      descEn: 'Generate a printable health report to share with your doctor',
      descAm: 'ለሐኪምዎ ለማጋራት ሊታተም የሚችል የጤና ሪፖርት ያዘጋጁ',
      cost: 100, type: RewardType.inApp,
      icon: Icons.picture_as_pdf_rounded, color: Color(0xFFE91E63),
    ),
    TsegaReward(
      id: 'pregnancy_cert', titleEn: 'Pregnancy Certificate',
      titleAm: 'የእርግዝና ምስክር ወረቀት',
      descEn: 'A beautiful shareable card celebrating your pregnancy journey',
      descAm: 'የእርግዝና ጉዞዎን የሚያከብር ሊጋራ የሚችል ካርድ',
      cost: 100, type: RewardType.inApp,
      icon: Icons.card_giftcard_rounded, color: Color(0xFF1565C0),
    ),
    TsegaReward(
      id: 'offline_pack', titleEn: 'Offline Course Pack',
      titleAm: 'ከመስመር ውጭ ኮርስ',
      descEn: 'Download a full course bundle for use without internet',
      descAm: 'ያለ ኢንተርኔት ለመጠቀም ሙሉ ኮርስ ያውርዱ',
      cost: 200, type: RewardType.inApp,
      icon: Icons.download_rounded, color: Color(0xFF4CAF50), minLevel: 3,
    ),
    TsegaReward(
      id: 'premium_ai', titleEn: '30-Day Premium AI',
      titleAm: '30 ቀን ፕሪሚየም AI',
      descEn: 'Unlimited AI chat for 30 days — no daily message limit',
      descAm: 'ለ30 ቀናት ያልተወሰነ AI ውይይት — ዕለታዊ ገደብ የለም',
      cost: 300, type: RewardType.inApp,
      icon: Icons.psychology_rounded, color: Color(0xFF7C4DFF), minLevel: 3,
    ),
    // ── DIGITAL REWARDS ───────────────────────────────────────────
    TsegaReward(
      id: 'airtime_10', titleEn: 'Telebirr Airtime 10 ETB',
      titleAm: 'ቴሌብር አየር ሰዓት 10 ብር',
      descEn: 'Get 10 ETB airtime credited to your Telebirr account',
      descAm: '10 ብር ወደ ቴሌብር መለያዎ ይጨምሩ',
      cost: 100, type: RewardType.digital,
      icon: Icons.phone_in_talk_rounded, color: Color(0xFF009999),
      minLevel: 2, available: false, // available: false = "Coming soon"
    ),
    TsegaReward(
      id: 'pharmacy_10pct', titleEn: 'Pharmacy 10% Off',
      titleAm: 'ፋርማሲ 10% ቅናሽ',
      descEn: 'One-time 10% discount at partner pharmacies',
      descAm: 'በሸሪካ ፋርማሲዎች አንድ ጊዜ 10% ቅናሽ',
      cost: 150, type: RewardType.digital,
      icon: Icons.local_pharmacy_rounded, color: Color(0xFFE91E63),
      minLevel: 2, available: false,
    ),
    TsegaReward(
      id: 'supplement_disc', titleEn: 'Iron Supplement 20% Off',
      titleAm: 'ብረት ቫይታሚን 20% ቅናሽ',
      descEn: 'Discount on iron and folic acid supplements at partner stores',
      descAm: 'በሸሪካ መደብሮች ብረት እና ፎሊክ አሲድ ቫይታሚኖች ቅናሽ',
      cost: 200, type: RewardType.digital,
      icon: Icons.medication_rounded, color: Color(0xFF4CAF50),
      minLevel: 2, available: false,
    ),
    // ── PHYSICAL REWARDS ──────────────────────────────────────────
    TsegaReward(
      id: 'free_consultation', titleEn: 'Free ANC Consultation',
      titleAm: 'ነፃ ANC ምክር',
      descEn: 'One free ANC consultation at a partner health center',
      descAm: 'በሸሪካ ጤና ጣቢያ አንድ ነፃ ANC ምክር',
      cost: 500, type: RewardType.physical,
      icon: Icons.local_hospital_rounded, color: Color(0xFF1565C0),
      minLevel: 4, available: false,
    ),
  ];

  int get coinsFromXp => cost; // cost is already in TC
}

// ─── XP EVENTS ───────────────────────────────────────────────────
enum XpEvent {
  dailyLog, moduleComplete, quizPassed, labEntered,
  ancLogged, weekStreak, wearableSynced, stepsGoalMet,
  partnerJoined, dangerCheckDone, sponsorQrScanned,
}

extension XpEventValue on XpEvent {
  int get xp {
    switch (this) {
      case XpEvent.dailyLog: return 10;
      case XpEvent.moduleComplete: return 50;
      case XpEvent.quizPassed: return 30;
      case XpEvent.labEntered: return 25;
      case XpEvent.ancLogged: return 40;
      case XpEvent.weekStreak: return 100;
      case XpEvent.wearableSynced: return 5;
      case XpEvent.stepsGoalMet: return 15;
      case XpEvent.partnerJoined: return 50;
      case XpEvent.dangerCheckDone: return 15;
      case XpEvent.sponsorQrScanned: return 50;
    }
  }

  String labelEn() {
    switch (this) {
      case XpEvent.dailyLog: return 'Daily log';
      case XpEvent.moduleComplete: return 'Module completed';
      case XpEvent.quizPassed: return 'Quiz passed';
      case XpEvent.labEntered: return 'Lab result entered';
      case XpEvent.ancLogged: return 'ANC visit logged';
      case XpEvent.weekStreak: return '7-day streak';
      case XpEvent.wearableSynced: return 'Wearable synced';
      case XpEvent.stepsGoalMet: return 'Steps goal met';
      case XpEvent.partnerJoined: return 'Partner joined';
      case XpEvent.dangerCheckDone: return 'Danger check done';
      case XpEvent.sponsorQrScanned: return 'Sponsor QR scanned';
    }
  }

  String labelAm() {
    switch (this) {
      case XpEvent.dailyLog: return 'ዕለታዊ ምዝገባ';
      case XpEvent.moduleComplete: return 'ክፍል ተጠናቀቀ';
      case XpEvent.quizPassed: return 'ፈተና አለፉ';
      case XpEvent.labEntered: return 'የላብ ውጤት ገብቷል';
      case XpEvent.ancLogged: return 'ANC ጉብኝት ተመዝግቧል';
      case XpEvent.weekStreak: return '7 ቀን ተከታታይ';
      case XpEvent.wearableSynced: return 'ዌርአብል ተሳስሯል';
      case XpEvent.stepsGoalMet: return 'የእርምጃ ግብ ተሳካ';
      case XpEvent.partnerJoined: return 'ሸሪካ ተቀላቀለ';
      case XpEvent.dangerCheckDone: return 'አደጋ ፍተሻ ተጠናቀቀ';
      case XpEvent.sponsorQrScanned: return 'ስፖንሰር QR ተቃኘ';
    }
  }
}

// ─── WEARABLE MODEL ──────────────────────────────────────────────
enum WearableSource {
  googleFit, appleHealth, samsungHealth, fitbit, garmin, manual,
}

extension WearableInfo on WearableSource {
  String get nameEn {
    switch (this) {
      case WearableSource.googleFit: return 'Google Fit';
      case WearableSource.appleHealth: return 'Apple Health';
      case WearableSource.samsungHealth: return 'Samsung Health';
      case WearableSource.fitbit: return 'Fitbit';
      case WearableSource.garmin: return 'Garmin';
      case WearableSource.manual: return 'Manual Entry';
    }
  }

  String get nameAm {
    switch (this) {
      case WearableSource.googleFit: return 'ጉግል ፊት';
      case WearableSource.appleHealth: return 'አፕል ጤና';
      case WearableSource.samsungHealth: return 'ሳምሱንግ ጤና';
      case WearableSource.fitbit: return 'ፊትቢት';
      case WearableSource.garmin: return 'ጋርሚን';
      case WearableSource.manual: return 'በእጅ ማስገቢያ';
    }
  }

  String get iconAsset {
    switch (this) {
      case WearableSource.googleFit: return 'google_fit';
      case WearableSource.appleHealth: return 'apple_health';
      case WearableSource.samsungHealth: return 'samsung_health';
      case WearableSource.fitbit: return 'fitbit';
      case WearableSource.garmin: return 'garmin';
      case WearableSource.manual: return 'manual';
    }
  }

  bool get isAvailableAndroid {
    return this != WearableSource.appleHealth;
  }

  bool get isAvailableIos {
    return this == WearableSource.appleHealth ||
        this == WearableSource.fitbit ||
        this == WearableSource.garmin ||
        this == WearableSource.manual;
  }

  Color get brandColor {
    switch (this) {
      case WearableSource.googleFit: return const Color(0xFF4285F4);
      case WearableSource.appleHealth: return const Color(0xFFFF2D55);
      case WearableSource.samsungHealth: return const Color(0xFF1428A0);
      case WearableSource.fitbit: return const Color(0xFF00B0B9);
      case WearableSource.garmin: return const Color(0xFF007CC3);
      case WearableSource.manual: return const Color(0xFF009999);
    }
  }
}

class HealthSnapshot {
  final DateTime timestamp;
  final WearableSource source;
  final int? steps;
  final int? heartRate;     // bpm
  final double? spo2;       // SpO2 %
  final double? sleepHours;
  final double? weight;     // kg
  final int? activeMinutes;

  const HealthSnapshot({
    required this.timestamp, required this.source,
    this.steps, this.heartRate, this.spo2,
    this.sleepHours, this.weight, this.activeMinutes,
  });

  // Altitude-aware SpO2 alert for Ethiopian highlands
  bool get hasSpO2Alert {
    if (spo2 == null) return false;
    return spo2! < 92.0; // below 92% is concerning even at altitude
  }

  String get spO2Status {
    if (spo2 == null) return '--';
    if (spo2! >= 95) return 'Normal';
    if (spo2! >= 92) return 'Watch';
    return 'Low — seek care';
  }

  String get spO2StatusAm {
    if (spo2 == null) return '--';
    if (spo2! >= 95) return 'ተለምዶ';
    if (spo2! >= 92) return 'ይከታተሉ';
    return 'ዝቅ ያለ — ሐኪም ያማክሩ';
  }

  bool get stepsGoalMet => (steps ?? 0) >= 6000;
}
