import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';
import '../../models/partner_model.dart';

class PartnerEducationScreen extends StatefulWidget {
  final LanguageProvider lang;
  final int week;
  const PartnerEducationScreen({super.key, required this.lang, required this.week});
  @override
  State<PartnerEducationScreen> createState() => _PartnerEducationScreenState();
}

class _PartnerEducationScreenState extends State<PartnerEducationScreen> {
  PartnerModule? _open;

  @override
  Widget build(BuildContext context) {
    if (_open != null) return _ModuleDetail(
      module: _open!, lang: widget.lang,
      onBack: () => setState(() => _open = null));

    final modules = PartnerModule.all;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.lang.s('Partner Learning', 'የሸሪካ ትምህርት'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                color: TColors.white)),
        Text(widget.lang.s(
            'Guides written specifically for you — not medical jargon',
            'ለእርስዎ የተፃፉ መመሪያዎች — የሕክምና ቃላት አይደሉም'),
            style: TextStyle(fontSize: 13,
                color: TColors.white.withOpacity(0.4))),
        const SizedBox(height: 24),

        // Priority banner — danger signs always first
        _PriorityBanner(lang: widget.lang,
            onTap: () => setState(() =>
                _open = modules.firstWhere((m) => m.id == 'danger_signs'))),
        const SizedBox(height: 16),

        ...modules.map((m) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ModuleCard(module: m, lang: widget.lang,
              onTap: () => setState(() => _open = m)),
        )),
      ]),
    );
  }
}

class _PriorityBanner extends StatelessWidget {
  final LanguageProvider lang;
  final VoidCallback onTap;
  const _PriorityBanner({required this.lang, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          TColors.red400.withOpacity(0.15),
          TColors.pink500.withOpacity(0.10),
        ]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.red400.withOpacity(0.35))),
      child: Row(children: [
        const Icon(Icons.warning_amber_rounded,
            color: TColors.red400, size: 28),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.s('Start here — Read first',
                'ከዚህ ጀምሩ — አስቀድሞ ያንብቡ'),
                style: const TextStyle(fontSize: 11,
                    color: TColors.red400, fontWeight: FontWeight.w700,
                    letterSpacing: 0.5)),
            Text(lang.s('Danger Signs Every Husband Must Know',
                'እያንዳንዱ ባል ማወቅ ያለበት የአደጋ ምልክቶች'),
                style: const TextStyle(fontSize: 15,
                    color: TColors.white, fontWeight: FontWeight.w700)),
          ],
        )),
        const Icon(Icons.arrow_forward_ios_rounded,
            color: TColors.red400, size: 14),
      ]),
    ),
  );
}

class _ModuleCard extends StatelessWidget {
  final PartnerModule module;
  final LanguageProvider lang;
  final VoidCallback onTap;
  const _ModuleCard({required this.module, required this.lang, required this.onTap});

  static const colors = [TColors.teal500, TColors.blue500,
    TColors.green500, const Color(0xFF7C4DFF), TColors.pink500];
  static const icons = [Icons.medical_services_rounded,
    Icons.local_hospital_rounded, Icons.restaurant_rounded,
    Icons.psychology_rounded, Icons.child_care_rounded];

  @override
  Widget build(BuildContext context) {
    final idx = PartnerModule.all.indexOf(module) % 5;
    final col = colors[idx];
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TColors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: TColors.white.withOpacity(0.08))),
            child: Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: col.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(13)),
                child: Icon(icons[idx], color: col, size: 24)),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lang.isAmharic ? module.titleAm : module.titleEn,
                      style: const TextStyle(fontSize: 14,
                          color: TColors.white, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(lang.isAmharic ? module.descAm : module.descEn,
                      style: TextStyle(fontSize: 12,
                          color: TColors.white.withOpacity(0.45),
                          height: 1.4),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              )),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: TColors.white.withOpacity(0.3), size: 14),
            ]),
          ),
        ),
      ),
    );
  }
}

class _ModuleDetail extends StatelessWidget {
  final PartnerModule module;
  final LanguageProvider lang;
  final VoidCallback onBack;
  const _ModuleDetail({required this.module, required this.lang, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final tips = lang.isAmharic ? module.tipsAm : module.tipsEn;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: onBack,
          child: Row(children: [
            const Icon(Icons.arrow_back_ios_rounded,
                color: TColors.teal400, size: 16),
            const SizedBox(width: 4),
            Text(lang.s('Back', 'ተመለስ'),
                style: const TextStyle(color: TColors.teal400, fontSize: 14)),
          ]),
        ),
        const SizedBox(height: 24),
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            gradient: TGradients.gradTeal,
            borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.menu_book_rounded,
              color: TColors.white, size: 28)),
        const SizedBox(height: 16),
        Text(lang.isAmharic ? module.titleAm : module.titleEn,
            style: const TextStyle(fontSize: 22,
                color: TColors.white, fontWeight: FontWeight.w800,
                height: 1.2)),
        const SizedBox(height: 8),
        Text(lang.isAmharic ? module.descAm : module.descEn,
            style: TextStyle(fontSize: 14, height: 1.6,
                color: TColors.white.withOpacity(0.55))),
        const SizedBox(height: 28),
        Text(lang.s('Key points for you:', 'ለእርስዎ ቁልፍ ነጥቦች:'),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                color: TColors.white.withOpacity(0.4),
                letterSpacing: 0.5)),
        const SizedBox(height: 12),
        ...List.generate(tips.length, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: TColors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: TColors.white.withOpacity(0.07))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        color: TColors.teal500.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6)),
                      child: Center(child: Text('${i+1}',
                          style: const TextStyle(fontSize: 11,
                              color: TColors.teal300,
                              fontWeight: FontWeight.w800)))),
                    const SizedBox(width: 12),
                    Expanded(child: Text(tips[i],
                        style: TextStyle(fontSize: 14, height: 1.5,
                            color: TColors.white.withOpacity(0.8)))),
                  ],
                ),
              ),
            ),
          ),
        )),
      ]),
    );
  }
}
