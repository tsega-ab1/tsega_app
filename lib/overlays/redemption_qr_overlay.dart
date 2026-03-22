import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';

class RedemptionQrOverlay extends StatelessWidget {
  final int coins;
  const RedemptionQrOverlay({super.key, required this.coins});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    // In production: generate QR encoding
    // tsega.app/redeem?uid=USER_ID&tc=COINS&exp=TIMESTAMP&sig=HMAC
    // Refresh every 24 hours — prevents screenshot sharing

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0E1320),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4,
            decoration: BoxDecoration(
                color: TColors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Text(lang.s('Your Reward QR', 'የሽልማት QR'),
            style: const TextStyle(fontSize: 20,
                color: TColors.white, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(lang.s('Show this to partner locations to redeem discounts',
            'ቅናሽ ለማግኘት ለሸሪካ ቦታዎች ይህን አሳይ'),
            style: TextStyle(fontSize: 12,
                color: TColors.white.withOpacity(0.5)),
            textAlign: TextAlign.center),
        const SizedBox(height: 24),

        // QR placeholder (replace with qr_flutter package in production)
        Container(
          width: 200, height: 200,
          decoration: BoxDecoration(
            color: TColors.white,
            borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.qr_code_2_rounded,
                  color: TColors.dark, size: 120),
              Text('$coins TC', style: const TextStyle(
                  fontSize: 13, color: TColors.dark,
                  fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Balance
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              TColors.teal700.withOpacity(0.2),
              TColors.blue700.withOpacity(0.15),
            ]),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TColors.teal400.withOpacity(0.3))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.token_rounded,
                  color: TColors.teal300, size: 20),
              const SizedBox(width: 8),
              Text(lang.s('Balance: $coins Tsega Coins',
                  'ቀሪ: $coins ጸጋ ሳንቲሞች'),
                  style: const TextStyle(fontSize: 15,
                      color: TColors.white, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // How it works
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: TColors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            _HowRow(lang.s(
                '1. Show QR at partner pharmacy or clinic',
                '1. ለሸሪካ ፋርማሲ ወይም ክሊኒክ QR አሳይ'), lang),
            _HowRow(lang.s(
                '2. Staff scans with their phone camera',
                '2. ሰራተኛ በስልካቸው ካሜራ ቃኙ'), lang),
            _HowRow(lang.s(
                '3. Discount applied at checkout',
                '3. ቅናሽ ሲከፍሉ ተተግብሯል'), lang),
          ]),
        ),
        const SizedBox(height: 8),
        Text(lang.s('QR refreshes every 24 hours for security',
            'QR ለደህንነት በ24 ሰዓት ይታደሳል'),
            style: TextStyle(fontSize: 10,
                color: TColors.white.withOpacity(0.3))),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity, height: 48,
            decoration: BoxDecoration(
              color: TColors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: TColors.white.withOpacity(0.1))),
            child: Center(child: Text(lang.close,
                style: const TextStyle(
                    color: TColors.white, fontWeight: FontWeight.w600)))),
        ),
        const SizedBox(height: 8),
      ]),
    );
  }
}

class _HowRow extends StatelessWidget {
  final String text;
  final LanguageProvider lang;
  const _HowRow(this.text, this.lang);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      const Icon(Icons.arrow_right_rounded,
          color: TColors.teal400, size: 18),
      const SizedBox(width: 6),
      Expanded(child: Text(text,
          style: TextStyle(fontSize: 12,
              color: TColors.white.withOpacity(0.6)))),
    ]),
  );
}
