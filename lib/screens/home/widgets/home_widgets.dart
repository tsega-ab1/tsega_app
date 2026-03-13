// daily_tip_card.dart
// alert_card.dart
// stat_cards.dart
// lifecycle_bar.dart
// ai_insight_card.dart
// partner_card.dart
// All in one file for now, split later

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/gradients.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/stage_provider.dart';
import '../../../overlays/tip_detail_overlay.dart';

// ─── DAILY TIP CARD ──────────────────────────────────────────────
class DailyTipCard extends StatelessWidget {
  const DailyTipCard({super.key});

  static final _tips = [
    _TipData('Drink 8 glasses of water today',
        'ዛሬ 8 ብርጭቆ ውሃ ይጠጡ',
        'Staying hydrated helps regulate your cycle and reduces cramps.',
        'ፈሳሽ መጠጣት የወር አበባ ዑደትዎን ይቆጣጠራል።',
        Icons.water_drop_rounded, TColors.blue500),
    _TipData('Iron-rich foods: lentils, spinach, teff',
        'ብረት ያለው ምግብ: ምስር፣ ስፒናች፣ ጤፍ',
        'Ethiopian teff has more iron than wheat. Eat injera daily during pregnancy.',
        'የኢትዮጵያ ጤፍ ከስንዴ በላይ ብረት አለው።',
        Icons.restaurant_rounded, TColors.green500),
    _TipData('Walk 20 minutes today',
        'ዛሬ 20 ደቂቃ ይራመዱ',
        'Light exercise reduces pregnancy discomfort and improves circulation.',
        'ቀላል ልምምድ የእርግዝና ምቾትን ይቀንሳል።',
        Icons.directions_walk_rounded, TColors.teal500),
    _TipData('Take your folic acid supplement',
        'የፎሊክ አሲድ ሙሌትዎን ይውሰዱ',
        'Folic acid prevents neural tube defects. Take 400mcg daily.',
        'ፎሊክ አሲድ የነርቭ ቱቦ ጉድለቶችን ይከላከላል።',
        Icons.medication_rounded, TColors.pink500),
    _TipData('Monitor your blood pressure today',
        'ዛሬ የደም ግፊትዎን ይፈትሹ',
        'High BP in pregnancy can signal preeclampsia. Know your numbers.',
        'ከፍተኛ BP በእርግዝና ቅድመ-ወሊድ ምልክት ሊሆን ይችላል።',
        Icons.monitor_heart_rounded, TColors.red400),
    _TipData('Rest when your body asks',
        'ሰውነትዎ ሲጠይቅ ያርፉ',
        'Fatigue is your body\'s signal. Sleep at least 8 hours during pregnancy.',
        'ድካም የሰውነትዎ ምልክት ነው። ቢያንስ 8 ሰዓት ይተኛሉ።',
        Icons.bedtime_rounded, TColors.blue300),
    _TipData('Eat calcium-rich foods today',
        'ዛሬ ካልሲየም ያለው ምግብ ይብሉ',
        'Sesame (selit), beans, and leafy greens are great Ethiopian calcium sources.',
        'ሰሊጥ፣ ባቄላ፣ እና አረንጓዴ ቅጠሎች ጥሩ ካልሲየም ምንጮች ናቸው።',
        Icons.eco_rounded, TColors.green700),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final tip = _tips[DateTime.now().day % _tips.length];

    return GestureDetector(
      onTap: () => showTipDetailOverlay(context, tip),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: tip.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: tip.color.withOpacity(0.2)),
        ),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: tip.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(tip.icon, color: tip.color, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lang.dailyTip,
                  style: TextStyle(fontSize: 11,
                      color: tip.color, fontWeight: FontWeight.w700,
                      letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(lang.isAmharic ? tip.titleAm : tip.titleEn,
                  style: TTextStyles.headlineSmall),
            ],
          )),
          Icon(Icons.arrow_forward_ios_rounded,
              color: tip.color, size: 16),
        ]),
      ),
    );
  }
}

class _TipData {
  final String titleEn, titleAm, bodyEn, bodyAm;
  final IconData icon;
  final Color color;
  const _TipData(this.titleEn, this.titleAm, this.bodyEn, this.bodyAm,
      this.icon, this.color);
}

// ─── ALERT CARD ──────────────────────────────────────────────────
class AlertCard extends StatelessWidget {
  const AlertCard({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: TGradients.gradTeal,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        const Icon(Icons.notifications_active_rounded,
            color: TColors.white, size: 28),
        const SizedBox(width: 16),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.s('ANC Visit Due', 'ANC ጉብኝት ሊደርስ ነው'),
                style: const TextStyle(color: TColors.white,
                    fontWeight: FontWeight.w700, fontSize: 15)),
            Text(lang.s('Next appointment: March 20',
                'ቀጣይ ቀጠሮ: መጋቢት 11'),
                style: TextStyle(color: TColors.white.withOpacity(0.85),
                    fontSize: 13)),
          ],
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: TColors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(lang.s('3 days', '3 ቀናት'),
              style: const TextStyle(color: TColors.white,
                  fontWeight: FontWeight.w700, fontSize: 12)),
        ),
      ]),
    );
  }
}

// ─── STAT CARDS ──────────────────────────────────────────────────
class StatCards extends StatelessWidget {
  const StatCards({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Row(children: [
      Expanded(child: _StatCard(
        icon: Icons.calendar_today_rounded,
        value: '14',
        label: lang.s('Cycle Day', 'የዑደት ቀን'),
        color: TColors.pink500,
      )),
      const SizedBox(width: 12),
      Expanded(child: _StatCard(
        icon: Icons.water_drop_rounded,
        value: '11.2',
        label: lang.s('Hb g/dL', 'Hb g/dL'),
        color: TColors.teal500,
      )),
      const SizedBox(width: 12),
      Expanded(child: _StatCard(
        icon: Icons.monitor_heart_rounded,
        value: '118/76',
        label: lang.s('Blood Pressure', 'ደም ግፊት'),
        color: TColors.blue500,
      )),
    ]);
  }
}

class _StatCard extends StatefulWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  const _StatCard({
    required this.icon, required this.value,
    required this.label, required this.color});
  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
            color: TColors.dark.withOpacity(0.05),
            blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(widget.icon, color: widget.color, size: 20),
        const SizedBox(height: 8),
        Text(widget.value, style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700,
            color: widget.color)),
        Text(widget.label, style: TTextStyles.bodySmall,
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    ),
  );
}

// ─── LIFECYCLE BAR ───────────────────────────────────────────────
class LifecycleBar extends StatelessWidget {
  const LifecycleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final stage = context.watch<StageProvider>();
    final stages = [
      LifeStage.adolescence,
      LifeStage.reproductive,
      LifeStage.pregnancy,
      LifeStage.postpartum,
      LifeStage.menopause,
    ];

    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: TColors.border,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(children: stages.map((s) {
        final active = stage.lifeStage == s;
        return Expanded(child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          height: 6,
          decoration: BoxDecoration(
            gradient: active ? TGradients.gradTeal : null,
            color: active ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(3),
          ),
        ));
      }).toList()),
    );
  }
}

// ─── AI INSIGHT CARD ─────────────────────────────────────────────
class AiInsightCard extends StatelessWidget {
  const AiInsightCard({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
            color: TColors.teal700.withOpacity(0.06),
            blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: TGradients.gradTeal,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.psychology_rounded,
                color: TColors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(lang.s('AI Insight', 'AI ትንታኔ'),
              style: TTextStyles.headlineSmall),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: TColors.green50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(lang.s('Low Risk', 'ዝቅተኛ ስጋት'),
                style: const TextStyle(fontSize: 11,
                    color: TColors.green700,
                    fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 14),
        Text(
          lang.s(
            'Your hemoglobin trend is stable. Continue iron-rich diet with teff and lentils. Next Hb check recommended in 4 weeks.',
            'የሄሞግሎቢን አዝማሚያዎ የተረጋጋ ነው። ጤፍ እና ምስር ያካተተ አመጋገብ ይቀጥሉ።'),
          style: TTextStyles.bodyMedium,
        ),
      ]),
    );
  }
}

// ─── PARTNER CARD ────────────────────────────────────────────────
class PartnerCard extends StatelessWidget {
  const PartnerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.blue50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TColors.blue100),
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            gradient: TGradients.gradBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.family_restroom_rounded,
              color: TColors.white, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.s('Partner Connected', 'ሸሪካ ተያይዟል'),
                style: TTextStyles.headlineSmall),
            Text(lang.s('Last alert sent 2 days ago',
                'የመጨረሻ ማንቂያ ከ2 ቀናት በፊት ተልኳል'),
                style: TTextStyles.bodySmall),
          ],
        )),
        const Icon(Icons.check_circle_rounded,
            color: TColors.green500, size: 24),
      ]),
    );
  }
}
