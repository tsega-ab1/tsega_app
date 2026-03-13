import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../core/theme/colors.dart';
import '../../../core/theme/gradients.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/stage_provider.dart';
import '../../../overlays/quick_log_overlay.dart';

class PeriodDashboard extends StatelessWidget {
  const PeriodDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final stage = context.watch<StageProvider>();
    final lang = context.watch<LanguageProvider>();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: TGradients.gradPink,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(
            color: TColors.pink500.withOpacity(0.3),
            blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(children: [
        // Circular cycle visualizer
        _CycleVisualizer(
          daysUntilPeriod: stage.daysUntilPeriod,
          daysUntilOvulation: stage.daysUntilOvulation,
          cycleDay: stage.cycleDay,
          isAmharic: lang.isAmharic,
        ),
        const SizedBox(height: 24),
        // Action buttons
        Row(children: [
          Expanded(
            child: _DashboardAction(
              icon: Icons.edit_rounded,
              label: lang.logToday,
              onTap: () => showQuickLogOverlay(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DashboardAction(
              icon: Icons.calendar_month_rounded,
              label: lang.s('Calendar', 'ቀን መቁጠሪያ'),
              onTap: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DashboardAction(
              icon: Icons.psychology_rounded,
              label: lang.s('Insights', 'ትንታኔ'),
              onTap: () {},
            ),
          ),
        ]),
      ]),
    );
  }
}

class _CycleVisualizer extends StatefulWidget {
  final int daysUntilPeriod;
  final int daysUntilOvulation;
  final int cycleDay;
  final bool isAmharic;

  const _CycleVisualizer({
    required this.daysUntilPeriod,
    required this.daysUntilOvulation,
    required this.cycleDay,
    required this.isAmharic,
  });

  @override
  State<_CycleVisualizer> createState() => _CycleVisualizerState();
}

class _CycleVisualizerState extends State<_CycleVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => SizedBox(
        width: 200, height: 200,
        child: CustomPaint(
          painter: _CyclePainter(
            progress: _anim.value,
            cycleDay: widget.cycleDay,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${widget.daysUntilPeriod}',
                    style: const TextStyle(
                        fontSize: 48, fontWeight: FontWeight.w700,
                        color: TColors.white)),
                Text(widget.isAmharic
                    ? 'ቀናት ቀርተዋል'
                    : 'days until\nperiod',
                    style: TextStyle(fontSize: 12,
                        color: TColors.white.withOpacity(0.85)),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CyclePainter extends CustomPainter {
  final double progress;
  final int cycleDay;

  _CyclePainter({required this.progress, required this.cycleDay});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    // Background ring
    final bgPaint = Paint()
      ..color = TColors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = TColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final sweep = (cycleDay / 28) * 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CyclePainter old) =>
      old.progress != progress || old.cycleDay != cycleDay;
}

class _DashboardAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DashboardAction({
    required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: TColors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: TColors.white, size: 22),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(
            color: TColors.white, fontSize: 11,
            fontWeight: FontWeight.w600),
            textAlign: TextAlign.center),
      ]),
    ),
  );
}
