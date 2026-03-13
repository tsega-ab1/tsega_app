import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  int _streak = 0;
  DateTime? _lastLogDate;

  UserModel? get user => _user;
  int get streak => _streak;
  bool get hasUser => _user != null;

  String get displayName => _user?.name ?? 'Guest';
  String get greetingName => _user?.name.split(' ').first ?? 'there';

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void updateStreak() {
    final today = DateTime.now();
    if (_lastLogDate == null) {
      _streak = 1;
    } else {
      final diff = today.difference(_lastLogDate!).inDays;
      if (diff == 1) {
        _streak++;
      } else if (diff > 1) {
        _streak = 1;
      }
    }
    _lastLogDate = today;
    notifyListeners();
  }

  void updateUser({
    String? name,
    DateTime? dob,
    String? region,
    String? partnerPhone,
    String? emergencyContact,
    String? emergencyName,
  }) {
    if (_user == null) return;
    _user = _user!.copyWith(
      name: name,
      dob: dob,
      region: region,
      partnerPhone: partnerPhone,
      emergencyContact: emergencyContact,
      emergencyName: emergencyName,
    );
    notifyListeners();
  }

  void clear() {
    _user = null;
    _streak = 0;
    _lastLogDate = null;
    notifyListeners();
  }
}
