import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/gradients.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/stage_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../overlays/quick_log_overlay.dart';

class PregnancyDashboard extends StatelessWidget {
  const PregnancyDashboard({super.key});

  String _getBabySize(int week) {
    final sizes = AppConstants.babySizes;
    int closest = sizes.keys.reduce(
        (a, b) => (a - week).abs() < (b - week).abs() ? a : b);
    return sizes[closest] ?? 'a lime';
  }

  @override
  Widget build(BuildContext context) {
    final stage = context.watch<StageProvider>();
    final lang = context.watch<LanguageProvider>();
    final week = stage.pregnancyWeek;
    final babySize = _getBabySize(week);
    final due = stage.dueDate;

    return Container(
      decoration: BoxDecoration(
        gradient: TGradients.gradTeal,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(
            color: TColors.teal700.withOpacity(0.3),
            blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(children: [
        // Week header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(lang.pregnancyWeek,
                  style: TextStyle(
                      color: TColors.white.withOpacity(0.8), fontSize: 13)),
              Text('$week',
                  style: const TextStyle(fontSize: 56,
                      color: TColors.white,
                      fontWeight: FontWeight.w700, height: 1)),
            ]),
            const Spacer(),
            // Due date countdown
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(lang.dueDate,
                  style: TextStyle(
                      color: TColors.white.withOpacity(0.8), fontSize: 13)),
              Text('${stage.daysToGo}',
                  style: const TextStyle(fontSize: 32,
                      color: TColors.white,
                      fontWeight: FontWeight.w700)),
              Text(lang.daysToGo,
                  style: TextStyle(
                      color: TColors.white.withOpacity(0.8), fontSize: 12)),
            ]),
          ]),
        ),

        // Baby size
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TColors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            const Icon(Icons.child_friendly_rounded,
                color: TColors.white, size: 32),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(lang.babySize,
                  style: TextStyle(
                      color: TColors.white.withOpacity(0.8), fontSize: 12)),
              Text(babySize,
                  style: const TextStyle(color: TColors.white,
                      fontWeight: FontWeight.w700, fontSize: 18)),
            ]),
          ]),
        ),

        // Action buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Row(children: [
            Expanded(child: _PregAction(
              icon: Icons.touch_app_rounded,
              label: lang.kickCounter,
              onTap: () {},
            )),
            const SizedBox(width: 12),
            Expanded(child: _PregAction(
              icon: Icons.timeline_rounded,
              label: lang.weekByWeek,
              onTap: () {},
            )),
            const SizedBox(width: 12),
            Expanded(child: _PregAction(
              icon: Icons.edit_note_rounded,
              label: lang.logSymptoms,
              onTap: () => showQuickLogOverlay(context),
            )),
          ]),
        ),
      ]),
    );
  }
}

class _PregAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PregAction({
    required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: TColors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: TColors.white, size: 24),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(
            color: TColors.white, fontSize: 11,
            fontWeight: FontWeight.w600),
            textAlign: TextAlign.center),
      ]),
    ),
  );
}
