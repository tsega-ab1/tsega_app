import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/stage_provider.dart';
import '../../overlays/quick_log_overlay.dart';

class CycleScreen extends StatefulWidget {
  const CycleScreen({super.key});
  @override
  State<CycleScreen> createState() => _CycleScreenState();
}

class _CycleScreenState extends State<CycleScreen>
    with TickerProviderStateMixin {
  late AnimationController _ringCtrl;
  late Animation<double> _ringAnim;
  bool _calendarView = false;
  DateTime _focusedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _ringAnim = CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut);
    _ringCtrl.forward();
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final stage = context.watch<StageProvider>();

    return Scaffold(
      backgroundColor: TColors.cream,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(gradient: TGradients.gradPink),
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(lang.s('My Cycle', 'ወር አበቤ'),
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.w700,
                              color: TColors.white)),
                      // Toggle calendar / ring
                      GestureDetector(
                        onTap: () => setState(
                            () => _calendarView = !_calendarView),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: TColors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(children: [
                            Icon(
                              _calendarView
                                  ? Icons.donut_large_rounded
                                  : Icons.calendar_month_rounded,
                              color: TColors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              _calendarView
                                  ? lang.s('Ring', 'ቀለበት')
                                  : lang.s('Calendar', 'ቀን መቁጠሪያ'),
                              style: const TextStyle(
                                  color: TColors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // Cycle ring visualizer
                  if (!_calendarView)
                    _CycleRing(animation: _ringAnim, stage: stage, lang: lang)
                  else
                    _CycleCalendar(
                        month: _focusedMonth,
                        stage: stage,
                        lang: lang,
                        onMonthChanged: (m) =>
                            setState(() => _focusedMonth = m)),
                ],
              ),
            ),
          ),

          // Quick stats row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                _StatChip(
                  icon: Icons.water_drop_rounded,
                  label: lang.s('Until period', 'ወር አበባ'),
                  value: '${stage.daysUntilPeriod}',
                  unit: lang.s('days', 'ቀናት'),
                  color: TColors.pink500,
                ),
                const SizedBox(width: 12),
                _StatChip(
                  icon: Icons.favorite_rounded,
                  label: lang.s('Until ovulation', 'ፅንሰ-ሀሳብ'),
                  value: '${stage.daysUntilOvulation}',
                  unit: lang.s('days', 'ቀናት'),
                  color: TColors.teal500,
                ),
                const SizedBox(width: 12),
                _StatChip(
                  icon: Icons.loop_rounded,
                  label: lang.s('Cycle day', 'ዑደት ቀን'),
                  value: '${stage.cycleDay}',
                  unit: '/ 28',
                  color: TColors.blue500,
                ),
              ]),
            ),
          ),

          // Log Today section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _LogTodayCard(lang: lang),
            ),
          ),

          // AI Insights
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _InsightCard(lang: lang, stage: stage),
            ),
          ),

          // Symptoms history chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: _SymptomsHistory(lang: lang),
            ),
          ),
        ],
      ),

      // FAB Log
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const QuickLogOverlay(),
        ),
        backgroundColor: TColors.pink500,
        icon: const Icon(Icons.add_rounded, color: TColors.white),
        label: Text(lang.logToday,
            style: const TextStyle(
                color: TColors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ─── CYCLE RING ──────────────────────────────────────────────────
class _CycleRing extends StatelessWidget {
  final Animation<double> animation;
  final StageProvider stage;
  final LanguageProvider lang;

  const _CycleRing(
      {required this.animation, required this.stage, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, __) => SizedBox(
          width: 220, height: 220,
          child: Stack(alignment: Alignment.center, children: [
            CustomPaint(
              size: const Size(220, 220),
              painter: _RingPainter(
                  progress: animation.value * (stage.cycleDay / 28),
                  fertileStart: 11 / 28,
                  fertileEnd: 17 / 28,
                  periodEnd: 5 / 28),
            ),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text('${stage.cycleDay}',
                  style: const TextStyle(
                      fontSize: 52, fontWeight: FontWeight.w700,
                      color: TColors.white)),
              Text(lang.s('Cycle Day', 'ዑደት ቀን'),
                  style: TextStyle(
                      fontSize: 14,
                      color: TColors.white.withOpacity(0.85))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: TColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  stage.daysUntilOvulation <= 0
                      ? lang.s('Fertile window', 'ፈጠራ መስኮት')
                      : '${stage.daysUntilOvulation} ${lang.s('days to ovulation', 'ቀናት ወደ ፅንሰ-ሀሳብ')}',
                  style: const TextStyle(
                      fontSize: 11,
                      color: TColors.white,
                      fontWeight: FontWeight.w600)),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double fertileStart;
  final double fertileEnd;
  final double periodEnd;

  const _RingPainter({
    required this.progress,
    required this.fertileStart,
    required this.fertileEnd,
    required this.periodEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const stroke = 18.0;

    // Background ring
    canvas.drawCircle(
        center, radius,
        Paint()
          ..color = TColors.white.withOpacity(0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke);

    // Period zone (red arc)
    _drawArc(canvas, center, radius, stroke, 0, periodEnd,
        TColors.red400.withOpacity(0.8));

    // Fertile zone (green arc)
    _drawArc(canvas, center, radius, stroke, fertileStart, fertileEnd,
        TColors.green300.withOpacity(0.9));

    // Progress arc
    _drawArc(canvas, center, radius, stroke, 0, progress, TColors.white);
  }

  void _drawArc(Canvas canvas, Offset center, double radius, double stroke,
      double start, double end, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + start * 2 * math.pi,
      (end - start) * 2 * math.pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ─── CALENDAR VIEW ───────────────────────────────────────────────
class _CycleCalendar extends StatelessWidget {
  final DateTime month;
  final StageProvider stage;
  final LanguageProvider lang;
  final ValueChanged<DateTime> onMonthChanged;

  const _CycleCalendar({
    required this.month, required this.stage,
    required this.lang, required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final monthNames = lang.isAmharic
        ? ['ጃን','ፌብ','ማር','ኤፕ','ሜይ','ጁን','ጁላ','ኦግ','ሴፕ','ኦክ','ኖቭ','ዲሴ']
        : ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

    return Column(children: [
      // Month nav
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => onMonthChanged(
                DateTime(month.year, month.month - 1)),
            icon: const Icon(Icons.chevron_left_rounded,
                color: TColors.white)),
          Text('${monthNames[month.month - 1]} ${month.year}',
              style: const TextStyle(
                  color: TColors.white,
                  fontSize: 16, fontWeight: FontWeight.w700)),
          IconButton(
            onPressed: () => onMonthChanged(
                DateTime(month.year, month.month + 1)),
            icon: const Icon(Icons.chevron_right_rounded,
                color: TColors.white)),
        ],
      ),
      const SizedBox(height: 8),
      // Day headers
      Row(
        children: (lang.isAmharic
            ? ['እሁ','ሰኞ','ማክ','ረቡ','ሐሙ','አር','ቅዳ']
            : ['Su','Mo','Tu','We','Th','Fr','Sa'])
            .map((d) => Expanded(
              child: Center(
                child: Text(d,
                    style: TextStyle(
                        color: TColors.white.withOpacity(0.7),
                        fontSize: 11, fontWeight: FontWeight.w600)))))
            .toList(),
      ),
      const SizedBox(height: 8),
      // Calendar grid
      _buildGrid(),
    ]);
  }

  Widget _buildGrid() {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // 0=Sun

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 4),
      itemCount: startWeekday + daysInMonth,
      itemBuilder: (_, i) {
        if (i < startWeekday) return const SizedBox();
        final day = i - startWeekday + 1;
        final date = DateTime(month.year, month.month, day);
        final isToday = date.day == DateTime.now().day &&
            date.month == DateTime.now().month &&
            date.year == DateTime.now().year;

        // Determine type
        final cycleDay = day % 28;
        final isFertile = cycleDay >= 11 && cycleDay <= 17;
        final isPeriod = cycleDay <= 5;

        Color bg = Colors.transparent;
        Color textColor = TColors.white.withOpacity(0.85);
        if (isFertile) { bg = TColors.green300.withOpacity(0.4); }
        if (isPeriod) { bg = TColors.red400.withOpacity(0.4); }
        if (isToday) { bg = TColors.white; textColor = TColors.pink700; }

        return Container(
          decoration: BoxDecoration(
              color: bg, borderRadius: BorderRadius.circular(8)),
          child: Center(
            child: Text('$day',
                style: TextStyle(
                    color: textColor, fontSize: 12,
                    fontWeight: isToday
                        ? FontWeight.w800 : FontWeight.w400)),
          ),
        );
      },
    );
  }
}

// ─── SUPPORTING WIDGETS ──────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label, value, unit;
  final Color color;

  const _StatChip({
    required this.icon, required this.label,
    required this.value, required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1),
              blurRadius: 8, offset: const Offset(0, 3))
        ],
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(fontSize: 22,
                fontWeight: FontWeight.w800, color: color)),
        Text(unit, style: const TextStyle(
            fontSize: 10, color: TColors.gray)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 9, color: TColors.gray),
            textAlign: TextAlign.center),
      ]),
    ),
  );
}

class _LogTodayCard extends StatelessWidget {
  final LanguageProvider lang;
  const _LogTodayCard({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: TGradients.gradPink,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: TColors.pink500.withOpacity(0.25),
              blurRadius: 16, offset: const Offset(0, 6))
        ],
      ),
      child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.s('How are you feeling today?', 'ዛሬ እንዴት ነዎት?'),
                style: const TextStyle(
                    color: TColors.white,
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(lang.s('Log your symptoms, mood & flow',
                'ምልክቶችዎን ፣ ስሜትዎን እና ፍሰትዎን ይመዝግቡ'),
                style: TextStyle(
                    color: TColors.white.withOpacity(0.85), fontSize: 12)),
          ],
        )),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const QuickLogOverlay(),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: TColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(lang.logToday,
                style: const TextStyle(
                    color: TColors.pink700,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final LanguageProvider lang;
  final StageProvider stage;
  const _InsightCard({required this.lang, required this.stage});

  @override
  Widget build(BuildContext context) {
    final insight = stage.daysUntilOvulation <= 3
        ? lang.s(
            '🌟 Your fertile window is approaching. This is your best time to conceive.',
            '🌟 ፈጠራ መስኮቶ እየቀረበ ነው። ለፅንሰ-ሀሳብ ምርጥ ጊዜ ነው።')
        : stage.daysUntilPeriod <= 3
            ? lang.s(
                '💧 Your period is expected soon. Stay hydrated and rest well.',
                '💧 ወር አበባዎ ቶሎ ይጠበቃል። ብዙ ውሃ ይጠጡ።')
            : lang.s(
                '✨ Your cycle is regular. Keep logging daily for better predictions.',
                '✨ ዑደትዎ መደበኛ ነው። ለተሻለ ትንበያ ዕለት ዕለት ይመዝግቡ።');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TColors.teal100),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.psychology_rounded,
              color: TColors.teal500, size: 20),
          const SizedBox(width: 8),
          Text(lang.s('AI Insight', 'AI ግምት'),
              style: TTextStyles.labelLarge
                  .copyWith(color: TColors.teal700)),
        ]),
        const SizedBox(height: 12),
        Text(insight, style: TTextStyles.bodyLarge.copyWith(height: 1.5)),
      ]),
    );
  }
}

class _SymptomsHistory extends StatelessWidget {
  final LanguageProvider lang;
  const _SymptomsHistory({required this.lang});

  final _recentSymptoms = const [
    ('Cramps', 'ቁርጠት', TColors.red400),
    ('Bloating', 'ነፍጠት', TColors.pink300),
    ('Mood swing', 'ስሜት ለውጥ', TColors.blue300),
    ('Fatigue', 'ድካም', TColors.gray),
    ('Headache', 'ራስ ምታት', TColors.mid),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(lang.s('Recent Symptoms', 'የቅርብ ምልክቶች'),
          style: TTextStyles.headlineSmall),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8, runSpacing: 8,
        children: _recentSymptoms.map((s) => Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: s.$3.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: s.$3.withOpacity(0.3)),
          ),
          child: Text(lang.isAmharic ? s.$2 : s.$1,
              style: TextStyle(
                  color: s.$3,
                  fontSize: 13, fontWeight: FontWeight.w600)),
        )).toList(),
      ),
    ]);
  }
}
