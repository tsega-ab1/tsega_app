import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../screens/wellness/wellness_screen.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/stage_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/common/tsega_app_bar.dart';
import '../../widgets/common/hamburger_drawer.dart';
import '../../widgets/animations/count_up.dart';
import '../../overlays/quick_log_overlay.dart';
import '../../overlays/ai_chat_overlay.dart';
import '../../overlays/tip_detail_overlay.dart';
import '../../screens/education/education_screen.dart';
import '../../screens/health/health_screen.dart';
import '../../screens/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final pages = [
      _HomeTab(scaffoldKey: _scaffoldKey),
      EducationScreen(scaffoldKey: _scaffoldKey),
      HealthScreen(scaffoldKey: _scaffoldKey),
      ProfileScreen(scaffoldKey: _scaffoldKey),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: const HamburgerDrawer(),
      body: pages[_navIndex],
      bottomNavigationBar: _BottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
      floatingActionButton: _SosFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }
}

// ─── BOTTOM NAV ──────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final items = [
      (Icons.home_rounded, lang.navHome),
      (Icons.menu_book_rounded, lang.navLearn),
      (Icons.local_hospital_rounded, lang.navHealth),
      (Icons.person_rounded, lang.navProfile),
    ];
    return Container(
      decoration: BoxDecoration(
        color: TColors.white,
        boxShadow: [BoxShadow(
          color: TColors.teal700.withOpacity(0.08),
          blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = i == currentIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: selected ? TGradients.gradTeal : null,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(items[i].$1,
                        color: selected ? TColors.white : TColors.gray,
                        size: 22),
                    const SizedBox(height: 3),
                    Text(items[i].$2,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: selected
                              ? FontWeight.w700 : FontWeight.w400,
                          color: selected ? TColors.white : TColors.gray,
                        )),
                  ]),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── SOS FAB ─────────────────────────────────────────────────────
class _SosFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const _EmergencyScreen())),
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
          context.read<LanguageProvider>().holdToActivate)),
      ),
      child: Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          gradient: TGradients.gradEmergency,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(
            color: TColors.red400.withOpacity(0.4),
            blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: const Icon(Icons.emergency_rounded,
            color: TColors.white, size: 24),
      ),
    );
  }
}

// ─── HOME TAB ────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const _HomeTab({required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final stage = context.watch<StageProvider>();
    return stage.isPregnancyMode
        ? _PregnancyHome(scaffoldKey: scaffoldKey)
        : _PeriodHome(scaffoldKey: scaffoldKey);
  }
}

// ─── PERIOD HOME ─────────────────────────────────────────────────
class _PeriodHome extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const _PeriodHome({required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final user = context.watch<UserProvider>();
    final stage = context.watch<StageProvider>();

    return Scaffold(
      backgroundColor: TColors.cream,
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
            child: TsegaAppBar(scaffoldKey: scaffoldKey)),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(delegate: SliverChildListDelegate([
            Text(
              lang.s('Good morning, ${user.greetingName} 👋',
                  'እንደምን አደሩ, ${user.greetingName} 👋'),
              style: TTextStyles.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(lang.s('How are you feeling today?',
                'ዛሬ እንዴት ይሰማዎታል?'),
                style: TTextStyles.bodyLarge),
            const SizedBox(height: 24),
            _CycleVisualizer(
              cycleDay: stage.cycleDay,
              daysUntilPeriod: stage.daysUntilPeriod,
              daysUntilOvulation: stage.daysUntilOvulation,
            ),
            const SizedBox(height: 20),
            _QuickActions(),
            const SizedBox(height: 20),
            const _DailyTipCard(),
            const SizedBox(height: 20),
            _StatsRow(
              stat1Label: lang.s('Cycle Day', 'የዑደት ቀን'),
              stat1Value: stage.cycleDay,
              stat2Label: lang.s('To Period', 'ወደ ወር አበባ'),
              stat2Value: stage.daysUntilPeriod,
              stat3Label: lang.s('To Ovulation', 'ወደ ፅንሰ-ሀሳብ'),
              stat3Value: stage.daysUntilOvulation,
            ),
            const SizedBox(height: 20),
            const _AiInsightCard(),
            const SizedBox(height: 80),
          ])),
        ),
      ]),
    );
  }
}
GestureDetector(
  onTap: () => Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => const WellnessScreen(),
      transitionsBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
            parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 400),
    ),
  ),
  child: Container(/* your button */),
)

// ─── PREGNANCY HOME ──────────────────────────────────────────────
class _PregnancyHome extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const _PregnancyHome({required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final user = context.watch<UserProvider>();
    final stage = context.watch<StageProvider>();
    final week = stage.pregnancyWeek;
    final sizes = AppConstants.babySizes;
    final closest = sizes.keys.isEmpty ? 16 : sizes.keys.reduce((a, b) =>
        (a - week).abs() < (b - week).abs() ? a : b);
    final babySize = sizes[closest] ?? 'growing beautifully';

    return Scaffold(
      backgroundColor: TColors.cream,
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
            child: TsegaAppBar(scaffoldKey: scaffoldKey)),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(delegate: SliverChildListDelegate([
            Text(
              lang.s('Hello, ${user.greetingName} 🌸',
                  'ሰላም, ${user.greetingName} 🌸'),
              style: TTextStyles.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(lang.s('You\'re doing amazing!', 'በጣም ጥሩ ነዎት!'),
                style: TTextStyles.bodyLarge),
            const SizedBox(height: 24),
            _PregnancyHeroCard(
              week: week,
              daysToGo: stage.daysToGo,
              babySize: babySize,
            ),
            const SizedBox(height: 20),
            _PregnancyQuickActions(),
            const SizedBox(height: 20),
            const _DailyTipCard(),
            const SizedBox(height: 20),
            _StatsRow(
              stat1Label: lang.s('Week', 'ሳምንት'),
              stat1Value: week,
              stat2Label: lang.s('Days Left', 'ቀናት ቀርተዋል'),
              stat2Value: stage.daysToGo,
              stat3Label: lang.s('Trimester', 'ሦስት ወር'),
              stat3Value: week <= 12 ? 1 : week <= 26 ? 2 : 3,
            ),
            const SizedBox(height: 20),
            const _AiInsightCard(),
            const SizedBox(height: 20),
            const _DangerSignsCard(),
            const SizedBox(height: 80),
          ])),
        ),
      ]),
    );
  }
}

// ─── CYCLE VISUALIZER ────────────────────────────────────────────
class _CycleVisualizer extends StatelessWidget {
  final int cycleDay, daysUntilPeriod, daysUntilOvulation;
  const _CycleVisualizer({
    required this.cycleDay,
    required this.daysUntilPeriod,
    required this.daysUntilOvulation,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: TGradients.gradPink,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(
          color: TColors.pink500.withOpacity(0.3),
          blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(children: [
        SizedBox(
          width: 100, height: 100,
          child: Stack(alignment: Alignment.center, children: [
            CircularProgressIndicator(
              value: cycleDay / 28,
              backgroundColor: TColors.white.withOpacity(0.3),
              color: TColors.white,
              strokeWidth: 8,
            ),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text('$cycleDay',
                  style: const TextStyle(fontSize: 28,
                      color: TColors.white, fontWeight: FontWeight.w700)),
              Text(lang.s('Day', 'ቀን'),
                  style: TextStyle(fontSize: 12,
                      color: TColors.white.withOpacity(0.8))),
            ]),
          ]),
        ),
        const SizedBox(width: 24),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CStat(
              icon: Icons.water_drop_rounded,
              label: lang.s('Period in', 'ወር አበባ በ'),
              value: lang.s('$daysUntilPeriod days',
                  '$daysUntilPeriod ቀናት'),
            ),
            const SizedBox(height: 12),
            _CStat(
              icon: Icons.favorite_rounded,
              label: lang.s('Ovulation in', 'ፅንሰ-ሀሳብ በ'),
              value: lang.s('$daysUntilOvulation days',
                  '$daysUntilOvulation ቀናት'),
            ),
          ],
        )),
      ]),
    );
  }
}

class _CStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _CStat({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: TColors.white.withOpacity(0.9), size: 16),
    const SizedBox(width: 8),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 11,
          color: TColors.white.withOpacity(0.75))),
      Text(value, style: const TextStyle(fontSize: 14,
          color: TColors.white, fontWeight: FontWeight.w700)),
    ]),
  ]);
}

// ─── PREGNANCY HERO CARD ─────────────────────────────────────────
class _PregnancyHeroCard extends StatelessWidget {
  final int week, daysToGo;
  final String babySize;
  const _PregnancyHeroCard({
    required this.week, required this.daysToGo, required this.babySize});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: TGradients.gradTeal,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(
          color: TColors.teal700.withOpacity(0.3),
          blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(lang.s('Week $week', 'ሳምንት $week'),
                  style: const TextStyle(fontSize: 36,
                      color: TColors.white, fontWeight: FontWeight.w800)),
              Text(lang.s('of Pregnancy', 'የእርግዝና'),
                  style: TextStyle(fontSize: 14,
                      color: TColors.white.withOpacity(0.8))),
            ]),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: TColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14)),
              child: Column(children: [
                Text('$daysToGo',
                    style: const TextStyle(fontSize: 24,
                        color: TColors.white, fontWeight: FontWeight.w700)),
                Text(lang.s('days left', 'ቀናት ቀርተዋል'),
                    style: TextStyle(fontSize: 11,
                        color: TColors.white.withOpacity(0.8))),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: TColors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const Icon(Icons.child_care_rounded,
                color: TColors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(
              lang.s('Baby is the size of $babySize',
                  'ልጅዎ የ $babySize መጠን ነው'),
              style: const TextStyle(color: TColors.white,
                  fontSize: 13, fontWeight: FontWeight.w500),
            )),
          ]),
        ),
      ]),
    );
  }
}

// ─── QUICK ACTIONS ───────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final items = [
      (Icons.edit_note_rounded, lang.logToday, TColors.pink500,
       () => _showLog(context)),
      (Icons.calendar_month_rounded, lang.s('Calendar', 'ቀን'),
       TColors.teal500, () {}),
      (Icons.psychology_rounded, lang.s('AI', 'AI'),
       TColors.blue500, () => _showAi(context)),
    ];
    return Row(
      children: List.generate(items.length, (i) => Expanded(
        child: GestureDetector(
          onTap: items[i].$4,
          child: Container(
            margin: EdgeInsets.only(right: i < items.length - 1 ? 12 : 0),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: TColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                color: TColors.teal700.withOpacity(0.06),
                blurRadius: 12, offset: const Offset(0, 3))],
            ),
            child: Column(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: items[i].$3.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12)),
                child: Icon(items[i].$1, color: items[i].$3, size: 22),
              ),
              const SizedBox(height: 8),
              Text(items[i].$2, style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: TColors.dark),
                  textAlign: TextAlign.center),
            ]),
          ),
        ),
      )),
    );
  }

  void _showLog(BuildContext ctx) => showModalBottomSheet(
      context: ctx, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const QuickLogOverlay());

  void _showAi(BuildContext ctx) => showModalBottomSheet(
      context: ctx, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AiChatOverlay());
}

// ─── PREGNANCY QUICK ACTIONS ─────────────────────────────────────
class _PregnancyQuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final items = [
      (Icons.touch_app_rounded, lang.kickCounter, TColors.teal500, () {}),
      (Icons.calendar_view_week_rounded, lang.weekByWeek, TColors.blue500, () {}),
      (Icons.note_add_rounded, lang.logSymptoms, TColors.pink500, () {}),
    ];
    return Row(
      children: List.generate(items.length, (i) => Expanded(
        child: GestureDetector(
          onTap: items[i].$4,
          child: Container(
            margin: EdgeInsets.only(right: i < items.length - 1 ? 12 : 0),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: TColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                color: TColors.teal700.withOpacity(0.06),
                blurRadius: 12, offset: const Offset(0, 3))],
            ),
            child: Column(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: items[i].$3.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12)),
                child: Icon(items[i].$1, color: items[i].$3, size: 22),
              ),
              const SizedBox(height: 8),
              Text(items[i].$2, style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: TColors.dark),
                  textAlign: TextAlign.center),
            ]),
          ),
        ),
      )),
    );
  }
}

// ─── DAILY TIP CARD ──────────────────────────────────────────────
class _DailyTipCard extends StatelessWidget {
  const _DailyTipCard();

  static const _tipsEn = [
    ('Stay Hydrated', 'Drink at least 8 glasses of water today. Dehydration worsens cramps and fatigue during your cycle.'),
    ('Iron-Rich Foods', 'Lentils (misir), spinach (gomen), and teff are excellent iron sources — especially important during menstruation.'),
    ('Folic Acid', 'Take 400mcg of folic acid daily if planning pregnancy. Prevents neural tube defects in the first weeks.'),
    ('Know Your Body', 'Track your basal body temperature to identify your fertile window more accurately.'),
    ('Rest is Medicine', 'Quality sleep regulates hormones. Aim for 7-9 hours especially in the second half of your cycle.'),
    ('Altitude & Hb', 'At Addis Ababa altitude (2,300m), normal hemoglobin is slightly higher than lowland values.'),
    ('Danger Signs', 'Severe headache, blurred vision, or sudden swelling during pregnancy — go to hospital immediately.'),
    ('Move Your Body', 'Light walking for 20 minutes improves circulation and reduces period cramps.'),
    ('Teff Nutrition', 'Teff injera contains more calcium and iron than wheat bread — excellent during pregnancy.'),
    ('ANC Visits', 'WHO recommends 8 ANC visits during pregnancy. Missing visits increases risk of complications.'),
    ('Iron Absorption', 'Eat vitamin C-rich foods (tomatoes, oranges) alongside lentils to boost iron absorption.'),
    ('Gestational Diabetes', 'Shiro and lentils have lower glycemic index than white rice — better for blood sugar control.'),
    ('Preeclampsia Watch', 'Monitor your blood pressure from week 20. Headache + swelling = go to hospital.'),
    ('Postpartum Care', 'Rest for at least 40 days after birth. Let family support you during recovery.'),
    ('Breastfeeding', 'Breastfeed within 1 hour of birth. Colostrum (first milk) protects your baby from infection.'),
  ];

  static const _tipsAm = [
    ('እርጥብ ሁኑ', 'ዛሬ ቢያንስ 8 ብርጭቆ ውሃ ይጠጡ። ውሃ ማጣት የወር አበባ ህመምን እና ድካምን ያባብሳል።'),
    ('ብረት ያለው ምግብ', 'ምስር፣ ጎመን፣ እና ጤፍ ጥሩ የብረት ምንጮች ናቸው — በወር አበባ ወቅት በጣም አስፈላጊ።'),
    ('ፎሊክ አሲድ', 'እርግዝናን ካቀዱ በቀን 400 ሚ.ግ. ፎሊክ አሲድ ይውሰዱ። የነርቭ ቱቦ ጉዳቶችን ይከላከላል።'),
    ('አካልዎን ይወቁ', 'ፈጣን የሙቀት መሠረትዎን ይከታተሉ — ይህ ፈጠራ መስኮትዎን ያሳያል።'),
    ('እረፍት መድሃኒት ነው', 'ጥሩ እንቅልፍ ሆርሞኖችን ይቆጣጠራል። 7-9 ሰዓት ይሂዱ።'),
    ('ከፍታ እና Hb', 'በአዲስ አበባ ከፍታ (2,300 ሜ.)፣ የተለመደ ሄሞግሎቢን ከዝቅተኛ ቦታ ትንሽ ከፍ ያለ ነው።'),
    ('አደጋ ምልክቶች', 'ከፍተኛ ራስ ምታት፣ ደብዛዛ ዕይታ፣ ወይም ማበጥ — ወዲያውኑ ሆስፒታል ይሂዱ።'),
    ('አካልዎን ያንቀሳቅሱ', 'ለ20 ደቂቃ ቀላል ልምምድ ደም ዝውውርን ያሻሽላል እና ህመምን ይቀንሳል።'),
    ('የጤፍ አመጋገብ', 'የጤፍ እንጀራ ከስንዴ ዳቦ የበለጠ ካልሲዩም እና ብረት ይዟል — በእርግዝና ጥሩ ነው።'),
    ('ANC ጉብኝቶች', 'WHO 8 ANC ጉብኝቶችን ይመክራል። ጉብኝቶችን መዝለል ያልተገኙ ችግሮችን ያባብሳል።'),
    ('ብረት መሳብ', 'ምስርን ከቲማቲም ወይም ብርቱካን ጋር ይ召し食べ — ቫይታሚን C ብረት መሳብን ያሻሽላል።'),
    ('የስኳር ምርት', 'ሽሮ እና ምስር ከነጭ ሩዝ ያነሰ ስኳር ያወጣሉ — የደም ስኳርን ለመቆጣጠር ጥሩ ናቸው።'),
    ('ቅድመ-ወሊድ ከፍተኛ ደም ግፊት', 'ከሳምንት 20 ጀምሮ ደም ግፊትዎን ይከታተሉ። ራስ ምታት + ማበጥ = ሆስፒታል።'),
    ('ድህረ-ወሊድ ክብካቤ', 'ከወሊድ በኋላ ቢያንስ 40 ቀን ያርፉ። ቤተሰቦ ይርዳዎ።'),
    ('ጡት ማጥባት', 'ከወሊድ በ1 ሰዓት ውስጥ ጡት ያጥቡ። ኮሎስትረም (የመጀመሪያ ወተት) ልጅዎን ከኢንፌክሽን ይከላከላል።'),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final idx = DateTime.now().day % _tipsEn.length;
    final tipEn = _tipsEn[idx];
    final tipAm = _tipsAm[idx];
    final title = lang.isAmharic ? tipAm.$1 : tipEn.$1;
    final body = lang.isAmharic ? tipAm.$2 : tipEn.$2;
    final preview = body.length > 65 ? '${body.substring(0, 65)}...' : body;

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => TipDetailOverlay(
          titleEn: tipEn.$1, titleAm: tipAm.$1,
          bodyEn: tipEn.$2, bodyAm: tipAm.$2,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: TGradients.gradTeal,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(
            color: TColors.teal700.withOpacity(0.2),
            blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: TColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.lightbulb_rounded,
                color: TColors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lang.s('Daily Tip', 'የዕለቱ ምክር'),
                  style: TextStyle(fontSize: 11,
                      color: TColors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(title, style: const TextStyle(fontSize: 15,
                  color: TColors.white, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(preview, style: TextStyle(fontSize: 12,
                  color: TColors.white.withOpacity(0.8))),
            ],
          )),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: TColors.white, size: 14),
        ]),
      ),
    );
  }
}

// ─── STATS ROW ───────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final String stat1Label, stat2Label, stat3Label;
  final int stat1Value, stat2Value, stat3Value;
  const _StatsRow({
    required this.stat1Label, required this.stat1Value,
    required this.stat2Label, required this.stat2Value,
    required this.stat3Label, required this.stat3Value,
  });

  @override
  Widget build(BuildContext context) => Row(children: [
    _SC(label: stat1Label, value: stat1Value, color: TColors.teal500),
    const SizedBox(width: 12),
    _SC(label: stat2Label, value: stat2Value, color: TColors.pink500),
    const SizedBox(width: 12),
    _SC(label: stat3Label, value: stat3Value, color: TColors.blue500),
  ]);
}

class _SC extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _SC({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
          color: TColors.teal700.withOpacity(0.06),
          blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(children: [
        CountUpWidget(end: value, color: color, fontSize: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(
            fontSize: 10, color: TColors.gray,
            fontWeight: FontWeight.w500),
            textAlign: TextAlign.center),
      ]),
    ),
  );
}

// ─── AI INSIGHT CARD ─────────────────────────────────────────────
class _AiInsightCard extends StatelessWidget {
  const _AiInsightCard();

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final stage = context.watch<StageProvider>();
    final insightEn = stage.isPregnancyMode
        ? 'Hemoglobin trend is stable. Continue your supplement routine and attend your next ANC visit on schedule.'
        : 'Cycle appears regular at 28 days. Fertile window approaching in ${stage.daysUntilOvulation > 2 ? stage.daysUntilOvulation - 2 : 0} days.';
    final insightAm = stage.isPregnancyMode
        ? 'የሄሞግሎቢን አዝማሚያ ተረጋግጧል። ቀጣዩን ANC ጉብኝት ወቅቱን ጠብቀው ይሄዱ።'
        : 'ዑደቶ በ28 ቀናት ተቀናጅቷል። ፈጠራ መስኮት በ${stage.daysUntilOvulation > 2 ? stage.daysUntilOvulation - 2 : 0} ቀናት ይጀምራል።';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TColors.teal100),
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
              borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.psychology_rounded,
                color: TColors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(lang.s('AI Insight', 'AI ምንጭ'),
              style: TTextStyles.headlineSmall),
        ]),
        const SizedBox(height: 14),
        Text(lang.isAmharic ? insightAm : insightEn,
            style: TTextStyles.bodyMedium.copyWith(height: 1.6)),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const AiChatOverlay()),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: TGradients.gradTeal,
              borderRadius: BorderRadius.circular(10)),
            child: Text(lang.s('Ask AI', 'AI ጠይቅ'),
                style: const TextStyle(color: TColors.white,
                    fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ),
      ]),
    );
  }
}

// ─── DANGER SIGNS CARD ───────────────────────────────────────────
class _DangerSignsCard extends StatelessWidget {
  const _DangerSignsCard();

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.red100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.red400.withOpacity(0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.warning_amber_rounded,
            color: TColors.red400, size: 28),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.s('Know danger signs', 'አደጋ ምልክቶቹን ይወቁ'),
                style: const TextStyle(fontWeight: FontWeight.w700,
                    color: TColors.dark, fontSize: 14)),
            Text(lang.s(
                'Severe headache · Blurred vision · Heavy bleeding',
                'ከፍተኛ ራስ ምታት · ደብዛዛ ዕይታ · ደም መፍሰስ'),
                style: const TextStyle(fontSize: 12, color: TColors.mid)),
          ],
        )),
        const Icon(Icons.arrow_forward_ios_rounded,
            color: TColors.red400, size: 16),
      ]),
    );
  }
}

// ─── EMERGENCY SCREEN ────────────────────────────────────────────
class _EmergencyScreen extends StatelessWidget {
  const _EmergencyScreen();

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFC0392B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emergency_rounded,
                  color: TColors.white, size: 80),
              const SizedBox(height: 24),
              Text(lang.emergencySos,
                  style: const TextStyle(fontSize: 32,
                      color: TColors.white, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(lang.s(
                  'Your emergency contacts will be notified',
                  'የአደጋ ዕውቂያዎ ያሳወቃሉ'),
                  style: TextStyle(color: TColors.white.withOpacity(0.8)),
                  textAlign: TextAlign.center),
              const SizedBox(height: 48),
              _EBtn(icon: Icons.phone_rounded,
                  en: 'Call 907 — Ambulance',
                  am: '907 ደውሉ — አምቡላንስ',
                  solid: true),
              const SizedBox(height: 16),
              _EBtn(icon: Icons.medical_services_rounded,
                  en: 'First Aid Guide',
                  am: 'የመጀመሪያ እርዳታ'),
              const SizedBox(height: 16),
              _EBtn(icon: Icons.local_hospital_rounded,
                  en: 'Nearest Hospital',
                  am: 'ቅርብ ሆስፒታል'),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(lang.close,
                    style: TextStyle(
                        color: TColors.white.withOpacity(0.7),
                        fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EBtn extends StatelessWidget {
  final IconData icon;
  final String en, am;
  final bool solid;
  const _EBtn({required this.icon, required this.en,
      required this.am, this.solid = false});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: solid ? TColors.white : TColors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon,
            color: solid ? TColors.red500 : TColors.white, size: 22),
        const SizedBox(width: 12),
        Text(lang.isAmharic ? am : en,
            style: TextStyle(
                color: solid ? TColors.red500 : TColors.white,
                fontWeight: FontWeight.w700, fontSize: 16)),
      ]),
    );
  }
}
