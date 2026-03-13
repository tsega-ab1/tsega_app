import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/models.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    assert(_prefs != null, 'StorageService not initialized');
    return _prefs!;
  }

  // ─── First launch ─────────────────────────────────────────────
  static bool get isFirstLaunch =>
      prefs.getBool(AppConstants.keyIsFirstLaunch) ?? true;

  static Future<void> setFirstLaunchDone() =>
      prefs.setBool(AppConstants.keyIsFirstLaunch, false);

  // ─── Language ──────────────────────────────────────────────────
  static String get language =>
      prefs.getString(AppConstants.keyLanguage) ?? 'en';

  static Future<void> setLanguage(String lang) =>
      prefs.setString(AppConstants.keyLanguage, lang);

  // ─── User profile ──────────────────────────────────────────────
  static UserModel? getUser() {
    final json = prefs.getString(AppConstants.keyUserProfile);
    if (json == null) return null;
    return UserModel.fromJson(jsonDecode(json));
  }

  static Future<void> saveUser(UserModel user) =>
      prefs.setString(AppConstants.keyUserProfile, jsonEncode(user.toJson()));

  // ─── User state (period/pregnancy) ────────────────────────────
  static String get userState =>
      prefs.getString(AppConstants.keyUserState) ?? 'period';

  static Future<void> setUserState(String state) =>
      prefs.setString(AppConstants.keyUserState, state);

  // ─── Module progress ──────────────────────────────────────────
  static Map<String, bool> getModuleProgress() {
    final json = prefs.getString(AppConstants.keyModuleProgress);
    if (json == null) return {};
    return Map<String, bool>.from(jsonDecode(json));
  }

  static Future<void> setModuleProgress(Map<String, bool> progress) =>
      prefs.setString(AppConstants.keyModuleProgress, jsonEncode(progress));

  static Future<void> markModuleComplete(String moduleId) async {
    final progress = getModuleProgress();
    progress[moduleId] = true;
    await setModuleProgress(progress);
  }

  // ─── Badges ───────────────────────────────────────────────────
  static List<String> getUnlockedBadges() {
    return prefs.getStringList(AppConstants.keyBadges) ?? [];
  }

  static Future<void> unlockBadge(String badgeId) async {
    final badges = getUnlockedBadges();
    if (!badges.contains(badgeId)) {
      badges.add(badgeId);
      await prefs.setStringList(AppConstants.keyBadges, badges);
    }
  }

  // ─── Symptom logs ─────────────────────────────────────────────
  static List<SymptomLog> getSymptomLogs() {
    final json = prefs.getString(AppConstants.keySymptomLogs);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => SymptomLog.fromJson(e)).toList();
  }

  static Future<void> addSymptomLog(SymptomLog log) async {
    final logs = getSymptomLogs();
    logs.add(log);
    await prefs.setString(
        AppConstants.keySymptomLogs,
        jsonEncode(logs.map((e) => e.toJson()).toList()));
  }

  // ─── Lab results ──────────────────────────────────────────────
  static List<LabResult> getLabResults() {
    final json = prefs.getString(AppConstants.keyLabResults);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => LabResult.fromJson(e)).toList();
  }

  static Future<void> addLabResult(LabResult result) async {
    final results = getLabResults();
    results.add(result);
    await prefs.setString(
        AppConstants.keyLabResults,
        jsonEncode(results.map((e) => e.toJson()).toList()));
  }

  // ─── Streak ───────────────────────────────────────────────────
  static int get streak => prefs.getInt(AppConstants.keyStreak) ?? 0;
  static Future<void> setStreak(int s) => prefs.setInt(AppConstants.keyStreak, s);

  static String? get lastLogDate =>
      prefs.getString(AppConstants.keyLastLogDate);
  static Future<void> setLastLogDate(String date) =>
      prefs.setString(AppConstants.keyLastLogDate, date);
}
