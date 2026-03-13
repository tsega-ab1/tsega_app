import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../core/theme/gradients.dart';

// ─── SYMPTOM MODEL ───────────────────────────────────────────────
class SymptomLog {
  final DateTime date;
  final String mood;
  final String flowIntensity; // none/light/medium/heavy
  final List<String> symptoms;
  final String? notes;

  const SymptomLog({
    required this.date,
    required this.mood,
    this.flowIntensity = 'none',
    this.symptoms = const [],
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'mood': mood,
    'flowIntensity': flowIntensity,
    'symptoms': symptoms,
    'notes': notes,
  };

  factory SymptomLog.fromJson(Map<String, dynamic> json) => SymptomLog(
    date: DateTime.parse(json['date']),
    mood: json['mood'] ?? '',
    flowIntensity: json['flowIntensity'] ?? 'none',
    symptoms: List<String>.from(json['symptoms'] ?? []),
    notes: json['notes'],
  );
}

// ─── MODULE MODEL ─────────────────────────────────────────────────
class EducationModule {
  final String id;
  final String titleEn;
  final String titleAm;
  final String categoryEn;
  final String categoryAm;
  final String duration;
  final LinearGradient gradient;
  final IconData icon;
  final bool completed;
  final bool locked;
  final int requiredPrevious; // how many modules must be done first
  final String contentEn;
  final String contentAm;
  final List<QuizQuestion> quiz;

  const EducationModule({
    required this.id,
    required this.titleEn,
    required this.titleAm,
    required this.categoryEn,
    required this.categoryAm,
    required this.duration,
    required this.gradient,
    required this.icon,
    this.completed = false,
    this.locked = false,
    this.requiredPrevious = 0,
    this.contentEn = '',
    this.contentAm = '',
    this.quiz = const [],
  });

  EducationModule copyWith({bool? completed, bool? locked}) => EducationModule(
    id: id, titleEn: titleEn, titleAm: titleAm,
    categoryEn: categoryEn, categoryAm: categoryAm,
    duration: duration, gradient: gradient, icon: icon,
    completed: completed ?? this.completed,
    locked: locked ?? this.locked,
    requiredPrevious: requiredPrevious,
    contentEn: contentEn, contentAm: contentAm, quiz: quiz,
  );
}

class QuizQuestion {
  final String questionEn;
  final String questionAm;
  final List<String> optionsEn;
  final List<String> optionsAm;
  final int correctIndex;

  const QuizQuestion({
    required this.questionEn,
    required this.questionAm,
    required this.optionsEn,
    required this.optionsAm,
    required this.correctIndex,
  });
}

// ─── TIP MODEL ───────────────────────────────────────────────────
class DailyTip {
  final String titleEn;
  final String titleAm;
  final String bodyEn;
  final String bodyAm;
  final String moduleId; // links to full module
  final IconData icon;
  final List<String> lifeStages; // which stages see this tip

  const DailyTip({
    required this.titleEn,
    required this.titleAm,
    required this.bodyEn,
    required this.bodyAm,
    this.moduleId = '',
    required this.icon,
    this.lifeStages = const ['all'],
  });
}

// ─── LAB RESULT MODEL ────────────────────────────────────────────
class LabResult {
  final DateTime date;
  final double? hemoglobin;
  final double? systolic;
  final double? diastolic;
  final double? bloodSugar;
  final double? weight;
  final double? urineProtein;
  final String? notes;
  final String riskLevel; // green / yellow / red

  const LabResult({
    required this.date,
    this.hemoglobin,
    this.systolic,
    this.diastolic,
    this.bloodSugar,
    this.weight,
    this.urineProtein,
    this.notes,
    this.riskLevel = 'green',
  });

  String get bloodPressure {
    if (systolic == null || diastolic == null) return '--/--';
    return '${systolic!.toInt()}/${diastolic!.toInt()}';
  }

  Color get riskColor {
    switch (riskLevel) {
      case 'red': return TColors.statusRed;
      case 'yellow': return TColors.statusYellow;
      default: return TColors.statusGreen;
    }
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'hemoglobin': hemoglobin,
    'systolic': systolic,
    'diastolic': diastolic,
    'bloodSugar': bloodSugar,
    'weight': weight,
    'urineProtein': urineProtein,
    'notes': notes,
    'riskLevel': riskLevel,
  };

  factory LabResult.fromJson(Map<String, dynamic> json) => LabResult(
    date: DateTime.parse(json['date']),
    hemoglobin: json['hemoglobin']?.toDouble(),
    systolic: json['systolic']?.toDouble(),
    diastolic: json['diastolic']?.toDouble(),
    bloodSugar: json['bloodSugar']?.toDouble(),
    weight: json['weight']?.toDouble(),
    urineProtein: json['urineProtein']?.toDouble(),
    notes: json['notes'],
    riskLevel: json['riskLevel'] ?? 'green',
  );
}

// ─── BADGE MODEL ─────────────────────────────────────────────────
class AchievementBadge {
  final String id;
  final String nameEn;
  final String nameAm;
  final String descEn;
  final String descAm;
  final IconData icon;
  final LinearGradient gradient;
  final int requiredModules;
  final bool unlocked;

  const AchievementBadge({
    required this.id,
    required this.nameEn,
    required this.nameAm,
    required this.descEn,
    required this.descAm,
    required this.icon,
    required this.gradient,
    required this.requiredModules,
    this.unlocked = false,
  });

  AchievementBadge copyWith({bool? unlocked}) => AchievementBadge(
    id: id, nameEn: nameEn, nameAm: nameAm,
    descEn: descEn, descAm: descAm,
    icon: icon, gradient: gradient,
    requiredModules: requiredModules,
    unlocked: unlocked ?? this.unlocked,
  );

  static List<AchievementBadge> get defaults => [
    AchievementBadge(
      id: 'first_step',
      nameEn: 'First Step', nameAm: 'የመጀመሪያ እርምጃ',
      descEn: 'Complete your first module', descAm: 'የመጀመሪያ ክፍልዎን ጨርሱ',
      icon: Icons.star_rounded, gradient: TGradients.gradTeal,
      requiredModules: 1,
    ),
    AchievementBadge(
      id: 'health_aware',
      nameEn: 'Health Aware', nameAm: 'ጤና ንቁ',
      descEn: 'Complete 3 modules', descAm: '3 ክፍሎች ይጨርሱ',
      icon: Icons.favorite_rounded, gradient: TGradients.gradPink,
      requiredModules: 3,
    ),
    AchievementBadge(
      id: 'health_scholar',
      nameEn: 'Health Scholar', nameAm: 'የጤና ምሁር',
      descEn: 'Complete 5 modules', descAm: '5 ክፍሎች ይጨርሱ',
      icon: Icons.school_rounded, gradient: TGradients.gradBlue,
      requiredModules: 5,
    ),
    AchievementBadge(
      id: 'tsega_champion',
      nameEn: 'Tsega Champion', nameAm: 'የጸጋ ሻምፒዮን',
      descEn: 'Complete all modules', descAm: 'ሁሉም ክፍሎች ይጨርሱ',
      icon: Icons.emoji_events_rounded, gradient: TGradients.gradGold,
      requiredModules: 8,
    ),
  ];
}
