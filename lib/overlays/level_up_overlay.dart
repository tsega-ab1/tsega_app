import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/providers/language_provider.dart';
import '../../models/gamification_model.dart';
import '../../widgets/animations/pulse_animation.dart';

class LevelUpOverlay extends StatefulWidget {
  final TsegaLevel level;
  const LevelUpOverlay({super.key, required this.level});
  @override
  State<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<LevelUpOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
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
        color: Color(0xFF0E1320),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4,
            decoration: BoxDecoration(
                color: TColors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 32),
        FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: PulseWidget(child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                gradient: widget.level.gradient,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(
                  color: widget.level.gradient.colors.first.withOpacity(0.4),
                  blurRadius: 40, spreadRadius: 8)]),
              child: Icon(widget.level.icon,
                  color: TColors.white, size: 56))),
          ),
        ),
        const SizedBox(height: 24),
        Text(lang.s('Level Up! 🎉', 'ደረጃ ወጡ! 🎉'),
            style: const TextStyle(fontSize: 14,
                color: TColors.teal300, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(lang.isAmharic
            ? widget.level.nameAm
            : widget.level.nameEn,
            style: const TextStyle(fontSize: 28,
                color: TColors.white, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(lang.s('Level ${widget.level.level}',
            'ደረጃ ${widget.level.level}'),
            style: TextStyle(fontSize: 14,
                color: TColors.white.withOpacity(0.5))),
        const SizedBox(height: 20),
        Text(lang.s('Unlocked:', 'ተከፍቷል:'),
            style: TextStyle(fontSize: 12,
                color: TColors.white.withOpacity(0.4),
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        ...List.generate(widget.level.unlocksEn.length, (i) =>
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: widget.level.gradient.colors.first.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: widget.level.gradient.colors.first.withOpacity(0.3))),
              child: Row(children: [
                const Icon(Icons.check_circle_rounded,
                    color: TColors.green500, size: 16),
                const SizedBox(width: 8),
                Text(
                  lang.isAmharic
                      ? widget.level.unlocksAm[i]
                      : widget.level.unlocksEn[i],
                  style: const TextStyle(
                      fontSize: 14, color: TColors.white)),
              ]),
            )),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity, height: 50,
            decoration: BoxDecoration(
              gradient: widget.level.gradient,
              borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(
              lang.s('Awesome! Keep going 🚀', 'አስደናቂ! ቀጥሉ 🚀'),
              style: const TextStyle(color: TColors.white,
                  fontWeight: FontWeight.w700, fontSize: 16)))),
        ),
        const SizedBox(height: 8),
      ]),
    );
  }
}
