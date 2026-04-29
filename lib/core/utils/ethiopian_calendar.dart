// ════════════════════════════════════════════════════════════════
// ETHIOPIAN CALENDAR UTILITY
// Converts between Gregorian and Ethiopian (Ge'ez) calendar
// 13 months: 12 × 30 days + Pagume (5-6 days)
// ════════════════════════════════════════════════════════════════

class EthiopianCalendar {
  static const List<String> monthNamesAm = [
    'መስከረም','ጥቅምት','ህዳር','ታህሳስ','ጥር','የካቲት',
    'መጋቢት','ሚያዝያ','ግንቦት','ሰኔ','ሐምሌ','ነሐሴ','ጳጉሜ',
  ];
  static const List<String> monthNamesEn = [
    'Meskerem','Tikimt','Hidar','Tahsas','Tir','Yekatit',
    'Megabit','Miyazia','Ginbot','Sene','Hamle','Nehase','Pagume',
  ];
  static const List<String> dayNamesAm = [
    'እሑድ','ሰኞ','ማክሰኞ','ረቡዕ','ሐሙስ','ዓርብ','ቅዳሜ',
  ];
  static const List<String> dayNamesEn = [
    'Sun','Mon','Tue','Wed','Thu','Fri','Sat',
  ];

  // ── GREGORIAN → ETHIOPIAN ────────────────────────────────────
  static EthiopianDate fromGregorian(DateTime g) {
    final jdn = _gToJdn(g.year, g.month, g.day);
    return _jdnToEth(jdn);
  }

  // ── ETHIOPIAN → GREGORIAN ────────────────────────────────────
  static DateTime toGregorian(EthiopianDate e) {
    final jdn = _ethToJdn(e.year, e.month, e.day);
    return _jdnToG(jdn);
  }

  static EthiopianDate today() => fromGregorian(DateTime.now());
  static int currentYear() => today().year;

  static int daysInMonth(int y, int m) {
    if (m == 13) return y % 4 == 3 ? 6 : 5;
    return 30;
  }

  static int firstWeekdayOfMonth(int y, int m) {
    final g = toGregorian(EthiopianDate(y, m, 1));
    return g.weekday % 7;
  }

  static String formatMonthYear(int y, int m, {bool amharic = true}) {
    final name = amharic ? monthNamesAm[m - 1] : monthNamesEn[m - 1];
    return '$name $y';
  }

  static bool isWeeklyFastDay(DateTime g) =>
      g.weekday == DateTime.wednesday || g.weekday == DateTime.friday;

  static bool isFilsetaFasting(DateTime g) {
    final e = fromGregorian(g);
    return e.month == 12 && e.day <= 14;
  }

  // ── INTERNAL ─────────────────────────────────────────────────
  static int _gToJdn(int y, int m, int d) {
    final a = (14 - m) ~/ 12;
    final yr = y + 4800 - a;
    final mo = m + 12 * a - 3;
    return d + (153 * mo + 2) ~/ 5 + 365 * yr +
        yr ~/ 4 - yr ~/ 100 + yr ~/ 400 - 32045;
  }

  static EthiopianDate _jdnToEth(int jdn) {
    const ep = 1724221;
    final r = (jdn - ep) % 1461;
    final n = r % 365 + 365 * (r ~/ 1460);
    final year = 4 * ((jdn - ep) ~/ 1461) + r ~/ 365 - r ~/ 1460;
    final month = n ~/ 30 + 1;
    final day = n % 30 + 1;
    return EthiopianDate(year, month, day);
  }

  static int _ethToJdn(int y, int m, int d) =>
      1724221 + 365 * y + y ~/ 4 + 30 * m + d - 31;

  static DateTime _jdnToG(int jdn) {
    final l = jdn + 68569;
    final n = (4 * l) ~/ 146097;
    final ll = l - (146097 * n + 3) ~/ 4;
    final i = (4000 * (ll + 1)) ~/ 1461001;
    final lll = ll - (1461 * i) ~/ 4 + 31;
    final j = (80 * lll) ~/ 2447;
    final d = lll - (2447 * j) ~/ 80;
    final k = j ~/ 11;
    final m = j + 2 - 12 * k;
    final y = 100 * (n - 49) + i + k;
    return DateTime(y, m, d);
  }
}

class EthiopianDate {
  final int year, month, day;
  const EthiopianDate(this.year, this.month, this.day);
  String get monthNameAm => EthiopianCalendar.monthNamesAm[month - 1];
  String get monthNameEn => EthiopianCalendar.monthNamesEn[month - 1];
  bool get isFastingWeekday =>
      EthiopianCalendar.isWeeklyFastDay(EthiopianCalendar.toGregorian(this));
  @override
  String toString() => '$year-$month-$day (ET)';
}
