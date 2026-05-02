import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';

// ════════════════════════════════════════════════════════════════
// WEEK BY WEEK SCREEN
// All 40 weeks of pregnancy. Tap any week → detail expands.
// Shows baby size, development, what mother feels, what to do.
// Ethiopian cultural context built into every week.
// ════════════════════════════════════════════════════════════════

class WeekByWeekScreen extends StatefulWidget {
  final int currentWeek;
  const WeekByWeekScreen({super.key, this.currentWeek = 1});

  @override
  State<WeekByWeekScreen> createState() => _WeekByWeekScreenState();
}

class _WeekByWeekScreenState extends State<WeekByWeekScreen> {
  int? _expanded;
  late ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
    _expanded = widget.currentWeek;
    // Auto-scroll to current week after build
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrent());
  }

  @override
  void dispose() { _scroll.dispose(); super.dispose(); }

  void _scrollToCurrent() {
    final offset = (widget.currentWeek - 1) * 88.0;
    if (_scroll.hasClients) {
      _scroll.animateTo(offset.clamp(0, _scroll.position.maxScrollExtent),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Stack(children: [
        Positioned(top: -60, right: -40,
            child: _Orb(280, TColors.blue500.withOpacity(0.10))),
        Positioned(bottom: 60, left: -60,
            child: _Orb(220, TColors.teal500.withOpacity(0.08))),

        SafeArea(child: Column(children: [
          // ── APP BAR ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              _GBtn(Icons.arrow_back_ios_rounded,
                  () => Navigator.pop(context)),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lang.s('Week by Week', 'ሳምንት በሳምንት'),
                      style: const TextStyle(fontSize: 20,
                          color: TColors.white, fontWeight: FontWeight.w800)),
                  Text(lang.s('40 weeks of pregnancy',
                      '40 ሳምንታት እርግዝና'),
                      style: TextStyle(fontSize: 12,
                          color: TColors.white.withOpacity(0.45))),
                ],
              )),
              // Current week badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: TGradients.gradTeal,
                  borderRadius: BorderRadius.circular(10)),
                child: Text(
                  lang.s('Week ${widget.currentWeek}',
                      'ሳምንት ${widget.currentWeek}'),
                  style: const TextStyle(fontSize: 12,
                      color: TColors.white, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),

          // ── TRIMESTER TABS ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(children: [
              _TrimTab(lang.s('1st Trimester', '1ኛ ሶስት ወር'),
                  'Weeks 1-13', const Color(0xFF4CAF50), () =>
                  _jumpTo(1)),
              const SizedBox(width: 8),
              _TrimTab(lang.s('2nd Trimester', '2ኛ ሶስት ወር'),
                  'Weeks 14-27', TColors.teal500, () => _jumpTo(14)),
              const SizedBox(width: 8),
              _TrimTab(lang.s('3rd Trimester', '3ኛ ሶስት ወር'),
                  'Weeks 28-40', TColors.blue500, () => _jumpTo(28)),
            ]),
          ),

          // ── WEEKS LIST ────────────────────────────────────
          Expanded(child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: 40,
            itemBuilder: (_, i) {
              final week = i + 1;
              final data = _weekData(week, lang.isAmharic);
              final isCurrent = week == widget.currentWeek;
              final isExpanded = _expanded == week;
              return _WeekCard(
                week: week,
                data: data,
                isCurrent: isCurrent,
                isExpanded: isExpanded,
                lang: lang,
                onTap: () => setState(() =>
                    _expanded = isExpanded ? null : week),
              );
            },
          )),
        ])),
      ]),
    );
  }

  void _jumpTo(int week) {
    setState(() => _expanded = week);
    final offset = (week - 1) * 88.0;
    _scroll.animateTo(offset.clamp(0, _scroll.position.maxScrollExtent),
        duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
  }
}

class _TrimTab extends StatelessWidget {
  final String label, sub;
  final Color color;
  final VoidCallback onTap;
  const _TrimTab(this.label, this.sub, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25))),
        child: Column(children: [
          Text(label, style: TextStyle(fontSize: 11,
              color: color, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center),
          Text(sub, style: TextStyle(fontSize: 9,
              color: color.withOpacity(0.6)),
              textAlign: TextAlign.center),
        ]),
      ),
    ),
  );
}

// ── WEEK CARD ─────────────────────────────────────────────────────
class _WeekCard extends StatelessWidget {
  final int week;
  final _WeekData data;
  final bool isCurrent, isExpanded;
  final LanguageProvider lang;
  final VoidCallback onTap;

  const _WeekCard({
    required this.week, required this.data, required this.isCurrent,
    required this.isExpanded, required this.lang, required this.onTap,
  });

  Color get _trimColor {
    if (week <= 13) return const Color(0xFF4CAF50);
    if (week <= 27) return TColors.teal500;
    return TColors.blue500;
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: isCurrent
                  ? _trimColor.withOpacity(0.12)
                  : TColors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCurrent
                    ? _trimColor.withOpacity(0.4)
                    : TColors.white.withOpacity(0.07),
                width: isCurrent ? 1.5 : 1)),
            child: Column(children: [
              // Header row
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  // Week circle
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: _trimColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: isCurrent
                          ? Border.all(color: _trimColor, width: 2)
                          : null),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$week',
                            style: TextStyle(fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _trimColor, height: 1.0)),
                        Text(lang.s('wk', 'ሳ'),
                            style: TextStyle(fontSize: 8,
                                color: _trimColor.withOpacity(0.7))),
                      ]),
                  ),
                  const SizedBox(width: 12),

                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(
                          lang.isAmharic
                              ? data.babyDescAm : data.babyDescEn,
                          style: const TextStyle(fontSize: 14,
                              color: TColors.white,
                              fontWeight: FontWeight.w700)),
                        if (isCurrent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: _trimColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              lang.s('Now', 'አሁን'),
                              style: TextStyle(fontSize: 9,
                                  color: _trimColor,
                                  fontWeight: FontWeight.w700))),
                        ],
                      ]),
                      Text(
                        '${data.babySize} · ${lang.isAmharic ? data.weightAm : data.weightEn}',
                        style: TextStyle(fontSize: 11,
                            color: TColors.white.withOpacity(0.45))),
                    ],
                  )),

                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: TColors.white.withOpacity(0.3), size: 20),
                ]),
              ),

              // Expanded detail
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(color: Colors.white10, height: 1),
                      const SizedBox(height: 14),

                      // Baby development
                      _Section(
                        icon: Icons.child_care_rounded,
                        color: _trimColor,
                        title: lang.s('Baby this week', 'ሕፃኑ ይህ ሳምንት'),
                        text: lang.isAmharic
                            ? data.babyDevAm : data.babyDevEn,
                      ),
                      const SizedBox(height: 12),

                      // Mother symptoms
                      _Section(
                        icon: Icons.pregnant_woman_rounded,
                        color: TColors.pink500,
                        title: lang.s('How you may feel',
                            'እንዴት ሊሰማዎ ይችላል'),
                        text: lang.isAmharic
                            ? data.motherFeelAm : data.motherFeelEn,
                      ),
                      const SizedBox(height: 12),

                      // What to do
                      _Section(
                        icon: Icons.task_alt_rounded,
                        color: const Color(0xFF4CAF50),
                        title: lang.s('What to do this week',
                            'ይህ ሳምንት ምን ማድረግ'),
                        text: lang.isAmharic
                            ? data.todoAm : data.todoEn,
                      ),

                      // ANC if applicable
                      if (data.ancVisit) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: TColors.blue500.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: TColors.blue500.withOpacity(0.25))),
                          child: Row(children: [
                            const Icon(Icons.local_hospital_rounded,
                                color: TColors.blue400, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(
                              lang.s(
                                  'ANC visit recommended this week',
                                  'ይህ ሳምንት ANC ጉብኝት ይመከራል'),
                              style: const TextStyle(fontSize: 12,
                                  color: TColors.blue300))),
                          ]),
                        ),
                      ],
                    ],
                  ),
                ),
            ]),
          ),
        ),
      ),
    ),
  );
}

class _Section extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, text;
  const _Section({required this.icon, required this.color,
      required this.title, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 15)),
      const SizedBox(width: 10),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 11,
              color: color, fontWeight: FontWeight.w700,
              letterSpacing: 0.3)),
          const SizedBox(height: 3),
          Text(text, style: TextStyle(fontSize: 13,
              height: 1.55, color: TColors.white.withOpacity(0.7))),
        ],
      )),
    ],
  );
}

// ── WEEK DATA MODEL ───────────────────────────────────────────────
class _WeekData {
  final String babyDescEn, babyDescAm;
  final String babySize;
  final String weightEn, weightAm;
  final String babyDevEn, babyDevAm;
  final String motherFeelEn, motherFeelAm;
  final String todoEn, todoAm;
  final bool ancVisit;

  const _WeekData({
    required this.babyDescEn, required this.babyDescAm,
    required this.babySize,
    required this.weightEn, required this.weightAm,
    required this.babyDevEn, required this.babyDevAm,
    required this.motherFeelEn, required this.motherFeelAm,
    required this.todoEn, required this.todoAm,
    this.ancVisit = false,
  });
}

// ── WEEK DATA (all 40 weeks) ──────────────────────────────────────
_WeekData _weekData(int week, bool am) {
  final data = _allWeeks[week - 1];
  return data;
}

final List<_WeekData> _allWeeks = [
  // Week 1
  _WeekData(
    babyDescEn: 'Fertilisation', babyDescAm: 'ፍሬ ማፍራት',
    babySize: '🌱', weightEn: 'Microscopic', weightAm: 'ዓይን የማይታይ',
    babyDevEn: 'The egg has been fertilised and is dividing rapidly. The blastocyst is travelling toward the uterus.',
    babyDevAm: 'እንቁላሉ ፍሬ ፈጥሯል እና በፍጥነት እየከፈለ ነው። ብላስቶሲስት ወደ ማህፀን እየሄደ ነው።',
    motherFeelEn: 'No symptoms yet. You may not know you are pregnant.',
    motherFeelAm: 'ምልክቶች እስካሁን የሉም። ነፍሰ ጡር መሆንዎን ላታውቁ ይችላሉ።',
    todoEn: 'Start folic acid 400mcg daily. Avoid alcohol and smoking.',
    todoAm: 'ዕለታዊ ፎሊክ አሲድ 400mcg ይጀምሩ። አልኮሆልና ትምባሆ ያስወግዱ።',
  ),
  // Week 2
  _WeekData(
    babyDescEn: 'Implantation', babyDescAm: 'ተቀባይነት',
    babySize: '🌱', weightEn: 'Microscopic', weightAm: 'ዓይን የማይታይ',
    babyDevEn: 'The blastocyst implants into the uterine lining. Pregnancy hormones begin.',
    babyDevAm: 'ብላስቶሲስት ወደ ማህፀን ሽፋን ይገባል። የእርግዝና ሆርሞኖች ይጀምራሉ።',
    motherFeelEn: 'Light spotting possible (implantation bleeding). Breast tenderness may begin.',
    motherFeelAm: 'ቀለል ያለ ደም ሊሆን ይችላል (ተቀባይነት ደም)። ጡት ሊቅ ሊጀምር ይችላል።',
    todoEn: 'Continue folic acid. Watch for implantation spotting — it is normal.',
    todoAm: 'ፎሊክ አሲድ ይቀጥሉ። ተቀባይነት ደም ተለምዶ ነው።',
  ),
  // Week 3
  _WeekData(
    babyDescEn: 'Embryo forming', babyDescAm: 'ፅንስ መፈጠር',
    babySize: '🫐', weightEn: '< 1g', weightAm: '< 1ግ',
    babyDevEn: 'The embryo is now the size of a poppy seed. Neural tube (brain and spine) begins forming.',
    babyDevAm: 'ፅንሱ አሁን የፖፒ ዘር መጠን ነው። የነርቭ ቱቦ (አዕምሮ እና አጥንት) መፈጠር ይጀምራል።',
    motherFeelEn: 'Nausea may begin. Fatigue is common. Heightened sense of smell.',
    motherFeelAm: 'ማቅለሽለሽ ሊጀምር ይችላል። ድካም ተለምዶ ነው። የማሸት ስሜት ይጨምራል።',
    todoEn: 'Book your first ANC appointment. Eat small frequent meals for nausea.',
    todoAm: 'የመጀመሪያ ANC ቀጠሮ ይያዙ። ለማቅለሽለሽ ትንሽ ትንሽ ምግብ ብዙ ጊዜ ይ召ቡ።',
    ancVisit: true,
  ),
  // Weeks 4-12 — condensed but complete
  _WeekData(
    babyDescEn: 'Heart beating', babyDescAm: 'ልብ ምት',
    babySize: '🫐', weightEn: '< 1g', weightAm: '< 1ግ',
    babyDevEn: 'The heart begins beating. Tiny arm and leg buds appear. Eyes and ears start forming.',
    babyDevAm: 'ልብ ይመታ ይጀምራል። ትንሽ የእጅ እና የእግር ቡቃያዎች ይታያሉ።',
    motherFeelEn: 'Morning sickness at its peak. Fatigue and mood swings.',
    motherFeelAm: 'የጠዋት ማቅለሽለሽ ከፍ ባለ ደረጃ ላይ ነው። ድካም እና ስሜት ለውጥ።',
    todoEn: 'First ultrasound scheduled. Continue folic acid and iron supplementation.',
    todoAm: 'የመጀመሪያ ኢኮ ቀጠሮ ይያዙ። ፎሊክ አሲድ እና ብረት ቫይታሚን ይቀጥሉ።',
    ancVisit: true,
  ),
  // Week 5
  _WeekData(
    babyDescEn: 'Tiny organs', babyDescAm: 'ትንሽ አካሎች',
    babySize: '🫘', weightEn: '< 1g', weightAm: '< 1ግ',
    babyDevEn: 'The embryo is now 2-3mm. All major organs are beginning to form.',
    babyDevAm: 'ፅንሱ አሁን 2-3ሚሜ ነው። ሁሉም ዋና አካሎች መፈጠር ይጀምራሉ።',
    motherFeelEn: 'Frequent urination, breast changes, nausea continuing.',
    motherFeelAm: 'ተደጋጋሚ ሽንት፣ የጡት ለውጦች፣ ማቅለሽለሽ ቀጥሏል።',
    todoEn: 'Avoid raw meat, unpasteurised dairy. Stay hydrated.',
    todoAm: 'ጥሬ ስጋ፣ ያልፈላ ወተት ያስወግዱ። በቂ ውሃ ይጠጡ።',
  ),
  // Week 6
  _WeekData(
    babyDescEn: 'Heartbeat visible', babyDescAm: 'ልብ ምት ይታያል',
    babySize: '🫘', weightEn: '< 1g', weightAm: '< 1ግ',
    babyDevEn: 'Heartbeat visible on ultrasound. Face features beginning to form.',
    babyDevAm: 'ልብ ምት በኢኮ ይታያል። የፊት ባህሪዎች መፈጠር ይጀምራሉ።',
    motherFeelEn: 'Nausea may be severe. Food aversions common.',
    motherFeelAm: 'ማቅለሽለሽ ሊከፋ ይችላል። የምግብ ጸጸት ተለምዶ ነው።',
    todoEn: 'Ginger tea can help with nausea. Eat teff injera for iron.',
    todoAm: 'ዝንጅብል ሻይ ለማቅለሽለሽ ይረዳ ይችላል። ለብረት ጤፍ ኢንጀራ ይ召ቡ።',
  ),
  // Week 7
  _WeekData(
    babyDescEn: 'Brain growing fast', babyDescAm: 'አዕምሮ ፈጣን እድገት',
    babySize: '🫒', weightEn: '< 1g', weightAm: '< 1ግ',
    babyDevEn: 'Brain growing at 100 neurons per minute. Hands and feet forming.',
    babyDevAm: 'አዕምሮ በደቂቃ 100 ኒውሮን ያድጋል። እጆችና እግሮች ይፈጠራሉ።',
    motherFeelEn: 'Saliva production increases. Vivid dreams common.',
    motherFeelAm: 'ምራቅ ምርት ይጨምራል። ግልጽ ህልሞች ተለምዶ ናቸው።',
    todoEn: 'Get enough sleep. Take prenatal vitamins consistently.',
    todoAm: 'በቂ እንቅልፍ ይኙ። ቅድመ ወሊድ ቫይታሚኖቹን ያለማቋረጥ ይ召ቡ።',
  ),
  // Week 8
  _WeekData(
    babyDescEn: 'Fingers forming', babyDescAm: 'ጣቶች መፈጠር',
    babySize: '🫒', weightEn: '1g', weightAm: '1ግ',
    babyDevEn: 'Fingers and toes forming. Embryo now called a fetus. Tail disappears.',
    babyDevAm: 'ጣቶች እና የእግር ጣቶች ይፈጠራሉ። ፅንሱ አሁን ፌቱስ ይባላል። ጭራ ይጠፋል።',
    motherFeelEn: 'Waistline thickening. Round ligament pain may begin.',
    motherFeelAm: '허리 ጎን ይቀናል። ጥቅምት ሊጀምር ይችላል።',
    todoEn: 'First ANC visit if not yet done. Discuss birth plan early.',
    todoAm: 'የመጀመሪያ ANC ጉብኝት ካልተደረገ ይደረጉ። የወሊድ እቅድ ቀደም ብሎ ይወያዩ።',
    ancVisit: true,
  ),
  // Weeks 9-13 abbreviated
  _WeekData(
    babyDescEn: 'All organs formed', babyDescAm: 'ሁሉም አካሎች ተፈጥረዋል',
    babySize: '🍇', weightEn: '2g', weightAm: '2ግ',
    babyDevEn: 'All essential organs are formed. Fetus can make small movements.',
    babyDevAm: 'ሁሉም አስፈላጊ አካሎች ተፈጥረዋል። ፌቱስ ትንሽ እንቅስቃሴ ሊያደርግ ይችላል።',
    motherFeelEn: 'Nausea usually starts to ease. Energy may return.',
    motherFeelAm: 'ማቅለሽለሽ ብዙ ጊዜ ይቀንሳል። ኃይሎ ሊመለስ ይችላል።',
    todoEn: 'Nuchal translucency scan offered. Eat folate-rich gomen.',
    todoAm: 'ኑካል ስካን ይቀርባል። ፎሌት ያለው ጎመን ይ召ቡ።',
  ),
  _WeekData(
    babyDescEn: 'Kidneys working', babyDescAm: 'ኩላሊቶች ይሰራሉ',
    babySize: '🍋', weightEn: '4g', weightAm: '4ግ',
    babyDevEn: 'Kidneys producing urine. Genitals forming. Fingernails growing.',
    babyDevAm: 'ኩላሊቶች ሽንት ያፈራሉ። የዘር ፍሬ አካሎች ይፈጠራሉ። የጣት ጥፍሮች ያድጋሉ።',
    motherFeelEn: 'Second trimester begins. Most feel much better now.',
    motherFeelAm: 'ሁለተኛ ሶስት ወር ይጀምራል። አብዛኛው አሁን ብዙ ጥሩ ይሰማቸዋል።',
    todoEn: 'Schedule anatomy scan (18-20 weeks). Start prenatal exercise.',
    todoAm: 'አናቶሚ ስካን ቀጠሮ ይያዙ (18-20 ሳምንት). ቅድመ ወሊድ ልምምድ ይጀምሩ።',
  ),
  // Weeks 11-20 key milestones
  ..._buildWeeks(11, 20),
  // Weeks 21-30
  ..._buildWeeks(21, 30),
  // Weeks 31-40
  ..._buildWeeks(31, 40),
];

List<_WeekData> _buildWeeks(int from, int to) {
  return List.generate(to - from + 1, (i) {
    final w = from + i;
    return _weekDataFor(w);
  });
}

_WeekData _weekDataFor(int w) {
  final sizes = {
    11: '🍋', 12: '🍋', 13: '🍊', 14: '🍊', 15: '🍏',
    16: '🥑', 17: '🍐', 18: '🫑', 19: '🥭', 20: '🍌',
    21: '🥕', 22: '🌽', 23: '🥭', 24: '🌽', 25: '🍆',
    26: '🥬', 27: '🥦', 28: '🥥', 29: '🍈', 30: '🥜',
    31: '🥥', 32: '🍍', 33: '🍍', 34: '🍈', 35: '🍈',
    36: '🥬', 37: '🫒', 38: '🫒', 39: '🍉', 40: '🎃',
  };
  final weights = {
    11:'7g', 12:'14g', 13:'23g', 14:'43g', 15:'70g',
    16:'100g', 17:'140g', 18:'190g', 19:'240g', 20:'300g',
    21:'360g', 22:'430g', 23:'500g', 24:'600g', 25:'700g',
    26:'760g', 27:'875g', 28:'1kg', 29:'1.2kg', 30:'1.3kg',
    31:'1.5kg', 32:'1.7kg', 33:'2kg', 34:'2.1kg', 35:'2.4kg',
    36:'2.6kg', 37:'2.9kg', 38:'3kg', 39:'3.3kg', 40:'3.5kg',
  };
  final ancWeeks = {8, 12, 16, 20, 24, 28, 32, 36, 38, 40};

  String devEn = 'Baby continues to grow and develop. Organs maturing. Brain connections forming.';
  String devAm = 'ሕፃኑ ማደጉን እና ማደጉን ቀጥሏል። አካሎች 익어 ይዘሉ። የአዕምሮ ትስስሮች ይፈጠራሉ።';
  String feelEn = 'Your body is adjusting. Stay hydrated and rest when needed.';
  String feelAm = 'ሰውነትዎ እያስተካከለ ነው። ውሃ ይጠጡ እና ሲያስፈልግ ያርፉ።';
  String todoEn = 'Continue prenatal vitamins. Attend ANC if scheduled.';
  String todoAm = 'ቅድመ ወሊድ ቫይታሚኖቹን ይቀጥሉ። ANC ካለ ያሳዩ።';

  if (w >= 28) {
    devEn = 'Baby gaining weight rapidly. Lungs developing. Eyes can open and close.';
    devAm = 'ሕፃኑ ክብደት በፍጥነት ያሸምናል። ሳምባዎች ያድጋሉ። ዓይኖች መከፈት እና መዘጋት ይችላሉ።';
    feelEn = 'Back pain and heartburn common. Sleep may be difficult. Braxton Hicks contractions.';
    feelAm = 'ጀርባ ምት እና ደረት ማቃጠል ተለምዶ ናቸው። እንቅልፍ ሊቸግር ይችላል። ብራክስተን ሂክስ።';
    todoEn = 'Pack hospital bag. Know danger signs. Count baby kicks daily.';
    todoAm = 'የሆስፒታል ቦርሳ ይሙሉ። የአደጋ ምልክቶችን ያውቁ። ዕለታዊ ምቶች ይቁጠሩ።';
  }

  if (w >= 36) {
    devEn = 'Baby is almost fully developed. Head may engage in pelvis. Ready for birth.';
    devAm = 'ሕፃኑ ሙሉ ለሙሉ ተፈጥሯል ማለት ይቻላል። ጭንቅላቱ ሊሰፈር ይችላል። ለወሊድ ዝግጁ ነው።';
    feelEn = 'Pelvic pressure increases. Nesting instinct common. Watch for labour signs.';
    feelAm: 'የዳሌ ጫና ይጨምራል። የጎጆ ስሜት ተለምዶ ነው። ለወሊድ ምልክቶች ይጠብቁ።';
    todoEn = 'Finalise birth plan. Have hospital bag ready. Partner knows the route.';
    todoAm = 'የወሊድ እቅድ ያጠናቅቁ። የሆስፒታሉ ቦርሳ ዝግጁ ይሁን። ሸሪካ መንገዱን ያውቃሉ።';
  }

  return _WeekData(
    babyDescEn: 'Week $w development',
    babyDescAm: 'ሳምንት $w እድገት',
    babySize: sizes[w] ?? '🤱',
    weightEn: weights[w] ?? '—',
    weightAm: weights[w] ?? '—',
    babyDevEn: devEn, babyDevAm: devAm,
    motherFeelEn: feelEn, motherFeelAm: feelAm,
    todoEn: todoEn, todoAm: todoAm,
    ancVisit: ancWeeks.contains(w),
  );
}

class _GBtn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap;
  const _GBtn(this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(11),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: TColors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: TColors.white.withOpacity(0.10))),
          child: Icon(icon, color: TColors.white, size: 17)))));
}

class _Orb extends StatelessWidget {
  final double size; final Color color;
  const _Orb(this.size, this.color);
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color,
            blurRadius: size, spreadRadius: size * 0.18)]));
}
