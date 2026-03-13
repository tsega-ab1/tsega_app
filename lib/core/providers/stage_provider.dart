import 'package:flutter/material.dart';

enum UserState { period, pregnancy }

enum LifeStage {
  adolescence,
  reproductive,
  pregnancy,
  postpartum,
  menopause,
}

class StageProvider extends ChangeNotifier {
  UserState _userState = UserState.period;
  LifeStage _lifeStage = LifeStage.reproductive;

  // Period mode data
  int _cycleDay = 1;
  int _cycleLength = 28;
  DateTime? _lastPeriodDate;

  // Pregnancy mode data
  DateTime? _lmpDate;
  int get pregnancyWeek {
    if (_lmpDate == null) return 0;
    return DateTime.now().difference(_lmpDate!).inDays ~/ 7;
  }

  DateTime? get dueDate {
    if (_lmpDate == null) return null;
    return _lmpDate!.add(const Duration(days: 280));
  }

  int get daysToGo {
    if (dueDate == null) return 0;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  int get daysUntilPeriod {
    if (_lastPeriodDate == null) return 14;
    final daysSince = DateTime.now().difference(_lastPeriodDate!).inDays;
    final remaining = _cycleLength - daysSince;
    return remaining < 0 ? 0 : remaining;
  }

  int get daysUntilOvulation {
    final ovulationDay = _cycleLength - 14;
    if (_lastPeriodDate == null) return ovulationDay;
    final daysSince = DateTime.now().difference(_lastPeriodDate!).inDays;
    final remaining = ovulationDay - daysSince;
    return remaining < 0 ? 0 : remaining;
  }

  UserState get userState => _userState;
  LifeStage get lifeStage => _lifeStage;
  bool get isPregnancyMode => _userState == UserState.pregnancy;
  bool get isPeriodMode => _userState == UserState.period;
  int get cycleDay => _cycleDay;
  DateTime? get lmpDate => _lmpDate;

  // Content visibility based on life stage
  bool get showCycleTracker =>
      _lifeStage != LifeStage.menopause && !isPregnancyMode;
  bool get showPregnancyContent =>
      _lifeStage == LifeStage.pregnancy || isPregnancyMode;
  bool get showPartnerModule =>
      _lifeStage != LifeStage.adolescence;
  bool get showAncReminders =>
      isPregnancyMode || _lifeStage == LifeStage.pregnancy;
  bool get showPostpartumContent =>
      _lifeStage == LifeStage.postpartum;
  bool get showAdolescentContent =>
      _lifeStage == LifeStage.adolescence;

  void setUserState(UserState state) {
    _userState = state;
    if (state == UserState.pregnancy) {
      _lifeStage = LifeStage.pregnancy;
    } else {
      if (_lifeStage == LifeStage.pregnancy) {
        _lifeStage = LifeStage.reproductive;
      }
    }
    notifyListeners();
  }

  void setLifeStage(LifeStage stage) {
    _lifeStage = stage;
    if (stage == LifeStage.pregnancy) {
      _userState = UserState.pregnancy;
    }
    notifyListeners();
  }

  void setLmpDate(DateTime date) {
    _lmpDate = date;
    _lastPeriodDate = date;
    notifyListeners();
  }

  void setCycleLength(int length) {
    _cycleLength = length;
    notifyListeners();
  }

  String get lifeStageLabel {
    switch (_lifeStage) {
      case LifeStage.adolescence: return 'Adolescence';
      case LifeStage.reproductive: return 'Reproductive';
      case LifeStage.pregnancy: return 'Pregnancy';
      case LifeStage.postpartum: return 'Postpartum';
      case LifeStage.menopause: return 'Menopause';
    }
  }

  IconData get lifeStageIcon {
    switch (_lifeStage) {
      case LifeStage.adolescence: return Icons.eco_rounded;
      case LifeStage.reproductive: return Icons.spa_rounded;
      case LifeStage.pregnancy: return Icons.pregnant_woman_rounded;
      case LifeStage.postpartum: return Icons.child_care_rounded;
      case LifeStage.menopause: return Icons.self_improvement_rounded;
    }
  }
}
