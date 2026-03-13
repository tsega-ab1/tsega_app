import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/stage_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../overlays/quick_log_overlay.dart';
import 'kick_counter_screen.dart';
import 'week_by_week_screen.dart';

class PregnancyScreen extends StatelessWidget {
  const PregnancyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final stage = context.watch<StageProvider>();
    final week = stage.pregnancyWeek.clamp(1, 40);

    // Find closest baby size
    final sizeKey = AppConstants.babySizes.keys
        .lastWhere((k) => k <= week, orElse: () => 4);
    final babySize = AppConstants.babySizes[sizeKey] ?? 'a poppy seed';

    return Scaffold(
      backgroundColor: TColors.cream,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(gradient: TGradients.gradTeal),
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lang.s('SafeMother', 'ሳፌ-ማዘር'),
                      style: TextStyle(
                          fontSize: 14,
                          color: TColors.white.withOpacity(0.75),
                          letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  Text(lang.s('Pregnancy Journey', 'የእርግዝና ጉዞ'),
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w700,
                          color: TColors.white)),
                  const SizedBox(height: 28),
                  // Week + due date row
                  Row(children: [
                    _WeekBubble(week: week, lang: lang),
                    const SizedBox(width: 20),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lang.s('Due Date', 'የወሊድ ቀን'),
                            style: TextStyle(
                                color: TColors.white.withOpacity(0.75),
                                fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(
                          stage.dueDate != null
                              ? '${stage.dueDate!.day}/${stage.dueDate!.month}/${stage.dueDate!.year}'
                              : '--/--/----',
                          style: const TextStyle(
                              color: TColors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: TColors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${stage.daysToGo} ${lang.s('days to go', 'ቀናት ቀርተዋል')}',
                            style: const TextStyle(
                                color: TColors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        ),
                      ],
                    )),
                  ]),
                  const SizedBox(height: 20),
                  // Baby size banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: TColors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: TColors.white.withOpacity(0.25)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.child_care_rounded,
                          color: TColors.white, size: 24),
                      const SizedBox(width: 12),
                      Expanded(child: Text(
                        '${lang.s('Baby is the size of', 'ሕፃኑ ያህላል')} $babySize',
                        style: const TextStyle(
                            color: TColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600))),
                    ]),
                  ),
                ],
              ),
            ),
          ),

          // Quick actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lang.s('Quick Actions', 'ፈጣን እርምጃዎች'),
                      style: TTextStyles.headlineSmall),
                  const SizedBox(height: 16),
                  Row(children: [
                    _ActionCard(
                      icon: Icons.touch_app_rounded,
                      label: lang.kickCounter,
                      gradient: TGradients.gradBlue,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const KickCounterScreen())),
                    ),
                    const SizedBox(width: 12),
                    _ActionCard(
                      icon: Icons.menu_book_rounded,
                      label: lang.weekByWeek,
                      gradient: TGradients.gradGreen,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const WeekByWeekScreen())),
                    ),
                    const SizedBox(width: 12),
                    _ActionCard(
                      icon: Icons.sick_rounded,
                      label: lang.logSymptoms,
                      gradient: TGradients.gradPink,
                      onTap: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const QuickLogOverlay(
                            isPregnancy: true),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),

          // ANC Reminders
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _AncCard(lang: lang, week: week),
            ),
          ),

          // Danger Signs
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _DangerSignsCard(lang: lang),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

// ─── WEEK BUBBLE ─────────────────────────────────────────────────
class _WeekBubble extends StatelessWidget {
  final int week;
  final LanguageProvider lang;
  const _WeekBubble({required this.week, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      SizedBox(
        width: 90, height: 90,
        child: CircularProgressIndicator(
          value: week / 40,
          backgroundColor: TColors.white.withOpacity(0.2),
          color: TColors.white,
          strokeWidth: 5,
        ),
      ),
      Column(mainAxisSize: MainAxisSize.min, children: [
        Text('$week',
            style: const TextStyle(
                fontSize: 30, fontWeight: FontWeight.w800,
                color: TColors.white)),
        Text(lang.s('weeks', 'ሳምንት'),
            style: TextStyle(
                fontSize: 11,
                color: TColors.white.withOpacity(0.75))),
      ]),
    ]);
  }
}

// ─── ACTION CARD ─────────────────────────────────────────────────
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon, required this.label,
    required this.gradient, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: TColors.teal700.withOpacity(0.2),
                blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: TColors.white, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    color: TColors.white, fontSize: 11,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    ),
  );
}

// ─── ANC CARD ────────────────────────────────────────────────────
class _AncCard extends StatelessWidget {
  final LanguageProvider lang;
  final int week;
  const _AncCard({required this.lang, required this.week});

  @override
  Widget build(BuildContext context) {
    final nextVisit = week < 12
        ? lang.s('First ANC visit (8–12 weeks)',
            'የመጀመሪያ ANC ጉብኝት (8-12 ሳምንት)')
        : week < 20
            ? lang.s('Second ANC visit (16–20 weeks)',
                'ሁለተኛ ANC ጉብኝት (16-20 ሳምንት)')
            : week < 28
                ? lang.s('Third ANC visit (24–28 weeks)',
                    'ሶስተኛ ANC ጉብኝት (24-28 ሳምንት)')
                : lang.s('Fourth ANC visit (32–36 weeks)',
                    'አራተኛ ANC ጉብኝት (32-36 ሳምንት)');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TColors.teal100),
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: TColors.teal50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.local_hospital_rounded,
              color: TColors.teal700, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.s('Next ANC Visit', 'ቀጣይ ANC ጉብኝት'),
                style: TTextStyles.labelLarge),
            const SizedBox(height: 4),
            Text(nextVisit, style: TTextStyles.bodyMedium),
          ],
        )),
        const Icon(Icons.chevron_right_rounded, color: TColors.gray),
      ]),
    );
  }
}

// ─── DANGER SIGNS CARD ───────────────────────────────────────────
class _DangerSignsCard extends StatelessWidget {
  final LanguageProvider lang;
  const _DangerSignsCard({required this.lang});

  @override
  Widget build(BuildContext context) {
    final signs = lang.isAmharic
        ? ['ከባድ ራስ ምታት', 'ፊት ወይም እጅ ማበጥ', 'ደም መፍሰስ', 'ሕፃኑ አልተንቀሳቀሰም']
        : ['Severe headache', 'Swelling of face/hands',
           'Vaginal bleeding', 'No fetal movement'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TColors.red100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TColors.red400.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.warning_amber_rounded,
              color: TColors.red400, size: 22),
          const SizedBox(width: 8),
          Text(lang.dangerSigns,
              style: TTextStyles.headlineSmall
                  .copyWith(color: TColors.red400)),
        ]),
        const SizedBox(height: 12),
        Text(lang.s(
            'Go to hospital immediately if you experience:',
            'ከሚከተሉት ምልክቶች ካጋጠሙዎ ወዲያው ሆስፒታል ይሂዱ:'),
            style: TTextStyles.bodyMedium),
        const SizedBox(height: 10),
        ...signs.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(children: [
            const Icon(Icons.circle, color: TColors.red400, size: 8),
            const SizedBox(width: 10),
            Text(s, style: TTextStyles.bodyMedium
                .copyWith(color: TColors.dark)),
          ]),
        )),
      ]),
    );
  }
}
