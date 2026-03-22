import 'package:flutter/material.dart';
import '../../models/gamification_model.dart';

class XpProvider extends ChangeNotifier {
  int _xp = 0;
  int _coins = 0;
  bool _justLeveledUp = false;
  bool _premiumAiActive = false;
  DateTime? _premiumAiExpiry;
  final List<XpEntry> _history = [];

  int get xp => _xp;
  int get coins => _coins;
  TsegaLevel get level => TsegaLevel.fromXp(_xp);
  double get levelProgress => level.progressWithin(_xp);
  int get xpToNextLevel => level.xpMax - _xp;
  bool get isPremiumAi =>
      _premiumAiActive &&
      _premiumAiExpiry != null &&
      DateTime.now().isBefore(_premiumAiExpiry!);
  List<XpEntry> get history => List.unmodifiable(_history);

  void load(int savedXp, int savedCoins) {
    _xp = savedXp; _coins = savedCoins; notifyListeners();
  }

  void addXp(XpEvent event, {int? customXp}) {
    final amount = customXp ?? event.xp;
    final prevLevel = level.level;
    _xp += amount;
    _coins = _xp ~/ 100;
    _history.insert(0, XpEntry(
        event: event, amount: amount, timestamp: DateTime.now()));
    if (_history.length > 50) _history.removeLast();
    if (level.level > prevLevel) _justLeveledUp = true;
    notifyListeners();
  }

  bool consumeLevelUp() {
    if (_justLeveledUp) { _justLeveledUp = false; return true; }
    return false;
  }

  bool canAfford(TsegaReward reward) => _coins >= reward.cost;

  bool redeem(TsegaReward reward) {
    if (!canAfford(reward)) return false;
    _coins -= reward.cost;
    _xp -= reward.cost * 100;
    if (_xp < 0) _xp = 0;
    if (reward.id == 'premium_ai') {
      _premiumAiActive = true;
      _premiumAiExpiry = DateTime.now().add(const Duration(days: 30));
    }
    notifyListeners();
    return true;
  }
}

class XpEntry {
  final XpEvent event;
  final int amount;
  final DateTime timestamp;
  XpEntry({required this.event, required this.amount, required this.timestamp});
}
