import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';
import '../../widgets/animations/pulse_animation.dart';

class BadgeUnlockOverlay extends StatefulWidget {
  final String badgeNameEn, badgeNameAm, badgeDescEn, badgeDescAm;
  final IconData icon;
  final LinearGradient gradient;
  const BadgeUnlockOverlay({
    super.key,
    required this.badgeNameEn, required this.badgeNameAm,
    required this.badgeDescEn, required this.badgeDescAm,
    required this.icon, required this.gradient,
  });
  @override
  State<BadgeUnlockOverlay> createState() => _BadgeUnlockOverlayState();
}

class _BadgeUnlockOverlayState extends State<BadgeUnlockOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _scale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Container(
      decoration: const BoxDecoration(
        color: TColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4,
            decoration: BoxDecoration(color: TColors.border,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 32),
        FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: PulseWidget(
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  gradient: widget.gradient,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                    color: TColors.teal700.withOpacity(0.3),
                    blurRadius: 30, spreadRadius: 5)]),
                child: Icon(widget.icon, color: TColors.white, size: 56),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(lang.s('🎉 Badge Earned!', '🎉 ሽልማት አገኙ!'),
            style: const TextStyle(fontSize: 14,
                color: TColors.teal500, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(lang.isAmharic ? widget.badgeNameAm : widget.badgeNameEn,
            style: const TextStyle(fontSize: 26,
                fontWeight: FontWeight.w800, color: TColors.dark),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(lang.isAmharic ? widget.badgeDescAm : widget.badgeDescEn,
            style: const TextStyle(fontSize: 14,
                color: TColors.gray, height: 1.5),
            textAlign: TextAlign.center),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(
              lang.s('Awesome! Keep Learning 🚀',
                  'አስደናቂ! መማርን ቀጥሉ 🚀'),
              style: const TextStyle(color: TColors.white,
                  fontWeight: FontWeight.w700, fontSize: 16))),
          ),
        ),
        const SizedBox(height: 8),
      ]),
    );
  }
}
