import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/partner_provider.dart';
import '../../models/partner_model.dart';
import 'partner_health_screen.dart';
import 'partner_education_screen.dart';
import 'partner_chat_screen.dart';
import 'partner_danger_overlay.dart';

class PartnerHomeScreen extends StatefulWidget {
  const PartnerHomeScreen({super.key});
  @override
  State<PartnerHomeScreen> createState() => _PartnerHomeScreenState();
}

class _PartnerHomeScreenState extends State<PartnerHomeScreen>
    with TickerProviderStateMixin {
  int _tab = 0;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // Check danger alert on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<PartnerProvider>();
      if (p.hasDangerAlert) _showDangerOverlay();
    });
  }

  @override
  void dispose() { _pulseCtrl.dispose(); super.dispose(); }

  void _showDangerOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => const PartnerDangerOverlay(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang    = context.watch<LanguageProvider>();
    final partner = context.watch<PartnerProvider>();
    final health  = partner.healthView;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Stack(children: [
        // Background
        Positioned(top: -80, right: -60,
            child: _Orb(300, TColors.teal500.withOpacity(0.10))),
        Positioned(bottom: 100, left: -60,
            child: _Orb(240, TColors.blue500.withOpacity(0.08))),

        SafeArea(child: IndexedStack(
          index: _tab,
          children: [
            _HomeTab(health: health, lang: lang, partner: partner,
                pulse: _pulse,
                onDangerTap: _showDangerOverlay),
            PartnerHealthScreen(health: health, lang: lang),
            PartnerEducationScreen(lang: lang,
                week: health?.pregnancyWeek ?? 0),
            PartnerChatScreen(lang: lang, partner: partner),
          ],
        )),

        // Bottom nav
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: _PartnerBottomNav(
            selected: _tab,
            unreadMessages: partner.unreadCount,
            lang: lang,
            onTap: (i) => setState(() => _tab = i),
          ),
        ),
      ]),
    );
  }
}

// ── HOME TAB ─────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final PartnerHealthView? health;
  final LanguageProvider lang;
  final PartnerProvider partner;
  final Animation<double> pulse;
  final VoidCallback onDangerTap;

  const _HomeTab({
    required this.health, required this.lang,
    required this.partner, required this.pulse,
    required this.onDangerTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = health?.womanName ?? 'her';
    final week = health?.pregnancyWeek ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── TOP BAR ─────────────────────────────────────────
          Row(children: [
            // Partner badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: TColors.teal500.withOpacity(0.12),
                border: Border.all(
                    color: TColors.teal500.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.favorite_rounded,
                    color: TColors.teal400, size: 12),
                const SizedBox(width: 5),
                Text(lang.s('Partner', 'ሸሪካ'),
                    style: const TextStyle(
                        fontSize: 11, color: TColors.teal300,
                        fontWeight: FontWeight.w700)),
              ]),
            ),
            const Spacer(),
            // Danger alert bell
            if (partner.hasDangerAlert)
              GestureDetector(
                onTap: onDangerTap,
                child: AnimatedBuilder(
                  animation: pulse,
                  builder: (_, __) => Transform.scale(
                    scale: pulse.value,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: TColors.red400.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: TColors.red400.withOpacity(0.5))),
                      child: const Icon(Icons.warning_amber_rounded,
                          color: TColors.red400, size: 20)),
                  ),
                ),
              ),
          ]),
          const SizedBox(height: 20),

          // ── GREETING ─────────────────────────────────────────
          Text(lang.s('Good morning', 'ደህና አደሩ'),
              style: TextStyle(fontSize: 13,
                  color: TColors.white.withOpacity(0.4))),
          Text(lang.s('Supporting $name', '$nameን እያገዙ ነዎት'),
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w800,
                  color: TColors.white, letterSpacing: -0.5)),
          const SizedBox(height: 20),

          // ── WEEK HERO CARD ───────────────────────────────────
          if (health?.pregnancyWeek != null)
            _WeekHeroCard(health: health!, lang: lang),

          const SizedBox(height: 16),

          // ── DANGER SIGNS STATUS ──────────────────────────────
          _DangerStatusCard(
            hasDanger: health?.hasDangerSigns ?? false,
            signs: health?.dangerSignsActive ?? [],
            lang: lang,
            onTap: onDangerTap,
          ),
          const SizedBox(height: 16),

          // ── TODAY'S ACTION CARD ──────────────────────────────
          _TodayActionCard(
            name: name, week: week, loggedToday: health?.loggedToday ?? false,
            lang: lang),
          const SizedBox(height: 16),

          // ── MOOD CARD (if permission granted) ───────────────
          if (health?.moodScore != null)
            _MoodCard(health: health!, lang: lang),

          if (health?.moodScore != null) const SizedBox(height: 16),

          // ── ANC REMINDER ─────────────────────────────────────
          if (health?.nextAncDate != null)
            _AncReminderCard(health: health!, lang: lang),

          if (health?.nextAncDate != null) const SizedBox(height: 16),

          // ── THIS WEEK EDUCATION PREVIEW ──────────────────────
          _WeekEducationPreview(week: week, lang: lang),
          const SizedBox(height: 16),

          // ── QUICK ACTIONS ────────────────────────────────────
          _QuickActionsRow(lang: lang),
        ],
      ),
    );
  }
}

// ── WEEK HERO CARD ───────────────────────────────────────────────
class _WeekHeroCard extends StatelessWidget {
  final PartnerHealthView health;
  final LanguageProvider lang;
  const _WeekHeroCard({required this.health, required this.lang});

  String _weekContext(int week, bool isAm) {
    if (week < 13) return isAm
        ? 'ፊርስት ትሪሜስተር — ህፃኑ በፍጥነት እያደገ ነው'
        : 'First trimester — baby growing rapidly';
    if (week < 27) return isAm
        ? 'ሴከንድ ትሪሜስተር — እሷ ቀላል ስሜት ሊሰማት ይችላል'
        : 'Second trimester — she may feel more comfortable';
    if (week < 37) return isAm
        ? 'ቴርድ ትሪሜስተር — ዝግጅት ጊዜ'
        : 'Third trimester — time to prepare';
    return isAm ? 'ብዙም አልቀረ — ዝግጁ ሁኑ' : 'Almost there — stay ready';
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            TColors.teal700.withOpacity(0.25),
            TColors.blue700.withOpacity(0.20),
          ]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: TColors.teal400.withOpacity(0.3))),
        child: Row(children: [
          // Week number
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(lang.s('WEEK', 'ሳምንት'),
                style: TextStyle(fontSize: 11,
                    color: TColors.teal300.withOpacity(0.7),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5)),
            Text('${health.pregnancyWeek}',
                style: const TextStyle(
                    fontSize: 64, fontWeight: FontWeight.w800,
                    color: TColors.white, height: 1.0)),
            Text(_weekContext(health.pregnancyWeek!, lang.isAmharic),
                style: TextStyle(fontSize: 12,
                    color: TColors.white.withOpacity(0.5))),
          ]),
          const Spacer(),
          // Days left
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(lang.s('Days to due date', 'ወደ መውለጃ ቀን'),
                style: TextStyle(fontSize: 11,
                    color: TColors.white.withOpacity(0.4))),
            Text('${(40 - health.pregnancyWeek!) * 7}',
                style: const TextStyle(
                    fontSize: 32, fontWeight: FontWeight.w800,
                    color: TColors.teal300)),
            Text(lang.s('days', 'ቀናት'),
                style: TextStyle(fontSize: 12,
                    color: TColors.white.withOpacity(0.4))),
          ]),
        ]),
      ),
    ),
  );
}

// ── DANGER STATUS CARD ───────────────────────────────────────────
class _DangerStatusCard extends StatelessWidget {
  final bool hasDanger;
  final List<String> signs;
  final LanguageProvider lang;
  final VoidCallback onTap;
  const _DangerStatusCard({
    required this.hasDanger, required this.signs,
    required this.lang, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: hasDanger ? onTap : null,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: hasDanger
                ? TColors.red400.withOpacity(0.10)
                : TColors.green500.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasDanger
                  ? TColors.red400.withOpacity(0.4)
                  : TColors.green500.withOpacity(0.25))),
          child: Row(children: [
            Icon(hasDanger
                ? Icons.warning_amber_rounded
                : Icons.check_circle_rounded,
                color: hasDanger ? TColors.red400 : TColors.green500,
                size: 24),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hasDanger
                    ? lang.s('Danger Signs Detected',
                        'የአደጋ ምልክቶች ተገኝተዋል')
                    : lang.s('No Danger Signs', 'ምንም የአደጋ ምልክቶች የሉም'),
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: hasDanger ? TColors.red400 : TColors.green500)),
                Text(hasDanger
                    ? lang.s('Tap to see details and take action',
                        'ዝርዝሮችን ለማየት እና እርምጃ ለመውሰድ ይጫኑ')
                    : lang.s('Her health is currently stable',
                        'ጤናዋ አሁን ተረጋጋ ነው'),
                    style: TextStyle(fontSize: 12,
                        color: TColors.white.withOpacity(0.5))),
              ],
            )),
            if (hasDanger)
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: TColors.red400, size: 14),
          ]),
        ),
      ),
    ),
  );
}

// ── TODAY ACTION CARD ────────────────────────────────────────────
class _TodayActionCard extends StatelessWidget {
  final String name;
  final int week;
  final bool loggedToday;
  final LanguageProvider lang;
  const _TodayActionCard({
    required this.name, required this.week,
    required this.loggedToday, required this.lang,
  });

  String _actionText(int week, bool isAm) {
    if (week >= 28 && week <= 32) return isAm
        ? 'ዛሬ $nameን ጡቶ ምልክቶቿን ልታሳውቅ ጠይቋት'
        : 'Ask $name if she felt any contractions today';
    if (week >= 36) return isAm
        ? 'ሆስፒታሉ ቅርብ ነው — ቦርሳ ዝግጁ ነው?'
        : 'Hospital bag packed? Due date is very close';
    return isAm
        ? 'ዛሬ $nameን እንዴት ናት ብለህ ጠይቃት'
        : 'Ask $name how she\'s feeling today — it means a lot';
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TColors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TColors.white.withOpacity(0.08))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.today_rounded,
                  color: TColors.teal400, size: 18),
              const SizedBox(width: 8),
              Text(lang.s('Your action today', 'ዛሬ ሊወስዱት የሚገባ እርምጃ'),
                  style: TextStyle(fontSize: 12,
                      color: TColors.white.withOpacity(0.5),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5)),
            ]),
            const SizedBox(height: 10),
            Text(_actionText(week, lang.isAmharic),
                style: const TextStyle(
                    fontSize: 15, color: TColors.white, height: 1.4)),
            const SizedBox(height: 12),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: loggedToday
                      ? TColors.green500.withOpacity(0.12)
                      : TColors.statusYellow.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8)),
                child: Text(
                  loggedToday
                      ? lang.s('✓ She logged today', '✓ ዛሬ ምዝገባ አደረገች')
                      : lang.s('Not logged today yet', 'ዛሬ ምዝገባ አልተደረገም'),
                  style: TextStyle(fontSize: 11,
                      color: loggedToday
                          ? TColors.green500 : TColors.statusYellow,
                      fontWeight: FontWeight.w700)),
              ),
            ]),
          ],
        ),
      ),
    ),
  );
}

// ── MOOD CARD ────────────────────────────────────────────────────
class _MoodCard extends StatelessWidget {
  final PartnerHealthView health;
  final LanguageProvider lang;
  const _MoodCard({required this.health, required this.lang});

  @override
  Widget build(BuildContext context) {
    final score = health.moodScore!;
    final isLow = score <= 2;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isLow
                ? TColors.pink500.withOpacity(0.08)
                : TColors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLow
                  ? TColors.pink500.withOpacity(0.3)
                  : TColors.white.withOpacity(0.07))),
          child: Row(children: [
            Text(['😞','😔','😐','🙂','😊','😄','🌟'][score - 1],
                style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lang.s('Her mood today', 'ዛሬ ስሜቷ'),
                    style: TextStyle(fontSize: 12,
                        color: TColors.white.withOpacity(0.4))),
                Text(health.moodLabel(lang.isAmharic),
                    style: const TextStyle(
                        fontSize: 15, color: TColors.white,
                        fontWeight: FontWeight.w600)),
                if (isLow) ...[
                  const SizedBox(height: 6),
                  Text(lang.s(
                      'She may need extra support today.',
                      'ዛሬ ተጨማሪ ድጋፍ ሊያስፈልጋት ይችላል።'),
                      style: TextStyle(fontSize: 12,
                          color: TColors.pink300.withOpacity(0.8))),
                ],
              ],
            )),
          ]),
        ),
      ),
    );
  }
}

// ── ANC REMINDER CARD ────────────────────────────────────────────
class _AncReminderCard extends StatelessWidget {
  final PartnerHealthView health;
  final LanguageProvider lang;
  const _AncReminderCard({required this.health, required this.lang});

  @override
  Widget build(BuildContext context) {
    final daysLeft = health.nextAncDate!.difference(DateTime.now()).inDays;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TColors.blue500.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: TColors.blue500.withOpacity(0.25))),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: TColors.blue500.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.local_hospital_rounded,
                  color: TColors.blue500, size: 22)),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lang.s('ANC Appointment', 'ANC ቀጠሮ'),
                    style: TextStyle(fontSize: 12,
                        color: TColors.white.withOpacity(0.4))),
                Text(lang.s(
                    'In $daysLeft days — ${health.ancLocation}',
                    'በ$daysLeft ቀናት — ${health.ancLocation}'),
                    style: const TextStyle(
                        fontSize: 14, color: TColors.white,
                        fontWeight: FontWeight.w600)),
                Text(lang.s(
                    'Help arrange transport and go with her',
                    'ትራንስፖርት ያዘጋጁ እና አብሯት ሂዱ'),
                    style: TextStyle(fontSize: 12,
                        color: TColors.blue300.withOpacity(0.7))),
              ],
            )),
          ]),
        ),
      ),
    );
  }
}

// ── WEEK EDUCATION PREVIEW ───────────────────────────────────────
class _WeekEducationPreview extends StatelessWidget {
  final int week;
  final LanguageProvider lang;
  const _WeekEducationPreview({required this.week, required this.lang});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TColors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TColors.white.withOpacity(0.07))),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: TGradients.gradTeal,
              borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.menu_book_rounded,
                color: TColors.white, size: 22)),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lang.s('This week for you', 'ዚህ ሳምንት ለእርስዎ'),
                  style: TextStyle(fontSize: 12,
                      color: TColors.white.withOpacity(0.4))),
              Text(lang.s(
                  'What to cook for her — Week $week',
                  'ሳምንት $week — ምን ማዘጋጀት'),
                  style: const TextStyle(
                      fontSize: 14, color: TColors.white,
                      fontWeight: FontWeight.w600)),
            ],
          )),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: TColors.teal400, size: 14),
        ]),
      ),
    ),
  );
}

// ── QUICK ACTIONS ROW ────────────────────────────────────────────
class _QuickActionsRow extends StatelessWidget {
  final LanguageProvider lang;
  const _QuickActionsRow({required this.lang});

  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: _ActionBtn(
      icon: Icons.phone_rounded,
      label: lang.s('Call 907', '907 ደውሉ'),
      color: TColors.red400,
      onTap: () {},
    )),
    const SizedBox(width: 12),
    Expanded(child: _ActionBtn(
      icon: Icons.chat_bubble_rounded,
      label: lang.s('Message her', 'ደብዳቤ ላኩ'),
      color: TColors.teal500,
      onTap: () {},
    )),
    const SizedBox(width: 12),
    Expanded(child: _ActionBtn(
      icon: Icons.local_hospital_rounded,
      label: lang.s('Nearest hospital', 'ቅርብ ሆስፒታል'),
      color: TColors.blue500,
      onTap: () {},
    )),
  ]);
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label,
      required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.25))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 11, color: color,
                fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
          ]),
        ),
      ),
    ),
  );
}

// ── BOTTOM NAV ───────────────────────────────────────────────────
class _PartnerBottomNav extends StatelessWidget {
  final int selected;
  final int unreadMessages;
  final LanguageProvider lang;
  final ValueChanged<int> onTap;
  const _PartnerBottomNav({
    required this.selected, required this.unreadMessages,
    required this.lang, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        padding: EdgeInsets.fromLTRB(8, 8, 8,
            MediaQuery.of(context).padding.bottom + 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1628).withOpacity(0.85),
          border: Border(top: BorderSide(
              color: TColors.white.withOpacity(0.07)))),
        child: Row(children: [
          _NavItem(Icons.home_rounded, lang.s('Home', 'ቤት'),
              0, selected, onTap),
          _NavItem(Icons.monitor_heart_rounded, lang.s('Health', 'ጤና'),
              1, selected, onTap),
          _NavItem(Icons.menu_book_rounded, lang.s('Learn', 'ተማሩ'),
              2, selected, onTap),
          _NavItemBadge(Icons.chat_bubble_rounded, lang.s('Chat', 'ቻት'),
              3, selected, unreadMessages, onTap),
        ]),
      ),
    ),
  );
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index, selected;
  final ValueChanged<int> onTap;
  const _NavItem(this.icon, this.label, this.index, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected == index
              ? TColors.teal500.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon,
              color: selected == index ? TColors.teal400
                  : TColors.white.withOpacity(0.35),
              size: 22),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(
              fontSize: 10,
              color: selected == index ? TColors.teal400
                  : TColors.white.withOpacity(0.35),
              fontWeight: selected == index
                  ? FontWeight.w700 : FontWeight.w400)),
        ]),
      ),
    ),
  );
}

class _NavItemBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index, selected, badge;
  final ValueChanged<int> onTap;
  const _NavItemBadge(this.icon, this.label, this.index, this.selected,
      this.badge, this.onTap);

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected == index
              ? TColors.teal500.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Stack(children: [
            Icon(icon,
                color: selected == index ? TColors.teal400
                    : TColors.white.withOpacity(0.35),
                size: 22),
            if (badge > 0)
              Positioned(top: -2, right: -4,
                  child: Container(
                    width: 14, height: 14,
                    decoration: const BoxDecoration(
                        color: TColors.red400, shape: BoxShape.circle),
                    child: Center(child: Text('$badge',
                        style: const TextStyle(
                            fontSize: 8, color: TColors.white,
                            fontWeight: FontWeight.w800))))),
          ]),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(
              fontSize: 10,
              color: selected == index ? TColors.teal400
                  : TColors.white.withOpacity(0.35),
              fontWeight: selected == index
                  ? FontWeight.w700 : FontWeight.w400)),
        ]),
      ),
    ),
  );
}

class _Orb extends StatelessWidget {
  final double size; final Color color;
  const _Orb(this.size, this.color);
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color,
            blurRadius: size, spreadRadius: size * 0.2)]));
}
