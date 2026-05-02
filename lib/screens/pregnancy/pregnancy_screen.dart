import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../overlays/kick_counter_overlay.dart';
import '../../overlays/danger_checklist_overlay.dart';
import '../../overlays/quick_log_overlay.dart';
import 'week_by_week_screen.dart';

// ════════════════════════════════════════════════════════════════
// PREGNANCY SCREEN
// Full pregnancy tracking hub — week bubble, ANC schedule,
// baby size, danger signs, quick actions
// ════════════════════════════════════════════════════════════════

class PregnancyScreen extends StatefulWidget {
  const PregnancyScreen({super.key});
  @override
  State<PregnancyScreen> createState() => _PregnancyScreenState();
}

class _PregnancyScreenState extends State<PregnancyScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double>   _pulse;
  late AnimationController _slideCtrl;
  late Animation<double>   _slide;

  // Mock data — replace with UserProvider values
  static const int _week     = 24;
  static const int _totalDays= 280;
  static const int _daysDone = (_week - 1) * 7 + 3;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _slide = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut);
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  String _trimester(int week) {
    if (week <= 13) return '1st';
    if (week <= 27) return '2nd';
    return '3rd';
  }

  String _trimesterAm(int week) {
    if (week <= 13) return '1ኛ ሶስት ወር';
    if (week <= 27) return '2ኛ ሶስት ወር';
    return '3ኛ ሶስት ወር';
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final daysLeft = _totalDays - _daysDone;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Stack(children: [
        // Background orbs
        Positioned(top: -80, right: -60,
            child: _Orb(300, TColors.blue500.withOpacity(0.12))),
        Positioned(bottom: 100, left: -60,
            child: _Orb(240, TColors.teal500.withOpacity(0.08))),

        SafeArea(child: FadeTransition(
          opacity: _slide,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── APP BAR ─────────────────────────────────
                Row(children: [
                  _GBtn(Icons.arrow_back_ios_rounded,
                      () => Navigator.pop(context)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lang.s('My Pregnancy', 'ፅንሴ'),
                          style: const TextStyle(fontSize: 20,
                              color: TColors.white,
                              fontWeight: FontWeight.w800)),
                      Text(lang.isAmharic
                          ? _trimesterAm(_week)
                          : '${_trimester(_week)} Trimester',
                          style: TextStyle(fontSize: 12,
                              color: TColors.blue300.withOpacity(0.8))),
                    ],
                  )),
                  // SOS button
                  GestureDetector(
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const DangerChecklistOverlay()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: TColors.red400.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: TColors.red400.withOpacity(0.4))),
                      child: Row(children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: TColors.red400, size: 14),
                        const SizedBox(width: 4),
                        Text(lang.s('Danger Signs', 'አደጋ ምልክቶች'),
                            style: const TextStyle(fontSize: 11,
                                color: TColors.red400,
                                fontWeight: FontWeight.w700)),
                      ])),
                  ),
                ]),

                const SizedBox(height: 24),

                // ── WEEK HERO BUBBLE ─────────────────────────
                Center(child: AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, __) => Transform.scale(
                    scale: _pulse.value,
                    child: _WeekBubble(
                        week: _week, lang: lang, daysLeft: daysLeft),
                  ),
                )),

                const SizedBox(height: 20),

                // ── BABY SIZE BANNER ─────────────────────────
                _BabySizeBanner(week: _week, lang: lang),

                const SizedBox(height: 16),

                // ── PROGRESS BAR ─────────────────────────────
                _ProgressBar(
                    daysDone: _daysDone,
                    totalDays: _totalDays,
                    lang: lang),

                const SizedBox(height: 20),

                // ── QUICK ACTIONS ────────────────────────────
                _SectionLabel(
                    lang.s('Quick Actions', 'ፈጣን እርምጃዎች')),
                const SizedBox(height: 10),
                _QuickActions(lang: lang),

                const SizedBox(height: 20),

                // ── WHAT TO EXPECT THIS WEEK ─────────────────
                _SectionLabel(
                    lang.s('This Week', 'ይህ ሳምንት')),
                const SizedBox(height: 10),
                _ThisWeekCard(week: _week, lang: lang),

                const SizedBox(height: 20),

                // ── ANC SCHEDULE ─────────────────────────────
                _SectionLabel(
                    lang.s('ANC Schedule', 'ANC መርሃ ግብር')),
                const SizedBox(height: 10),
                _AncSchedule(currentWeek: _week, lang: lang),

                const SizedBox(height: 20),

                // ── WEEK BY WEEK BUTTON ──────────────────────
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) =>
                          WeekByWeekScreen(currentWeek: _week))),
                  child: Container(
                    width: double.infinity, height: 52,
                    decoration: BoxDecoration(
                      gradient: TGradients.gradBlue,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(
                        color: TColors.blue500.withOpacity(0.3),
                        blurRadius: 16, offset: const Offset(0, 6))]),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_view_week_rounded,
                            color: TColors.white, size: 20),
                        const SizedBox(width: 10),
                        Text(lang.s('Week by Week Guide',
                            'ሳምንት በሳምንት መመሪያ'),
                            style: const TextStyle(
                                color: TColors.white, fontSize: 15,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            color: TColors.white, size: 13),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )),
      ]),
    );
  }
}

// ── WEEK BUBBLE ───────────────────────────────────────────────────
class _WeekBubble extends StatelessWidget {
  final int week, daysLeft;
  final LanguageProvider lang;
  const _WeekBubble({
    required this.week, required this.lang, required this.daysLeft});

  @override
  Widget build(BuildContext context) => Container(
    width: 200, height: 200,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        colors: [TColors.blue700, TColors.blue500],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight),
      boxShadow: [
        BoxShadow(color: TColors.blue500.withOpacity(0.35),
            blurRadius: 40, spreadRadius: 8),
        BoxShadow(color: TColors.blue700.withOpacity(0.2),
            blurRadius: 60, spreadRadius: 15),
      ]),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(lang.s('WEEK', 'ሳምንት'),
            style: TextStyle(fontSize: 12,
                color: TColors.white.withOpacity(0.6),
                letterSpacing: 2, fontWeight: FontWeight.w600)),
        Text('$week',
            style: const TextStyle(fontSize: 72,
                color: TColors.white, fontWeight: FontWeight.w800,
                height: 1.0)),
        Text(
          lang.s('$daysLeft days left', '$daysLeft ቀናት ቀርቷቸዋል'),
          style: TextStyle(fontSize: 11,
              color: TColors.white.withOpacity(0.55))),
      ],
    ),
  );
}

// ── BABY SIZE BANNER ──────────────────────────────────────────────
class _BabySizeBanner extends StatelessWidget {
  final int week;
  final LanguageProvider lang;
  const _BabySizeBanner({required this.week, required this.lang});

  static const Map<int, (String, String, String)> _sizes = {
    4:  ('🫐', 'size of a poppy seed', 'የፖፒ ዘር መጠን'),
    8:  ('🫒', 'size of a raspberry', 'የራዝቤሪ መጠን'),
    12: ('🍋', 'size of a lime', 'የሎሚ መጠን'),
    16: ('🥑', 'size of an avocado', 'የአቮካዶ መጠን'),
    20: ('🍌', 'size of a banana', 'የሙዝ መጠን'),
    24: ('🌽', 'size of an ear of corn', 'የቆሎ ዘንግ መጠን'),
    28: ('🥥', 'size of a coconut', 'የኮኮናት መጠን'),
    32: ('🍍', 'size of a pineapple', 'የኣናናስ መጠን'),
    36: ('🥬', 'size of a head of lettuce', 'የሰላጣ ራስ መጠን'),
    40: ('🎃', 'size of a small pumpkin', 'ትንሽ ዱባ መጠን'),
  };

  (String, String, String) get _sizeData {
    int closest = 4;
    for (final k in _sizes.keys) {
      if (k <= week) closest = k;
    }
    return _sizes[closest]!;
  }

  @override
  Widget build(BuildContext context) {
    final d = _sizeData;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: TColors.blue500.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: TColors.blue500.withOpacity(0.2))),
          child: Row(children: [
            Text(d.$1, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(lang.s('Your baby is the', 'ሕፃንዎ ነው'),
                  style: TextStyle(fontSize: 11,
                      color: TColors.white.withOpacity(0.45))),
              Text(lang.isAmharic ? d.$3 : d.$2,
                  style: const TextStyle(fontSize: 15,
                      color: TColors.white, fontWeight: FontWeight.w700)),
            ]),
          ]),
        ),
      ),
    );
  }
}

// ── PROGRESS BAR ──────────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final int daysDone, totalDays;
  final LanguageProvider lang;
  const _ProgressBar({
    required this.daysDone, required this.totalDays,
    required this.lang});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(lang.s('Pregnancy Progress', 'የእርግዝና ሂደት'),
            style: TextStyle(fontSize: 12,
                color: TColors.white.withOpacity(0.45))),
        Text('${((daysDone / totalDays) * 100).toInt()}%',
            style: const TextStyle(fontSize: 12,
                color: TColors.blue300, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: daysDone / totalDays,
          backgroundColor: TColors.white.withOpacity(0.07),
          valueColor: AlwaysStoppedAnimation(TColors.blue500),
          minHeight: 6),
      ),
      const SizedBox(height: 4),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(lang.s('Day 1', 'ቀን 1'),
            style: TextStyle(fontSize: 10,
                color: TColors.white.withOpacity(0.3))),
        Text(lang.s('Day $totalDays', 'ቀን $totalDays'),
            style: TextStyle(fontSize: 10,
                color: TColors.white.withOpacity(0.3))),
      ]),
    ],
  );
}

// ── QUICK ACTIONS ─────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  final LanguageProvider lang;
  const _QuickActions({required this.lang});

  @override
  Widget build(BuildContext context) => Row(children: [
    _ActionBtn(
      icon: Icons.child_care_rounded,
      labelEn: 'Kick\nCounter',
      labelAm: 'ምቶች\nቁጠሩ',
      color: TColors.teal500,
      lang: lang,
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const KickCounterOverlay()),
    ),
    const SizedBox(width: 10),
    _ActionBtn(
      icon: Icons.edit_note_rounded,
      labelEn: 'Log\nSymptoms',
      labelAm: 'ምልክቶች\nይምዝገቡ',
      color: TColors.pink500,
      lang: lang,
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const QuickLogOverlay()),
    ),
    const SizedBox(width: 10),
    _ActionBtn(
      icon: Icons.monitor_heart_rounded,
      labelEn: 'Week by\nWeek',
      labelAm: 'ሳምንት\nበሳምንት',
      color: TColors.blue500,
      lang: lang,
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) =>
              const WeekByWeekScreen(currentWeek: 24))),
    ),
    const SizedBox(width: 10),
    _ActionBtn(
      icon: Icons.local_hospital_rounded,
      labelEn: 'ANC\nVisit',
      labelAm: 'ANC\nቀጠሮ',
      color: const Color(0xFF4CAF50),
      lang: lang,
      onTap: () {},
    ),
  ]);
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String labelEn, labelAm;
  final Color color;
  final LanguageProvider lang;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.labelEn,
      required this.labelAm, required this.color, required this.lang,
      required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.25))),
            child: Column(children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(lang.isAmharic ? labelAm : labelEn,
                  style: TextStyle(fontSize: 10,
                      color: color, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center),
            ]),
          ),
        ),
      ),
    ),
  );
}

// ── THIS WEEK CARD ────────────────────────────────────────────────
class _ThisWeekCard extends StatelessWidget {
  final int week;
  final LanguageProvider lang;
  const _ThisWeekCard({required this.week, required this.lang});

  String _devEn(int w) {
    if (w <= 12) return 'Major organs are forming. The neural tube that becomes the brain and spine is developing rapidly.';
    if (w <= 27) return 'Baby is growing fast. Hearing is developing — your baby can hear your voice. Movements become stronger.';
    if (w <= 36) return 'Baby is gaining weight rapidly. Lungs are maturing. Eyes can open and close. Position may be head-down.';
    return 'Baby is fully developed and ready for birth. You may feel increased pressure in your pelvis.';
  }

  String _devAm(int w) {
    if (w <= 12) return 'ዋና አካሎች እየፈጠሩ ናቸው። አዕምሮ እና አጥንት የሚሆነው የነርቭ ቱቦ በፍጥነት ያድጋል።';
    if (w <= 27) return 'ሕፃኑ በፍጥነት ያድጋል። መስሚያ እያደገ ነው — ሕፃኑ ድምጽዎን ሊሰማ ይችላል። እንቅስቃሴዎች ይጠናከራሉ።';
    if (w <= 36) return 'ሕፃኑ ክብደት በፍጥነት ያሸምናል። ሳምባዎች ያድጋሉ። ዓይኖች መከፈት ይችላሉ። ቦታው ጭንቅላት ሊሆን ይችላል።';
    return 'ሕፃኑ ሙሉ ለሙሉ ተፈጥሯል እና ለወሊድ ዝግጁ ነው። በዳሌ ውስጥ ጫና ሊሰማ ይችላል።';
  }

  String _feelEn(int w) {
    if (w <= 12) return 'Nausea, fatigue, and frequent urination are common. Your body is working hard.';
    if (w <= 27) return 'Energy often improves in the second trimester. Back pain and heartburn may begin.';
    if (w <= 36) return 'Sleep may be difficult. Braxton Hicks contractions. Shortness of breath as baby grows.';
    return 'Strong pressure in pelvis. Nesting instinct common. Watch for labour signs — regular contractions, water breaking.';
  }

  String _feelAm(int w) {
    if (w <= 12) return 'ማቅለሽለሽ፣ ድካም እና ተደጋጋሚ ሽንት ተለምዶ ናቸው። ሰውነትዎ በጥብቅ እየሰራ ነው።';
    if (w <= 27) return 'ኃይሎ በ2ኛ ሶስት ወር ብዙ ጊዜ ይሻሻላል። ጀርባ ምት እና ደረት ማቃጠል ሊጀምር ይችላል።';
    if (w <= 36) return 'እንቅልፍ ሊቸግር ይችላል። ብራክስተን ሂክስ። ሕፃኑ ሲያድግ ትንፋሽ ሊቆም ይችላል።';
    return 'በዳሌ ውስጥ ጠንካራ ጫና። ፓዘር ስሜት ተለምዶ ነው። ለወሊድ ምልክቶች ይጠብቁ።';
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        decoration: BoxDecoration(
          color: TColors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TColors.white.withOpacity(0.08))),
        child: Column(children: [
          _Row(Icons.child_care_rounded, TColors.blue400,
              lang.s('Baby', 'ሕፃኑ'),
              lang.isAmharic ? _devAm(week) : _devEn(week),
              lang),
          Divider(color: TColors.white.withOpacity(0.05), height: 1),
          _Row(Icons.pregnant_woman_rounded, TColors.pink400,
              lang.s('You', 'እርስዎ'),
              lang.isAmharic ? _feelAm(week) : _feelEn(week),
              lang),
        ]),
      ),
    ),
  );
}

class _Row extends StatelessWidget {
  final IconData icon; final Color color;
  final String label, text;
  final LanguageProvider lang;
  const _Row(this.icon, this.color, this.label, this.text, this.lang);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(14),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(9)),
        child: Icon(icon, color: color, size: 16)),
      const SizedBox(width: 10),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11,
              color: color, fontWeight: FontWeight.w700,
              letterSpacing: 0.3)),
          const SizedBox(height: 3),
          Text(text, style: TextStyle(fontSize: 13,
              height: 1.55, color: TColors.white.withOpacity(0.7))),
        ],
      )),
    ]),
  );
}

// ── ANC SCHEDULE ──────────────────────────────────────────────────
class _AncSchedule extends StatelessWidget {
  final int currentWeek;
  final LanguageProvider lang;
  const _AncSchedule({required this.currentWeek, required this.lang});

  static const List<(int, String)> _visits = [
    (8,  'First ANC — Blood tests, weight, BP'),
    (12, 'Dating scan — Confirm due date'),
    (16, 'Blood pressure check — Anaemia screen'),
    (20, 'Anatomy scan — Baby development check'),
    (24, 'Glucose tolerance test — Gestational diabetes'),
    (28, 'Third trimester check — Iron levels'),
    (32, 'Growth scan — Baby position'),
    (36, 'Birth planning — Hospital registration'),
    (38, 'Final check — Labour readiness'),
    (40, 'Due date — Labour assessment'),
  ];

  static const List<(int, String)> _visitsAm = [
    (8,  'የመጀመሪያ ANC — የደም ምርመራ፣ ክብደት፣ BP'),
    (12, 'ቀን ኢኮ — የወሊድ ቀን ያረጋግጡ'),
    (16, 'ደም ግፊት ፍተሻ — የደም ማነስ ምርመራ'),
    (20, 'አናቶሚ ኢኮ — የሕፃን እድገት ፍተሻ'),
    (24, 'የስኳር ፍተሻ — የእርግዝና ስኳር'),
    (28, 'ሶስተኛ ሶስት ወር ፍተሻ — የብረት ደረጃ'),
    (32, 'የእድገት ኢኮ — የሕፃን ቦታ'),
    (36, 'የወሊድ እቅድ — የሆስፒታል ምዝገባ'),
    (38, 'ሁዳዴ ፍተሻ — ለወሊድ ዝግጁነት'),
    (40, 'የወሊድ ቀን — የወሊድ ምዘና'),
  ];

  @override
  Widget build(BuildContext context) {
    final visits = lang.isAmharic ? _visitsAm : _visits;
    return Column(
      children: visits.map((v) {
        final week = v.$1;
        final desc = v.$2;
        final isPast    = week < currentWeek;
        final isCurrent = week == currentWeek ||
            (currentWeek > week - 3 && currentWeek <= week);
        final isFuture  = week > currentWeek;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? TColors.blue500.withOpacity(0.12)
                      : isPast
                          ? TColors.white.withOpacity(0.03)
                          : TColors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrent
                        ? TColors.blue500.withOpacity(0.4)
                        : TColors.white.withOpacity(0.06),
                    width: isCurrent ? 1.5 : 1)),
                child: Row(children: [
                  // Week circle
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isPast
                          ? TColors.green500.withOpacity(0.15)
                          : isCurrent
                              ? TColors.blue500.withOpacity(0.2)
                              : TColors.white.withOpacity(0.05)),
                    child: Center(child: isPast
                        ? const Icon(Icons.check_rounded,
                            color: TColors.green500, size: 16)
                        : Text('$week',
                            style: TextStyle(fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: isCurrent
                                    ? TColors.blue300
                                    : TColors.white.withOpacity(0.3))))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.s('Week $week', 'ሳምንት $week'),
                        style: TextStyle(fontSize: 11,
                            color: isCurrent
                                ? TColors.blue300 : TColors.white.withOpacity(0.35),
                            fontWeight: FontWeight.w600)),
                      Text(desc,
                          style: TextStyle(fontSize: 12,
                              color: isPast
                                  ? TColors.white.withOpacity(0.35)
                                  : isCurrent
                                      ? TColors.white.withOpacity(0.85)
                                      : TColors.white.withOpacity(0.55))),
                    ],
                  )),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: TColors.blue500.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6)),
                      child: Text(lang.s('Now', 'አሁን'),
                          style: const TextStyle(fontSize: 9,
                              color: TColors.blue300,
                              fontWeight: FontWeight.w700))),
                ]),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── SHARED WIDGETS ────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
          color: TColors.white.withOpacity(0.4), letterSpacing: 0.5));
}

class _GBtn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap;
  const _GBtn(this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(11),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: TColors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
                color: TColors.white.withOpacity(0.10))),
          child: Icon(icon, color: TColors.white, size: 17)))));
}

class _Orb extends StatelessWidget {
  final double size; final Color color;
  const _Orb(this.size, this.color);
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color,
            blurRadius: size, spreadRadius: size * 0.18)]));
}
