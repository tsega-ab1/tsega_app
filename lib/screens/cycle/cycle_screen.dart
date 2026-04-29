import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';
import '../../core/utils/ethiopian_calendar.dart';
import '../../overlays/hormone_chart_overlay.dart';
import '../../overlays/quick_log_overlay.dart';

// ════════════════════════════════════════════════════════════════
// CYCLE SCREEN — Complete with:
//   - Ring view (circular progress visualiser)
//   - Calendar view (Gregorian OR Ethiopian/Ge'ez)
//   - Toggle between ring and calendar
//   - Toggle between Gregorian and Ethiopian calendar
//   - Tap any day → HormoneChartOverlay popup
//   - Fasting day indicator (Ge'ez calendar)
//   - Daily insight card based on cycle phase
// ════════════════════════════════════════════════════════════════

class CycleScreen extends StatefulWidget {
  const CycleScreen({super.key});
  @override
  State<CycleScreen> createState() => _CycleScreenState();
}

class _CycleScreenState extends State<CycleScreen>
    with TickerProviderStateMixin {

  // View toggles
  bool _showCal = false;
  bool _useEth  = false;

  // Calendar navigation
  DateTime _gregMonth = DateTime.now();
  late EthiopianDate _ethMonth;
  DateTime? _selectedDay;

  // Cycle data — replace these with real user data from StorageService
  static const int _cycleLen  = 28;
  static const int _cycleDay  = 14;
  static const int _periodLen = 5;
  final DateTime _lastPeriod =
      DateTime.now().subtract(const Duration(days: 13));

  // Logged data — replace with StorageService.loadLogs()
  final Map<String, String> _symptoms = {};
  final Map<String, String> _flow     = {};

  late AnimationController _ringCtrl;
  late Animation<double>   _ringAnim;

  @override
  void initState() {
    super.initState();
    _ethMonth = EthiopianCalendar.fromGregorian(_gregMonth);
    _ringCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600));
    _ringAnim = CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut);
    _ringCtrl.forward();
  }

  @override
  void dispose() { _ringCtrl.dispose(); super.dispose(); }

  // ── Cycle day for a given Gregorian date ─────────────────────
  int? _cycleDayFor(DateTime d) {
    final diff = d.difference(_lastPeriod).inDays;
    if (diff < 0) return null;
    return (diff % _cycleLen) + 1;
  }

  // ── Open hormone popup ────────────────────────────────────────
  void _openHormone(DateTime date) {
    final cd = _cycleDayFor(date);
    if (cd == null) return;
    final key = '${date.year}-${date.month}-${date.day}';
    final lang = context.read<LanguageProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HormoneChartOverlay(
        cycleDay: cd,
        cycleLength: _cycleLen,
        selectedDate: date,
        isAmharic: lang.isAmharic,
        symptoms: _symptoms[key],
        flow: _flow[key],
      ),
    );
  }

  // ── Month navigation ──────────────────────────────────────────
  void _prevMonth() {
    setState(() {
      _gregMonth = DateTime(_gregMonth.year, _gregMonth.month - 1);
      _ethMonth = _useEth
          ? EthiopianDate(
              _ethMonth.month == 1 ? _ethMonth.year - 1 : _ethMonth.year,
              _ethMonth.month == 1 ? 13 : _ethMonth.month - 1, 1)
          : EthiopianCalendar.fromGregorian(_gregMonth);
    });
  }

  void _nextMonth() {
    setState(() {
      _gregMonth = DateTime(_gregMonth.year, _gregMonth.month + 1);
      _ethMonth = _useEth
          ? EthiopianDate(
              _ethMonth.month == 13 ? _ethMonth.year + 1 : _ethMonth.year,
              _ethMonth.month == 13 ? 1 : _ethMonth.month + 1, 1)
          : EthiopianCalendar.fromGregorian(_gregMonth);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Stack(children: [
        Positioned(top: -80, right: -60,
            child: _Orb(300, TColors.pink500.withOpacity(0.10))),
        Positioned(bottom: 80, left: -60,
            child: _Orb(240, TColors.teal500.withOpacity(0.08))),

        SafeArea(child: Column(children: [

          // ── APP BAR ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              _GBtn(Icons.arrow_back_ios_rounded,
                  () => Navigator.pop(context)),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lang.s('My Cycle', 'የእኔ ዑደት'),
                      style: const TextStyle(fontSize: 20,
                          color: TColors.white, fontWeight: FontWeight.w800)),
                  if (_showCal)
                    Text(_useEth
                        ? lang.s('Ethiopian Calendar ·ᴱᵀ', 'የኢትዮጵያ ቀን መቁጠሪያ ·ᴱᵀ')
                        : lang.s('Gregorian Calendar', 'ጎርጎሪያን ቀን መቁጠሪያ'),
                        style: TextStyle(fontSize: 10,
                            color: TColors.pink300.withOpacity(0.8))),
                ],
              )),

              // ET ↔ GR toggle — only visible in calendar view
              if (_showCal) ...[
                GestureDetector(
                  onTap: () => setState(() => _useEth = !_useEth),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: _useEth ? TGradients.gradTeal : null,
                      color: _useEth ? null
                          : TColors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _useEth
                            ? TColors.teal400
                            : TColors.white.withOpacity(0.15))),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(_useEth ? 'ᴱᵀ' : 'GR',
                          style: const TextStyle(fontSize: 12,
                              color: TColors.white,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'monospace')),
                      const SizedBox(width: 4),
                      Text(_useEth ? 'ኢትዮጵያ' : 'Gregorian',
                          style: TextStyle(fontSize: 9,
                              color: TColors.white.withOpacity(0.7))),
                    ]),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Ring ↔ Calendar toggle
              _GBtn(
                _showCal
                    ? Icons.radio_button_checked_rounded
                    : Icons.calendar_month_rounded,
                () {
                  setState(() => _showCal = !_showCal);
                  if (!_showCal) _ringCtrl.forward(from: 0);
                },
                active: true,
              ),
            ]),
          ),

          // ── STATS ROW ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(children: [
              _Chip('$_cycleDay',
                  lang.s('Cycle Day', 'ዑደት ቀን'),
                  TColors.pink500),
              const SizedBox(width: 8),
              _Chip('${_cycleLen - _cycleDay}',
                  lang.s('Until Period', 'ወር አበባ ሲቀር'),
                  TColors.teal500),
              const SizedBox(width: 8),
              _Chip(
                _cycleDay < (_cycleLen / 2).round() - 2
                    ? '${(_cycleLen / 2).round() - _cycleDay}'
                    : '✓',
                lang.s('Until Ovulation', 'ኦቭዩሌሽን ሲቀር'),
                const Color(0xFF4CAF50)),
            ]),
          ),

          const SizedBox(height: 8),

          // ── MAIN VIEW ────────────────────────────────────────
          Expanded(child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero).animate(anim),
                child: child)),
            child: _showCal
                ? (_useEth
                    ? _EthiopianGrid(
                        key: const ValueKey('eth'),
                        ethMonth: _ethMonth,
                        selected: _selectedDay,
                        cycleLen: _cycleLen,
                        periodLen: _periodLen,
                        lastPeriod: _lastPeriod,
                        symptoms: _symptoms,
                        lang: lang,
                        onTap: (d) {
                          setState(() => _selectedDay = d);
                          _openHormone(d);
                        },
                        onPrev: _prevMonth,
                        onNext: _nextMonth,
                      )
                    : _GregorianGrid(
                        key: const ValueKey('greg'),
                        month: _gregMonth,
                        selected: _selectedDay,
                        cycleLen: _cycleLen,
                        periodLen: _periodLen,
                        lastPeriod: _lastPeriod,
                        symptoms: _symptoms,
                        lang: lang,
                        onTap: (d) {
                          setState(() => _selectedDay = d);
                          _openHormone(d);
                        },
                        onPrev: _prevMonth,
                        onNext: _nextMonth,
                      ))
                : _RingView(
                    key: const ValueKey('ring'),
                    cycleDay: _cycleDay,
                    cycleLen: _cycleLen,
                    periodLen: _periodLen,
                    anim: _ringAnim,
                    lang: lang,
                    onLog: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const QuickLogOverlay()),
                    onTapCenter: () => _openHormone(DateTime.now()),
                  ),
          )),

          // ── LEGEND ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Leg(TColors.pink500, lang.s('Period','ወር አበባ')),
                const SizedBox(width: 14),
                _Leg(const Color(0xFF4CAF50), lang.s('Fertile','ፈሩ')),
                const SizedBox(width: 14),
                _Leg(TColors.teal400, lang.s('Logged','ምዝገባ')),
                const SizedBox(width: 14),
                _Leg(const Color(0xFFF9A825), lang.s('Fasting','ጾም')),
              ],
            ),
          ),
        ])),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// RING VIEW
// ════════════════════════════════════════════════════════════════
class _RingView extends StatelessWidget {
  final int cycleDay, cycleLen, periodLen;
  final Animation<double> anim;
  final LanguageProvider lang;
  final VoidCallback onLog, onTapCenter;
  const _RingView({super.key, required this.cycleDay, required this.cycleLen,
      required this.periodLen, required this.anim, required this.lang,
      required this.onLog, required this.onTapCenter});

  @override
  Widget build(BuildContext context) {
    final ov       = (cycleLen / 2).round();
    final isPeriod = cycleDay <= periodLen;
    final isFert   = cycleDay >= ov - 2 && cycleDay <= ov + 1;
    final label    = isPeriod
        ? lang.s('Period', 'ወር አበባ')
        : isFert
            ? lang.s('Fertile', 'ፈሩ')
            : lang.s('Follicular', 'ፎሊኩለር');
    final labelCol = isPeriod ? TColors.pink400
        : isFert ? const Color(0xFF4CAF50) : TColors.teal300;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(children: [
        // Ring
        GestureDetector(
          onTap: onTapCenter,
          child: Center(child: AnimatedBuilder(
            animation: anim,
            builder: (_, __) => SizedBox(
              width: 220, height: 220,
              child: Stack(alignment: Alignment.center, children: [
                CustomPaint(
                  size: const Size(220, 220),
                  painter: _RingPainter(
                    progress: anim.value * cycleDay / cycleLen,
                    cycleDay: cycleDay,
                    cycleLen: cycleLen,
                    periodLen: periodLen,
                  ),
                ),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('$cycleDay',
                      style: const TextStyle(fontSize: 58,
                          fontWeight: FontWeight.w800,
                          color: TColors.white, height: 1.0)),
                  Text(lang.s('Day', 'ቀን'),
                      style: TextStyle(fontSize: 14,
                          color: TColors.white.withOpacity(0.45))),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: labelCol.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10)),
                    child: Text(label,
                        style: TextStyle(fontSize: 12,
                            fontWeight: FontWeight.w700, color: labelCol))),
                  const SizedBox(height: 3),
                  Text(lang.s('Tap to see hormones →',
                      'ሆርሞኖች ለማየት ይጫኑ →'),
                      style: TextStyle(fontSize: 9,
                          color: TColors.white.withOpacity(0.3))),
                ]),
              ]),
            ),
          )),
        ),
        const SizedBox(height: 14),

        // Phase insight
        _PhaseCard(cycleDay: cycleDay, cycleLen: cycleLen,
            periodLen: periodLen, lang: lang),
        const SizedBox(height: 12),

        // Log button
        GestureDetector(
          onTap: onLog,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: TGradients.gradPink,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(
                color: TColors.pink500.withOpacity(0.3),
                blurRadius: 16, offset: const Offset(0, 6))]),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.add_rounded, color: TColors.white, size: 20),
              const SizedBox(width: 8),
              Text(lang.s('Log Today', 'ዛሬ ይምዝገቡ'),
                  style: const TextStyle(color: TColors.white,
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ])),
        ),
        const SizedBox(height: 20),
      ]),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final int cycleDay, cycleLen, periodLen;
  const _RingPainter({required this.progress, required this.cycleDay,
      required this.cycleLen, required this.periodLen});

  @override
  void paint(Canvas canvas, Size size) {
    const double pi = 3.14159265;
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 16;
    const sw = 16.0;
    const sa = -pi / 2;

    // Background ring
    canvas.drawCircle(c, r, Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..style = PaintingStyle.stroke..strokeWidth = sw);

    // Period zone
    canvas.drawArc(Rect.fromCircle(center: c, radius: r),
      sa, (periodLen / cycleLen) * 2 * pi, false,
      Paint()..color = TColors.pink500.withOpacity(0.22)
        ..style = PaintingStyle.stroke..strokeWidth = sw);

    // Fertile zone
    final ov = cycleLen / 2;
    canvas.drawArc(Rect.fromCircle(center: c, radius: r),
      sa + ((ov - 3) / cycleLen) * 2 * pi,
      (5 / cycleLen) * 2 * pi, false,
      Paint()..color = const Color(0xFF4CAF50).withOpacity(0.22)
        ..style = PaintingStyle.stroke..strokeWidth = sw);

    // Progress arc
    final sweep = progress * 2 * pi;
    canvas.drawArc(Rect.fromCircle(center: c, radius: r),
      sa, sweep, false,
      Paint()
        ..shader = SweepGradient(
          startAngle: sa, endAngle: sa + 2 * pi,
          colors: [TColors.pink400, TColors.pink600, TColors.pink400])
            .createShader(Rect.fromCircle(center: c, radius: r))
        ..style = PaintingStyle.stroke..strokeWidth = sw
        ..strokeCap = StrokeCap.round);

    // End dot
    final dotX = c.dx + r * cos(sa + sweep);
    final dotY = c.dy + r * sin(sa + sweep);
    canvas.drawCircle(Offset(dotX, dotY), 8,
        Paint()..color = TColors.pink400);
    canvas.drawCircle(Offset(dotX, dotY), 3,
        Paint()..color = TColors.white);
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.progress != progress;
}

// ── PHASE INSIGHT CARD ────────────────────────────────────────────
class _PhaseCard extends StatelessWidget {
  final int cycleDay, cycleLen, periodLen;
  final LanguageProvider lang;
  const _PhaseCard({required this.cycleDay, required this.cycleLen,
      required this.periodLen, required this.lang});

  @override
  Widget build(BuildContext context) {
    final ov = (cycleLen / 2).round();
    late String en, am;
    late Color col;
    late IconData icon;

    if (cycleDay <= periodLen) {
      en = 'Iron-rich foods help replace blood lost. Try misir wot, gomen, and teff injera.';
      am = 'ብረት ያለው ምግብ ያጡትን ደም ለመተካት ይረዳል። ምስር ወጥ፣ ጎመን እና ጤፍ ኢንጀራ ይሞክሩ።';
      col = TColors.pink500; icon = Icons.restaurant_rounded;
    } else if (cycleDay < ov - 2) {
      en = 'Estrogen rising. Energy, mood, and focus usually improve in this phase.';
      am = 'ኢስትሮጅን እያደገ ነው። ኃይሎ፣ ስሜት እና ትኩረት ብዙ ጊዜ ይሻሻላሉ።';
      col = TColors.teal500; icon = Icons.trending_up_rounded;
    } else if (cycleDay <= ov + 1) {
      en = 'LH surging — ovulation is happening. Your most fertile days.';
      am = 'LH እየወጣ ነው — ኦቭዩሌሽን እየሆነ ነው። እጅግ ፈሩ ቀናት።';
      col = const Color(0xFF4CAF50); icon = Icons.flash_on_rounded;
    } else {
      en = 'Progesterone rising. You may feel warmer and crave comfort foods.';
      am = 'ፕሮጀስቴሮን እያደገ ነው። ሙቀት ሊሰማ እና ምቹ ምግቦችን ሊፈልጉ ይችላሉ።';
      col = TColors.blue500; icon = Icons.psychology_rounded;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: col.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: col.withOpacity(0.2))),
          child: Row(children: [
            Icon(icon, color: col, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Text(
              lang.isAmharic ? am : en,
              style: TextStyle(fontSize: 13, height: 1.5,
                  color: TColors.white.withOpacity(0.8)))),
          ]),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// GREGORIAN CALENDAR GRID
// ════════════════════════════════════════════════════════════════
class _GregorianGrid extends StatelessWidget {
  final DateTime month;
  final DateTime? selected;
  final int cycleLen, periodLen;
  final DateTime lastPeriod;
  final Map<String, String> symptoms;
  final LanguageProvider lang;
  final Function(DateTime) onTap;
  final VoidCallback onPrev, onNext;
  const _GregorianGrid({super.key, required this.month, required this.selected,
      required this.cycleLen, required this.periodLen, required this.lastPeriod,
      required this.symptoms, required this.lang, required this.onTap,
      required this.onPrev, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final days  = DateTime(month.year, month.month + 1, 0).day;
    final offset = first.weekday % 7; // Sun=0
    final months = ['January','February','March','April','May','June',
        'July','August','September','October','November','December'];

    return Column(children: [
      _MonthNav(months[month.month - 1] + ' ${month.year}',
          null, onPrev, onNext),
      _DayHeaders(lang.isAmharic
          ? EthiopianCalendar.dayNamesAm
          : ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'],
          TColors.white.withOpacity(0.35)),
      Expanded(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 4),
          itemCount: offset + days,
          itemBuilder: (_, i) {
            if (i < offset) return const SizedBox();
            final d   = i - offset + 1;
            final dt  = DateTime(month.year, month.month, d);
            final diff= dt.difference(lastPeriod).inDays;
            final cd  = diff < 0 ? null : (diff % cycleLen) + 1;
            final ov  = (cycleLen / 2).round();
            final key = '${dt.year}-${dt.month}-${dt.day}';
            final now = DateTime.now();
            return _DayCell(
              label: '$d',
              subLabel: null,
              isPeriod: cd != null && cd <= periodLen,
              isFertile: cd != null && cd >= ov - 2 && cd <= ov + 1,
              isToday: dt.year == now.year && dt.month == now.month && dt.day == now.day,
              isSelected: selected != null && selected!.year == dt.year &&
                  selected!.month == dt.month && selected!.day == dt.day,
              hasLog: symptoms.containsKey(key),
              isFasting: false,
              onTap: () => onTap(dt),
            );
          },
        ),
      )),
    ]);
  }
}

// ════════════════════════════════════════════════════════════════
// ETHIOPIAN CALENDAR GRID
// ════════════════════════════════════════════════════════════════
class _EthiopianGrid extends StatelessWidget {
  final EthiopianDate ethMonth;
  final DateTime? selected;
  final int cycleLen, periodLen;
  final DateTime lastPeriod;
  final Map<String, String> symptoms;
  final LanguageProvider lang;
  final Function(DateTime) onTap;
  final VoidCallback onPrev, onNext;
  const _EthiopianGrid({super.key, required this.ethMonth, required this.selected,
      required this.cycleLen, required this.periodLen, required this.lastPeriod,
      required this.symptoms, required this.lang, required this.onTap,
      required this.onPrev, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final daysInMonth = EthiopianCalendar.daysInMonth(
        ethMonth.year, ethMonth.month);
    final firstGreg = EthiopianCalendar.toGregorian(
        EthiopianDate(ethMonth.year, ethMonth.month, 1));
    final offset = firstGreg.weekday % 7;
    final label  = EthiopianCalendar.formatMonthYear(
        ethMonth.year, ethMonth.month, amharic: lang.isAmharic);

    return Column(children: [
      _MonthNav(label,
          lang.s('Ethiopian Calendar', 'የኢትዮጵያ ቀን መቁጠሪያ'),
          onPrev, onNext),
      _DayHeaders(
          lang.isAmharic
              ? EthiopianCalendar.dayNamesAm
              : EthiopianCalendar.dayNamesEn,
          TColors.teal300.withOpacity(0.55)),
      Expanded(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 4),
          itemCount: offset + daysInMonth,
          itemBuilder: (_, i) {
            if (i < offset) return const SizedBox();
            final ethDay = i - offset + 1;
            final greg   = EthiopianCalendar.toGregorian(
                EthiopianDate(ethMonth.year, ethMonth.month, ethDay));
            final diff = greg.difference(lastPeriod).inDays;
            final cd   = diff < 0 ? null : (diff % cycleLen) + 1;
            final ov   = (cycleLen / 2).round();
            final key  = '${greg.year}-${greg.month}-${greg.day}';
            final now  = DateTime.now();
            final isFasting = EthiopianCalendar.isWeeklyFastDay(greg) ||
                EthiopianCalendar.isFilsetaFasting(greg);
            return _DayCell(
              label: '$ethDay',
              subLabel: '${greg.day}',
              isPeriod: cd != null && cd <= periodLen,
              isFertile: cd != null && cd >= ov - 2 && cd <= ov + 1,
              isToday: greg.year == now.year && greg.month == now.month && greg.day == now.day,
              isSelected: selected != null && selected!.year == greg.year &&
                  selected!.month == greg.month && selected!.day == greg.day,
              hasLog: symptoms.containsKey(key),
              isFasting: isFasting,
              useEthFont: true,
              onTap: () => onTap(greg),
            );
          },
        ),
      )),
      // Fasting note
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
        child: Row(children: [
          Container(width: 7, height: 7,
              decoration: const BoxDecoration(
                  color: Color(0xFFF9A825), shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(lang.s('Gold dot = fasting day (Wed/Fri + Filseta)',
              'ወርቃማ ነጥብ = ጾም ቀን (ረቡዕ/ዓርብ + ፍልሰታ)'),
              style: TextStyle(fontSize: 9,
                  color: TColors.white.withOpacity(0.3))),
        ]),
      ),
    ]);
  }
}

// ── SHARED CALENDAR WIDGETS ───────────────────────────────────────

class _MonthNav extends StatelessWidget {
  final String label;
  final String? sub;
  final VoidCallback onPrev, onNext;
  const _MonthNav(this.label, this.sub, this.onPrev, this.onNext);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(children: [
      _GBtn(Icons.chevron_left_rounded, onPrev),
      Expanded(child: Column(children: [
        Text(label, style: const TextStyle(fontSize: 15,
            color: TColors.white, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center),
        if (sub != null)
          Text(sub!, style: TextStyle(fontSize: 9,
              color: TColors.teal300.withOpacity(0.7)),
              textAlign: TextAlign.center),
      ])),
      _GBtn(Icons.chevron_right_rounded, onNext),
    ]),
  );
}

class _DayHeaders extends StatelessWidget {
  final List<String> labels;
  final Color color;
  const _DayHeaders(this.labels, this.color);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
    child: Row(
      children: labels.map((d) => Expanded(child: Center(
        child: Text(d, style: TextStyle(fontSize: 10,
            fontWeight: FontWeight.w700, color: color))))).toList(),
    ),
  );
}

class _DayCell extends StatelessWidget {
  final String label;
  final String? subLabel;
  final bool isPeriod, isFertile, isToday, isSelected, hasLog, isFasting;
  final bool useEthFont;
  final VoidCallback onTap;
  const _DayCell({
    required this.label, this.subLabel,
    required this.isPeriod, required this.isFertile,
    required this.isToday, required this.isSelected,
    required this.hasLog, required this.isFasting,
    this.useEthFont = false, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.transparent;
    Color fg = TColors.white.withOpacity(0.7);
    Color border = Colors.transparent;

    if (isSelected) {
      bg = TColors.pink500.withOpacity(0.8);
      fg = TColors.white;
      border = TColors.pink300;
    } else if (isToday) {
      border = TColors.white.withOpacity(0.55);
      fg = TColors.white;
    } else if (isPeriod) {
      bg = TColors.pink500.withOpacity(0.18);
      fg = TColors.pink300;
    } else if (isFertile) {
      bg = const Color(0xFF4CAF50).withOpacity(0.15);
      fg = const Color(0xFF81C784);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border, width: 1.5)),
        child: Stack(children: [
          Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: TextStyle(
                fontSize: 13,
                fontWeight: isToday || isSelected
                    ? FontWeight.w800 : FontWeight.w500,
                color: fg,
                fontFamily: useEthFont ? 'NotoSansEthiopic' : null)),
              if (subLabel != null)
                Text(subLabel!, style: TextStyle(
                    fontSize: 8, color: fg.withOpacity(0.4))),
            ],
          )),
          // Fasting dot (gold, top-right)
          if (isFasting)
            Positioned(top: 3, right: 4,
                child: Container(width: 4, height: 4,
                    decoration: const BoxDecoration(
                        color: Color(0xFFF9A825), shape: BoxShape.circle))),
          // Log dot (teal, bottom-right)
          if (hasLog)
            Positioned(bottom: 3, right: 4,
                child: Container(width: 4, height: 4,
                    decoration: const BoxDecoration(
                        color: TColors.teal400, shape: BoxShape.circle))),
        ]),
      ),
    );
  }
}

// ── SMALL SHARED WIDGETS ──────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String value, label;
  final Color color;
  const _Chip(this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Expanded(child: ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(value, style: TextStyle(fontSize: 22,
              fontWeight: FontWeight.w800, color: color)),
          Text(label, style: TextStyle(fontSize: 9,
              color: TColors.white.withOpacity(0.45)),
              textAlign: TextAlign.center),
        ]),
      ),
    ),
  ));
}

class _Leg extends StatelessWidget {
  final Color color; final String label;
  const _Leg(this.color, this.label);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 7, height: 7,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 4),
    Text(label, style: TextStyle(fontSize: 10,
        color: TColors.white.withOpacity(0.4))),
  ]);
}

class _GBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  const _GBtn(this.icon, this.onTap, {this.active = false});
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
            color: active
                ? TColors.pink500.withOpacity(0.15)
                : TColors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
                color: active
                    ? TColors.pink500.withOpacity(0.4)
                    : TColors.white.withOpacity(0.10))),
          child: Icon(icon,
              color: active ? TColors.pink300 : TColors.white,
              size: 17)))));
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
