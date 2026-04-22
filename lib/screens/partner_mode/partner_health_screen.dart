import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/providers/language_provider.dart';
import '../../models/partner_model.dart';

class PartnerHealthScreen extends StatelessWidget {
  final PartnerHealthView? health;
  final LanguageProvider lang;
  const PartnerHealthScreen({super.key, required this.health, required this.lang});

  @override
  Widget build(BuildContext context) {
    if (health == null) return _Empty(lang: lang);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(lang.s('Her Health', 'ጤናዋ'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                color: TColors.white)),
        Text(lang.s('${health!.womanName}\'s current status',
            '${health!.womanName} ወቅታዊ ሁኔታ'),
            style: TextStyle(fontSize: 13, color: TColors.white.withOpacity(0.4))),
        const SizedBox(height: 24),

        // Status summary card
        _GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _CardLabel(lang.s('OVERVIEW', 'ጠቅላላ እይታ')),
            const SizedBox(height: 12),
            _InfoRow(Icons.pregnant_woman_rounded, TColors.teal500,
                lang.s('Stage', 'ደረጃ'), health!.stageDisplay),
            if (health!.pregnancyWeek != null)
              _InfoRow(Icons.calendar_today_rounded, TColors.blue500,
                  lang.s('Pregnancy week', 'የእርግዝና ሳምንት'),
                  lang.s('Week ${health!.pregnancyWeek}',
                      'ሳምንት ${health!.pregnancyWeek}')),
            _InfoRow(Icons.edit_note_rounded,
                health!.loggedToday ? TColors.green500 : TColors.statusYellow,
                lang.s('Logged today', 'ዛሬ ምዝገባ'),
                health!.loggedToday
                    ? lang.s('Yes ✓', 'አዎ ✓')
                    : lang.s('Not yet', 'እስካሁን አይ')),
          ]),
        ),
        const SizedBox(height: 14),

        // Mood (if permitted)
        if (health!.moodScore != null) ...[
          _GlassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _CardLabel(lang.s('MOOD TODAY', 'ዛሬ ስሜት')),
              const SizedBox(height: 12),
              Row(children: [
                Text(['😞','😔','😐','🙂','😊','😄','🌟']
                    [health!.moodScore! - 1],
                    style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(health!.moodLabel(lang.isAmharic),
                      style: const TextStyle(fontSize: 16,
                          color: TColors.white, fontWeight: FontWeight.w700)),
                  if (health!.moodScore! <= 2)
                    Text(lang.s('Consider checking in with her',
                        'ሁኔታዋን ማረጋገጥ ይቆጠሩ'),
                        style: const TextStyle(fontSize: 12,
                            color: TColors.pink300)),
                ]),
              ]),
            ]),
          ),
          const SizedBox(height: 14),
        ],

        // ANC appointment
        if (health!.nextAncDate != null) ...[
          _GlassCard(
            color: TColors.blue500.withOpacity(0.07),
            borderColor: TColors.blue500.withOpacity(0.2),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _CardLabel(lang.s('NEXT ANC VISIT', 'ቀጣይ ANC ጉብኝት')),
              const SizedBox(height: 12),
              _InfoRow(Icons.calendar_month_rounded, TColors.blue500,
                  lang.s('Date', 'ቀን'),
                  '${health!.nextAncDate!.day}/${health!.nextAncDate!.month}/${health!.nextAncDate!.year}'),
              if (health!.ancLocation != null)
                _InfoRow(Icons.place_rounded, TColors.blue400,
                    lang.s('Location', 'ቦታ'), health!.ancLocation!),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TColors.blue500.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10)),
                child: Text(lang.s(
                    '💡 Your role: arrange transport, take time off work, '
                    'bring a written list of questions for the doctor.',
                    '💡 ሚናዎ: ትራንስፖርት ያዘጋጁ፣ ከሥራ ፈቃድ ይውሰዱ፣ '
                    'ለሐኪሙ የጽሑፍ ጥያቄዎች ዝርዝር ያምጡ።'),
                    style: TextStyle(fontSize: 12, height: 1.5,
                        color: TColors.blue300.withOpacity(0.8)))),
            ]),
          ),
          const SizedBox(height: 14),
        ],

        // What she may be feeling this week
        _GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _CardLabel(lang.s('WHAT SHE MAY BE FEELING',
                'ምን ስሜት ሊሰማት ይችላል')),
            const SizedBox(height: 12),
            ..._weekSymptoms(health!.pregnancyWeek ?? 0, lang.isAmharic)
                .map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 6, height: 6,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: TColors.teal400, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(s,
                    style: TextStyle(fontSize: 13,
                        color: TColors.white.withOpacity(0.65),
                        height: 1.4))),
              ]),
            )),
          ]),
        ),
      ]),
    );
  }

  List<String> _weekSymptoms(int week, bool isAm) {
    if (week < 13) return isAm
        ? ['ማሳከክ እና ማቅለሽለሽ ብዙ ጊዜ ይታያሉ', 'ድካም ተለምዶ ነው', 'ደረት ቁርጠት ሊሰማ ይችላል']
        : ['Nausea and vomiting are common', 'Fatigue is normal', 'Breast tenderness is expected'];
    if (week < 27) return isAm
        ? ['ሆዳ ይታያል — ሊያፍሩ ይችላሉ', 'ጀርባ ምታ ሊያጋጥም ይችላል', 'ዝርዝር ሃሳቦች ሊኖሯቸው ይችላሉ']
        : ['Belly is showing — she may feel self-conscious', 'Back pain is common', 'She may feel emotional and forgetful'];
    if (week < 37) return isAm
        ? ['ህፃኑ ምቹ ቦታ ሊያሰቃያት ይችላል', 'ወደ መጸዳጃ ቤት ብዙ ጊዜ ትሄዳለች', 'ፍርሃት ከወሊድ ሊጀምር ይችላል']
        : ['Baby\'s position may cause discomfort', 'Frequent bathroom trips', 'Fear about labor may begin'];
    return isAm
        ? ['ሁሉ ቁሳቁስ ዝግጁ ነው?', 'ሆስፒታሉ ዙሪያ ይፈጥኑ', 'ቀን ቀን ይቆጠሩ']
        : ['Is everything packed?', 'Know the hospital route', 'Count down every day with her'];
  }
}

class _Empty extends StatelessWidget {
  final LanguageProvider lang;
  const _Empty({required this.lang});
  @override
  Widget build(BuildContext context) => Center(
    child: Text(lang.s('No health data yet', 'እስካሁን የጤና ዳታ የለም'),
        style: TextStyle(color: TColors.white.withOpacity(0.3))));
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Color? borderColor;
  const _GlassCard({required this.child, this.color, this.borderColor});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color ?? TColors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: borderColor ?? TColors.white.withOpacity(0.08))),
        child: child)));
}

class _CardLabel extends StatelessWidget {
  final String text;
  const _CardLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
          color: TColors.white.withOpacity(0.35), letterSpacing: 1.2));
}

class _InfoRow extends StatelessWidget {
  final IconData icon; final Color color;
  final String label, value;
  const _InfoRow(this.icon, this.color, this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Icon(icon, color: color, size: 16),
      const SizedBox(width: 8),
      Text(label, style: TextStyle(fontSize: 13,
          color: TColors.white.withOpacity(0.45))),
      const Spacer(),
      Text(value, style: const TextStyle(fontSize: 13,
          color: TColors.white, fontWeight: FontWeight.w600)),
    ]));
}
