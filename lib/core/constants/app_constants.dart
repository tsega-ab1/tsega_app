class AppConstants {
  AppConstants._();

  // Ethiopian regions
  static const regions = [
    'Addis Ababa',
    'Afar',
    'Amhara',
    'Benishangul-Gumuz',
    'Dire Dawa',
    'Gambella',
    'Harari',
    'Oromia',
    'Sidama',
    'SNNPR',
    'Somali',
    'Tigray',
    'Central Ethiopia',
    'South Ethiopia',
    'South West Ethiopia',
  ];

  // Altitude by region (meters)
  static const altitudes = {
    'Addis Ababa': 2300,
    'Amhara': 2100,
    'Tigray': 2000,
    'Oromia': 1800,
    'SNNPR': 1600,
    'Afar': 400,
    'Somali': 500,
    'Gambella': 450,
    'Dire Dawa': 1180,
  };

  // Altitude-adjusted Hb thresholds (g/dL)
  static double hbNormalMin(int altitudeM) {
    if (altitudeM >= 2500) return 13.0;
    if (altitudeM >= 2000) return 12.5;
    if (altitudeM >= 1500) return 12.2;
    return 12.0;
  }

  // Baby size by week
  static const babySizes = {
    4: 'a poppy seed',    8: 'a raspberry',
    10: 'a strawberry',  12: 'a lime',
    14: 'a lemon',       16: 'an avocado',
    18: 'a sweet potato',20: 'a banana',
    24: 'an ear of corn',28: 'an eggplant',
    32: 'a squash',      36: 'a romaine lettuce',
    40: 'a small pumpkin',
  };

  // Ethiopian emergency numbers
  static const ambulanceNumber = '907';
  static const policeNumber = '911';
  static const fireNumber = '939';

  // Fasting seasons (approximate Gregorian months)
  static const fastingMonths = [3, 4, 8, 11, 12]; // March/April Tsome, Aug, Nov, Dec

  // Storage keys
  static const keyUserProfile    = 'user_profile';
  static const keyUserState      = 'user_state';
  static const keyLanguage       = 'language';
  static const keyIsFirstLaunch  = 'is_first_launch';
  static const keyModuleProgress = 'module_progress';
  static const keyBadges         = 'badges';
  static const keySymptomLogs    = 'symptom_logs';
  static const keyLabResults     = 'lab_results';
  static const keyStreak         = 'streak';
  static const keyLastLogDate    = 'last_log_date';
}
