import 'package:flutter/material.dart';
import '../constants/strings_en.dart';
import '../constants/strings_am.dart';

enum AppLanguage { english, amharic }

class LanguageProvider extends ChangeNotifier {
  AppLanguage _language = AppLanguage.english;

  AppLanguage get language => _language;
  bool get isAmharic => _language == AppLanguage.amharic;
  String get languageCode => isAmharic ? 'am' : 'en';

  void toggle() {
    _language = isAmharic ? AppLanguage.english : AppLanguage.amharic;
    notifyListeners();
  }

  void setLanguage(AppLanguage lang) {
    _language = lang;
    notifyListeners();
  }

  // Convenience: get string based on current language
  String s(String en, String am) => isAmharic ? am : en;

  // Typed string accessors
  String get appName => s(StringsEn.appName, StringsAm.appName);
  String get appTagline => s(StringsEn.appTagline, StringsAm.appTagline);
  String get navHome => s(StringsEn.navHome, StringsAm.navHome);
  String get navLearn => s(StringsEn.navLearn, StringsAm.navLearn);
  String get navHealth => s(StringsEn.navHealth, StringsAm.navHealth);
  String get navProfile => s(StringsEn.navProfile, StringsAm.navProfile);
  String get dailyTip => s(StringsEn.dailyTip, StringsAm.dailyTip);
  String get readMore => s(StringsEn.readMore, StringsAm.readMore);
  String get logToday => s(StringsEn.logToday, StringsAm.logToday);
  String get kickCounter => s(StringsEn.kickCounter, StringsAm.kickCounter);
  String get weekByWeek => s(StringsEn.weekByWeek, StringsAm.weekByWeek);
  String get logSymptoms => s(StringsEn.logSymptoms, StringsAm.logSymptoms);
  String get learningHub => s(StringsEn.learningHub, StringsAm.learningHub);
  String get medicalRecords => s(StringsEn.medicalRecords, StringsAm.medicalRecords);
  String get emergencySos => s(StringsEn.emergencySos, StringsAm.emergencySos);
  String get holdToActivate => s(StringsEn.holdToActivate, StringsAm.holdToActivate);
  String get riskLow => s(StringsEn.riskLow, StringsAm.riskLow);
  String get riskModerate => s(StringsEn.riskModerate, StringsAm.riskModerate);
  String get riskHigh => s(StringsEn.riskHigh, StringsAm.riskHigh);
  String get next => s(StringsEn.next, StringsAm.next);
  String get skip => s(StringsEn.skip, StringsAm.skip);
  String get getStarted => s(StringsEn.getStarted, StringsAm.getStarted);
  String get save => s(StringsEn.save, StringsAm.save);
  String get cancel => s(StringsEn.cancel, StringsAm.cancel);
  String get done => s(StringsEn.done, StringsAm.done);
  String get close => s(StringsEn.close, StringsAm.close);
  String get profile => s(StringsEn.profile, StringsAm.profile);
  String get settings => s(StringsEn.settings, StringsAm.settings);
  String get history => s(StringsEn.history, StringsAm.history);
  String get partner => s(StringsEn.partner, StringsAm.partner);
  String get switchStage => s(StringsEn.switchStage, StringsAm.switchStage);
  String get shareWithDoctor => s(StringsEn.shareWithDoctor, StringsAm.shareWithDoctor);
  String get addResult => s(StringsEn.addResult, StringsAm.addResult);
  String get nearestHospital => s(StringsEn.nearestHospital, StringsAm.nearestHospital);
  String get dangerSigns => s(StringsEn.dangerSigns, StringsAm.dangerSigns);
  String get firstAid => s(StringsEn.firstAid, StringsAm.firstAid);

  String get medicalRecords => s(StringsEn.medicalRecords, StringsAm.medicalRecords);
  String get addResult => s(StringsEn.addResult, StringsAm.addResult);
  String get scanQr => s(StringsEn.scanQr, StringsAm.scanQr);
  String get manualEntry => s(StringsEn.manualEntry, StringsAm.manualEntry);
  String get hemoglobin => s(StringsEn.hemoglobin, StringsAm.hemoglobin);
  String get bloodPressure => s(StringsEn.bloodPressure, StringsAm.bloodPressure);
  String get bloodSugar => s(StringsEn.bloodSugar, StringsAm.bloodSugar);
  String get weight => s(StringsEn.weight, StringsAm.weight);
  String get aiRiskAssessment => s(StringsEn.aiRiskAssessment, StringsAm.aiRiskAssessment);
  String get labResults => s(StringsEn.labResults, StringsAm.labResults);
  String get notifications => s(StringsEn.notifications, StringsAm.notifications);
  String get aboutTsega => s(StringsEn.aboutTsega, StringsAm.aboutTsega);
  String get support => s(StringsEn.support, StringsAm.support);
  String get reminders => s(StringsEn.reminders, StringsAm.reminders);
  String get kickCounter => s(StringsEn.kickCounter, StringsAm.kickCounter);
  String get weekByWeek => s(StringsEn.weekByWeek, StringsAm.weekByWeek);
  String get logSymptoms => s(StringsEn.logSymptoms, StringsAm.logSymptoms);
  String get logToday => s(StringsEn.logToday, StringsAm.logToday);
}