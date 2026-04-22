import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/partner_provider.dart';

class PartnerDangerOverlay extends StatelessWidget {
  const PartnerDangerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final lang    = context.watch<LanguageProvider>();
    final partner = context.read<PartnerProvider>();
    final name    = partner.healthView?.womanName ?? 'her';

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A0A0A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4,
            decoration: BoxDecoration(
                color: TColors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 24),

        // Alert icon
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: TColors.red400.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: TColors.red400.withOpacity(0.5), width: 2)),
          child: const Icon(Icons.warning_amber_rounded,
              color: TColors.red400, size: 40)),
        const SizedBox(height: 16),

        Text(lang.s('DANGER ALERT', 'የአደጋ ማስጠንቀቂያ'),
            style: const TextStyle(fontSize: 13, color: TColors.red400,
                fontWeight: FontWeight.w800, letterSpacing: 2)),
        const SizedBox(height: 8),
        Text(lang.s(
            '$name reported danger signs',
            '$name የአደጋ ምልክቶችን ዘግቧል'),
            style: const TextStyle(fontSize: 22,
                color: TColors.white, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center),
        const SizedBox(height: 20),

        // Action buttons
        GestureDetector(
          onTap: () {},
          child: Container(
            width: double.infinity, height: 56,
            decoration: BoxDecoration(
              color: TColors.red400,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(
                color: TColors.red400.withOpacity(0.4),
                blurRadius: 20, offset: const Offset(0, 8))]),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.phone_rounded, color: TColors.white, size: 22),
              const SizedBox(width: 10),
              Text(lang.s('Call 907 — Ambulance', '907 ደውሉ — አምቡላንስ'),
                  style: const TextStyle(color: TColors.white,
                      fontSize: 16, fontWeight: FontWeight.w800)),
            ])),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: double.infinity, height: 50,
            decoration: BoxDecoration(
              color: TColors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: TColors.white.withOpacity(0.15))),
            child: Center(child: Text(
              lang.s('Find Nearest Hospital', 'ቅርብ ሆስፒታል ያግኙ'),
              style: const TextStyle(color: TColors.white,
                  fontSize: 15, fontWeight: FontWeight.w600)))),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            partner.dismissDangerAlert();
            Navigator.pop(context);
          },
          child: Container(
            width: double.infinity, height: 48,
            decoration: BoxDecoration(
              color: TColors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(
              lang.s('I have handled this', 'ተወው — ተፈቷል'),
              style: TextStyle(color: TColors.white.withOpacity(0.5),
                  fontSize: 14)))),
        ),
        const SizedBox(height: 8),
      ]),
    );
  }
}
