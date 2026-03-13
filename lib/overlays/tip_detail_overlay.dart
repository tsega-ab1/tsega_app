import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';

class TipDetailOverlay extends StatelessWidget {
  final String titleEn, titleAm, bodyEn, bodyAm;
  const TipDetailOverlay({
    super.key,
    required this.titleEn, required this.titleAm,
    required this.bodyEn, required this.bodyAm,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Container(
      decoration: const BoxDecoration(
        color: TColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4,
            decoration: BoxDecoration(
                color: TColors.border,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: TGradients.gradTeal,
            borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: TColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.lightbulb_rounded,
                  color: TColors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(
              lang.isAmharic ? titleAm : titleEn,
              style: const TextStyle(fontSize: 18,
                  color: TColors.white, fontWeight: FontWeight.w700),
            )),
          ]),
        ),
        const SizedBox(height: 20),
        Text(lang.isAmharic ? bodyAm : bodyEn,
            style: const TextStyle(fontSize: 15,
                color: TColors.mid, height: 1.7)),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: TGradients.gradTeal,
              borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(lang.s('Go to Learning Hub', 'ወደ ትምህርት ማዕከል'),
                style: const TextStyle(color: TColors.white,
                    fontWeight: FontWeight.w700))),
          ),
        ),
        const SizedBox(height: 8),
      ]),
    );
  }
}
