import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/ethiopian_calendar.dart';

// ════════════════════════════════════════════════════════════════
// HORMONE CHART OVERLAY
// Shown when user taps any day on the cycle calendar
// Shows estrogen / LH / progesterone / FSH curves
// First tap on legend chip → explains that hormone
// ════════════════════════════════════════════════════════════════

class HormoneChartOverlay extends StatefulWidget {
  final int cycleDay;
  final int cycleLength;
  final DateTime selectedDate;
  final bool isAmharic;
  final String? symptoms;
  final String? flow;

  const HormoneChartOverlay({
    super.key,
    required this.cycleDay,
    required this.cycleLength,
    required this.selectedDate,
    required this.isAmharic,
    this.symptoms,
    this.flow,
  });

  @override
  State<HormoneChartOverlay> createState() => _HormoneChartOverlayState();
}

class _HormoneChartOverlayState extends State<HormoneChartOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _draw;
  int? _selected; // which hormone chip is tapped

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _draw = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  // ── HORMONE CURVES (normalized 0-1 over cycle) ────────────────
  List<double> _estrogen(int len) => List.generate(len, (i) {
    final t = i / (len - 1);
    return (exp(-pow((t - 0.45) * 5, 2)) * 0.85 +
            exp(-pow((t - 0.75) * 6, 2)) * 0.45).clamp(0.05, 1.0);
  });

  List<double> _lh(int len) => List.generate(len, (i) {
    final t = i / (len - 1);
    return (exp(-pow((t - 0.46) * 12, 2)) * 0.95 + 0.05).clamp(0.0, 1.0);
  });

  List<double> _progesterone(int len) => List.generate(len, (i) {
    final t = i / (len - 1);
    if (t < 0.5) return 0.05;
    return (exp(-pow((t - 0.75) * 4.5, 2)) * 0.9 + 0.05).clamp(0.0, 1.0);
  });

  List<double> _fsh(int len) => List.generate(len, (i) {
    final t = i / (len - 1);
    return (exp(-pow((t - 0.1) * 6, 2)) * 0.6 +
            exp(-pow((t - 0.44) * 14, 2)) * 0.5 + 0.05).clamp(0.0, 1.0);
  });

  // ── PHASE LOGIC ───────────────────────────────────────────────
  String _phase(int d, int l) {
    final ov = (l / 2).round();
    if (widget.isAmharic) {
      if (d <= 5) return 'የወር አበባ ደረጃ';
      if (d < ov - 1) return 'የፎሊኩለር ደረጃ';
      if (d <= ov + 1) return 'ኦቭዩሌሽን';
      if (d <= ov + 12) return 'የሉቲያል ደረጃ';
      return 'ዘግይቶ የሉቲያል ደረጃ';
    } else {
      if (d <= 5) return 'Menstrual Phase';
      if (d < ov - 1) return 'Follicular Phase';
      if (d <= ov + 1) return 'Ovulation';
      if (d <= ov + 12) return 'Luteal Phase';
      return 'Late Luteal Phase';
    }
  }

  String _phaseDesc(int d, int l) {
    final ov = (l / 2).round();
    if (widget.isAmharic) {
      if (d <= 5) return 'ኢስትሮጅን እና ፕሮጀስቴሮን ዝቅ ያሉ ናቸው። የማህፀን ሽፋን ይወድቃል። ድካም እና ቁርጠት ሊሰማ ይችላል።';
      if (d < ov - 1) return 'ፎሊኮሎች ሲያድጉ ኢስትሮጅን ይጨምራል። ኃይሎ ደረጃ ብዙ ጊዜ ይጨምራል። ፈሩ መስኮት እየቀረበ ነው።';
      if (d <= ov + 1) return 'LH ይወጣል — ኦቭዩሌሽን እየሆነ ነው። እጅግ ፈሩ ቀናት። እንቁላል ይለቀቃል።';
      if (d <= ov + 12) return 'ፕሮጀስቴሮን ሊሆን ይችላልን ፅንስ ለመደገፍ ይጨምራል። ሙቀት ሊሰማ ይችላል።';
      return 'ሆርሞን ደረጃዎች ይወርዳሉ። ወር አበባ በ1-3 ቀናት ውስጥ።';
    } else {
      if (d <= 5) return 'Estrogen and progesterone are low. Uterine lining sheds. Fatigue and cramping are common.';
      if (d < ov - 1) return 'Estrogen rises as follicles develop. Energy often improves. Fertile window is approaching.';
      if (d <= ov + 1) return 'LH is surging — ovulation is happening or very close. Your most fertile days.';
      if (d <= ov + 12) return 'Progesterone rises to support potential implantation. You may feel warmer.';
      return 'Hormone levels drop if no pregnancy. Period approaching in 1–3 days.';
    }
  }

  Color _phaseColor(int d, int l) {
    final ov = (l / 2).round();
    if (d <= 5) return TColors.pink500;
    if (d < ov - 1) return TColors.teal500;
    if (d <= ov + 1) return const Color(0xFF4CAF50);
    return TColors.blue500;
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.cycleDay;
    final l = widget.cycleLength;
    final am = widget.isAmharic;
    final pColor = _phaseColor(d, l);

    final hormones = [
      _H('Estrogen', 'ኢስትሮጅን',
          'Builds uterine lining, boosts mood, drives follicle growth.',
          'የማህፀን ሽፋን ይገነባል፣ ስሜትን ያሻሽላል።',
          TColors.pink500, _estrogen(l), Icons.water_drop_rounded),
      _H('LH', 'LH',
          'Triggers ovulation when it surges around mid-cycle.',
          'ሲወጣ ኦቭዩሌሽን ያስነሳል።',
          const Color(0xFF4CAF50), _lh(l), Icons.flash_on_rounded),
      _H('Progesterone', 'ፕሮጀስቴሮን',
          'Supports pregnancy or triggers period if no fertilization.',
          'እርግዝናን ይደግፋል ወይም ወር አበባን ያስከትላል።',
          TColors.blue500, _progesterone(l), Icons.favorite_rounded),
      _H('FSH', 'FSH',
          'Stimulates follicle development and egg maturation.',
          'የፎሊኮሎች እና እንቁላል እድገትን ያነሳሳል።',
          const Color(0xFFF9A825), _fsh(l), Icons.bubble_chart_rounded),
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFF0E1320),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
        // Handle
        Padding(padding: const EdgeInsets.only(top: 12),
          child: Container(width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(2)))),

        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(am ? 'ቀን $d / $l' : 'Day $d of $l',
                style: TextStyle(fontSize: 12,
                    color: Colors.white.withOpacity(0.45))),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: pColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: pColor.withOpacity(0.4))),
                child: Text(_phase(d, l),
                  style: TextStyle(fontSize: 13,
                      color: pColor, fontWeight: FontWeight.w700))),
            ]),
            const Spacer(),
            Text(
              '${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}',
              style: TextStyle(fontSize: 12,
                  color: Colors.white.withOpacity(0.35))),
          ]),
        ),

        const SizedBox(height: 10),

        // Chart
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: AnimatedBuilder(
            animation: _draw,
            builder: (_, __) => SizedBox(
              height: 160,
              child: CustomPaint(
                size: const Size(double.infinity, 160),
                painter: _ChartPainter(
                  hormones: hormones,
                  currentDay: d,
                  cycleLength: l,
                  progress: _draw.value,
                  tapped: _selected,
                ),
              ),
            ),
          ),
        ),

        // Hormone chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(hormones.length, (i) {
              final h = hormones[i];
              final on = _selected == i;
              return GestureDetector(
                onTap: () => setState(() => _selected = on ? null : i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: on
                        ? h.color.withOpacity(0.18)
                        : Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: on
                          ? h.color.withOpacity(0.6)
                          : Colors.white.withOpacity(0.08))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 7, height: 7,
                      decoration: BoxDecoration(
                          color: h.color, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text(am ? h.nameAm : h.nameEn,
                      style: TextStyle(fontSize: 11,
                        color: on
                            ? h.color
                            : Colors.white.withOpacity(0.5),
                        fontWeight: on
                            ? FontWeight.w700 : FontWeight.w400)),
                  ]),
                ),
              );
            }),
          ),
        ),

        // Hormone detail card
        if (_selected != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: ClipRRect(
                key: ValueKey(_selected),
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: hormones[_selected!].color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: hormones[_selected!].color.withOpacity(0.25))),
                    child: Row(children: [
                      Icon(hormones[_selected!].icon,
                          color: hormones[_selected!].color, size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text(
                        am ? hormones[_selected!].descAm : hormones[_selected!].descEn,
                        style: TextStyle(fontSize: 12,
                            height: 1.5,
                            color: Colors.white.withOpacity(0.75)))),
                    ]),
                  ),
                ),
              ),
            ),
          ),

        const Divider(color: Colors.white10, height: 1),

        // Phase description + extras
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(am ? 'ለእርስዎ ምን ማለት ነው' : 'What this means for you',
                style: TextStyle(fontSize: 11,
                    color: Colors.white.withOpacity(0.4),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Text(_phaseDesc(d, l),
                style: TextStyle(fontSize: 14, height: 1.65,
                    color: Colors.white.withOpacity(0.8))),

              // Symptoms logged
              if (widget.symptoms?.isNotEmpty == true) ...[
                const SizedBox(height: 14),
                _InfoTile(
                  icon: Icons.edit_note_rounded,
                  iconColor: TColors.teal400,
                  label: am ? 'የምዘግቡት:' : 'You logged:',
                  value: widget.symptoms!),
              ],

              // Flow logged
              if (widget.flow?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                _InfoTile(
                  icon: Icons.water_drop_rounded,
                  iconColor: TColors.pink300,
                  label: am ? 'ፍሰት:' : 'Flow:',
                  value: widget.flow!,
                  tint: TColors.pink500),
              ],

              // Fasting notice
              if (EthiopianCalendar.isWeeklyFastDay(widget.selectedDate)) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9A825).withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFFF9A825).withOpacity(0.2))),
                  child: Row(children: [
                    const Text('🕊️', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(
                      am
                          ? 'ጾም ቀን — በቂ ውሃ ይጠጡ። ምስር፣ ጎመን እና ሽምብራ ያሉ ብረት ያለቸው ቪጋን ምግቦችን ይ召ቡ።'
                          : 'Fasting day — stay hydrated. Eat iron-rich vegan foods like lentils, gomen, and chickpeas.',
                      style: TextStyle(fontSize: 12, height: 1.5,
                          color: const Color(0xFFF9A825).withOpacity(0.8)))),
                  ]),
                ),
              ],

              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: TColors.teal500.withOpacity(0.3))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.menu_book_rounded,
                          color: TColors.teal400, size: 16),
                      const SizedBox(width: 8),
                      Text(am
                          ? 'ስለ ዑደትዎ ተጨማሪ ይወቁ →'
                          : 'Learn more about your cycle →',
                        style: const TextStyle(fontSize: 13,
                            color: TColors.teal300,
                            fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )),
      ]),
    );
  }
}

// ── DATA MODEL ────────────────────────────────────────────────────
class _H {
  final String nameEn, nameAm, descEn, descAm;
  final Color color;
  final List<double> values;
  final IconData icon;
  const _H(this.nameEn, this.nameAm, this.descEn, this.descAm,
      this.color, this.values, this.icon);
}

// ── INFO TILE ─────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label, value;
  final Color tint;
  const _InfoTile({
    required this.icon, required this.iconColor,
    required this.label, required this.value,
    this.tint = TColors.teal500,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: tint.withOpacity(0.07),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: tint.withOpacity(0.15))),
    child: Row(children: [
      Icon(icon, color: iconColor, size: 17),
      const SizedBox(width: 9),
      Expanded(child: RichText(text: TextSpan(children: [
        TextSpan(text: '$label ',
          style: TextStyle(fontSize: 11,
              color: iconColor, fontWeight: FontWeight.w600)),
        TextSpan(text: value,
          style: TextStyle(fontSize: 13,
              color: Colors.white.withOpacity(0.7))),
      ]))),
    ]),
  );
}

// ── CHART PAINTER ─────────────────────────────────────────────────
class _ChartPainter extends CustomPainter {
  final List<_H> hormones;
  final int currentDay, cycleLength;
  final double progress;
  final int? tapped;

  const _ChartPainter({
    required this.hormones, required this.currentDay,
    required this.cycleLength, required this.progress, this.tapped,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double pL = 20, pR = 10, pT = 10, pB = 22;
    final double cW = size.width - pL - pR;
    final double cH = size.height - pT - pB;

    // Grid
    final gp = Paint()..color = Colors.white.withOpacity(0.06)..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = pT + cH * (1 - i / 4);
      canvas.drawLine(Offset(pL, y), Offset(pL + cW, y), gp);
    }

    // Curves
    for (int h = 0; h < hormones.length; h++) {
      final ho = hormones[h];
      final dimmed = tapped != null && tapped != h;
      final bright = tapped == h;
      final paint = Paint()
        ..color = ho.color.withOpacity(dimmed ? 0.12 : bright ? 1.0 : 0.75)
        ..strokeWidth = bright ? 2.5 : 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      final pts = (cycleLength * progress).round();
      for (int i = 0; i < pts; i++) {
        final x = pL + (i / (cycleLength - 1)) * cW;
        final y = pT + cH * (1 - ho.values[i]);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          final px = pL + ((i - 1) / (cycleLength - 1)) * cW;
          final py = pT + cH * (1 - ho.values[i - 1]);
          final cx = (px + x) / 2;
          path.cubicTo(cx, py, cx, y, x, y);
        }
      }
      canvas.drawPath(path, paint);
    }

    // Current day line
    final dx = pL + ((currentDay - 1) / (cycleLength - 1)) * cW;
    canvas.drawLine(
      Offset(dx, pT), Offset(dx, pT + cH),
      Paint()..color = Colors.white.withOpacity(0.35)..strokeWidth = 1.5);

    // Dots on curves at current day
    for (int h = 0; h < hormones.length; h++) {
      if (currentDay - 1 < hormones[h].values.length) {
        final val = hormones[h].values[currentDay - 1];
        final dy = pT + cH * (1 - val);
        final dimmed = tapped != null && tapped != h;
        canvas.drawCircle(
          Offset(dx, dy),
          tapped == h ? 6 : 4,
          Paint()..color = hormones[h].color.withOpacity(dimmed ? 0.12 : 1.0));
        if (!dimmed) {
          canvas.drawCircle(Offset(dx, dy), 2,
              Paint()..color = Colors.white);
        }
      }
    }

    // X labels
    final ts = TextStyle(color: Colors.white.withOpacity(0.3),
        fontSize: 9);
    for (final d in [1, 7, 14, 21, cycleLength]) {
      final x = pL + ((d - 1) / (cycleLength - 1)) * cW;
      final tp = TextPainter(
        text: TextSpan(text: '$d', style: ts),
        textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - pB + 5));
    }
  }

  @override
  bool shouldRepaint(_ChartPainter o) =>
      o.progress != progress || o.tapped != tapped || o.currentDay != currentDay;
}
