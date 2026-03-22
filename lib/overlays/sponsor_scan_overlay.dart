import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/xp_provider.dart';
import '../../models/gamification_model.dart';

class SponsorScanOverlay extends StatefulWidget {
  const SponsorScanOverlay({super.key});
  @override
  State<SponsorScanOverlay> createState() => _SponsorScanOverlayState();
}

class _SponsorScanOverlayState extends State<SponsorScanOverlay> {
  bool _scanning = false;
  bool _scanned = false;
  String? _sponsorName;
  int _earnedXp = 0;

  void _simulateScan() async {
    setState(() => _scanning = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _scanning = false;
      _scanned = true;
      _sponsorName = 'Kenema Pharmacy';
      _earnedXp = 50;
    });
    context.read<XpProvider>().addXp(
        XpEvent.sponsorQrScanned, customXp: _earnedXp);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF0E1320),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: _scanned ? _SuccessView(
        sponsorName: _sponsorName!,
        xp: _earnedXp,
        lang: lang,
        onClose: () => Navigator.pop(context),
      ) : Column(children: [
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Container(width: 40, height: 4,
              decoration: BoxDecoration(
                  color: TColors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2)))),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(children: [
            const Icon(Icons.qr_code_scanner_rounded,
                color: TColors.teal400, size: 24),
            const SizedBox(width: 12),
            Text(lang.s('Scan & Earn', 'ቃኝ እና አግኝ'),
                style: const TextStyle(fontSize: 18,
                    color: TColors.white, fontWeight: FontWeight.w700)),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.close_rounded,
                  color: TColors.white.withOpacity(0.4))),
          ]),
        ),
        Expanded(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Camera viewfinder mockup
            Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                border: Border.all(
                    color: TColors.teal400.withOpacity(0.6), width: 2),
                borderRadius: BorderRadius.circular(16)),
              child: Stack(children: [
                // Corner brackets
                ..._corners(TColors.teal400),
                Center(child: _scanning
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                              color: TColors.teal400, strokeWidth: 2),
                          const SizedBox(height: 12),
                          Text(lang.s('Scanning...', 'እየቃኘ...'),
                              style: const TextStyle(
                                  color: TColors.teal300, fontSize: 13)),
                        ])
                    : Icon(Icons.qr_code_scanner_rounded,
                        color: TColors.teal400.withOpacity(0.3), size: 80)),
              ]),
            ),
            const SizedBox(height: 24),
            Text(lang.s(
                'Point camera at a Tsega partner QR code',
                'ካሜራዎን ወደ ጸጋ ሸሪካ QR ኮድ ያቅናሉ'),
                style: TextStyle(fontSize: 14,
                    color: TColors.white.withOpacity(0.6)),
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(lang.s(
                'Earn 20–100 XP per scan at partner locations',
                'በሸሪካ ቦታዎች በእያንዳንዱ ቅኝ 20-100 XP ያግኙ'),
                style: TextStyle(fontSize: 12,
                    color: TColors.teal300.withOpacity(0.7)),
                textAlign: TextAlign.center),
            const SizedBox(height: 32),
            // Simulate scan button (replace with real camera in production)
            GestureDetector(
              onTap: _scanning ? null : _simulateScan,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  gradient: TGradients.gradTeal,
                  borderRadius: BorderRadius.circular(14)),
                child: Text(lang.s('Simulate Scan', 'ቅኝ አስመስል'),
                    style: const TextStyle(color: TColors.white,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 8),
            Text(lang.s(
                '(Camera integration coming in next update)',
                '(ካሜራ ቀጣዩ ዝማኔ ላይ ይመጣል)'),
                style: TextStyle(fontSize: 10,
                    color: TColors.white.withOpacity(0.2))),
          ],
        )),
      ]),
    );
  }

  List<Widget> _corners(Color c) => [
    Positioned(top: 0, left: 0, child: _Corner(c, false, false)),
    Positioned(top: 0, right: 0, child: _Corner(c, false, true)),
    Positioned(bottom: 0, left: 0, child: _Corner(c, true, false)),
    Positioned(bottom: 0, right: 0, child: _Corner(c, true, true)),
  ];
}

class _Corner extends StatelessWidget {
  final Color color; final bool bottom, right;
  const _Corner(this.color, this.bottom, this.right);
  @override
  Widget build(BuildContext context) => Container(
    width: 20, height: 20,
    decoration: BoxDecoration(
      border: Border(
        top: bottom ? BorderSide.none : BorderSide(color: color, width: 3),
        bottom: bottom ? BorderSide(color: color, width: 3) : BorderSide.none,
        left: right ? BorderSide.none : BorderSide(color: color, width: 3),
        right: right ? BorderSide(color: color, width: 3) : BorderSide.none,
      ),
    ),
  );
}

class _SuccessView extends StatelessWidget {
  final String sponsorName;
  final int xp;
  final LanguageProvider lang;
  final VoidCallback onClose;
  const _SuccessView({required this.sponsorName, required this.xp,
      required this.lang, required this.onClose});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.check_circle_rounded,
          color: TColors.green500, size: 72),
      const SizedBox(height: 20),
      Text(lang.s('Sponsor Scanned!', 'ስፖንሰር ተቃኘ!'),
          style: const TextStyle(fontSize: 24,
              color: TColors.white, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text(sponsorName,
          style: const TextStyle(fontSize: 16, color: TColors.teal300)),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TColors.green500.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: TColors.green500.withOpacity(0.3))),
        child: Text('+$xp XP ${lang.s('added to your account!', 'ወደ መለያዎ ታክሏል!')}',
            style: const TextStyle(fontSize: 18,
                color: TColors.green500, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center)),
      const SizedBox(height: 32),
      GestureDetector(
        onTap: onClose,
        child: Container(
          width: double.infinity, height: 50,
          decoration: BoxDecoration(
            gradient: TGradients.gradTeal,
            borderRadius: BorderRadius.circular(14)),
          child: Center(child: Text(lang.done,
              style: const TextStyle(color: TColors.white,
                  fontWeight: FontWeight.w700, fontSize: 16)))),
      ),
    ]),
  );
}
