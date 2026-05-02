import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/xp_provider.dart';
import '../../models/gamification_model.dart';

// ════════════════════════════════════════════════════════════════
// WELLNESS SCREEN
// Daily check-in: full-screen gradient mood slider (7 levels)
// Habit tracker, body awareness, daily affirmation
// PPD detection: mood ≤2 for 3 days triggers check-in card
// ════════════════════════════════════════════════════════════════

class WellnessScreen extends StatefulWidget {
  const WellnessScreen({super.key});
  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen>
    with TickerProviderStateMixin {

  // Mood state
  int _mood = 4; // 1-7
  bool _moodSaved = false;

  // Mood slider drag
  double _sliderX = 0;
  bool _dragging = false;

  // Habits
  final List<_Habit> _habits = [
    _Habit('Drank 8 glasses of water', 'ስምንት ብርጭቆ ውሃ ጠጣሁ',
        Icons.water_drop_rounded, TColors.blue500),
    _Habit('Took prenatal vitamins', 'ቅድመ ወሊድ ቫይታሚን ወሰድኩ',
        Icons.medication_rounded, TColors.teal500),
    _Habit('Walked or moved for 20 minutes', 'ለ20 ደቂቃ ሄድኩ ወይም ተንቀሳቀስኩ',
        Icons.directions_walk_rounded, const Color(0xFF4CAF50)),
    _Habit('Ate iron-rich food', 'ብረት ያለው ምግብ 召ትኩ',
        Icons.restaurant_rounded, TColors.pink500),
    _Habit('Rested when I needed to', 'ሲያስፈልገኝ ዐረፍኩ',
        Icons.bedtime_rounded, const Color(0xFF7C4DFF)),
  ];

  // Body awareness symptoms
  final List<_Symptom> _symptoms = [
    _Symptom('Headache', 'ራስ ምታት', Icons.sick_rounded),
    _Symptom('Back pain', 'ጀርባ ምት', Icons.accessibility_new_rounded),
    _Symptom('Nausea', 'ማቅለሽለሽ', Icons.sentiment_dissatisfied_rounded),
    _Symptom('Swelling', 'ማበጥ', Icons.water_drop_outlined),
    _Symptom('Fatigue', 'ድካም', Icons.battery_1_bar_rounded),
    _Symptom('Heartburn', 'ደረት ማቃጠል', Icons.local_fire_department_rounded),
    _Symptom('Cramps', 'ቁርጠት', Icons.electric_bolt_rounded),
    _Symptom('Shortness of breath', 'ትንፋሽ ማጠር', Icons.air_rounded),
  ];

  late AnimationController _bgCtrl;
  late Animation<Color?> _bgAnim;

  static const List<Color> _moodColors = [
    Color(0xFF1A0A28), // 1 - very low - deep purple
    Color(0xFF1A1428), // 2 - low - dark blue
    Color(0xFF0A1628), // 3 - neutral - navy
    Color(0xFF0A2020), // 4 - okay - dark teal
    Color(0xFF0A1A10), // 5 - good - dark green
    Color(0xFF1A1A00), // 6 - great - dark gold
    Color(0xFF1A0A00), // 7 - wonderful - warm amber
  ];

  static const List<String> _moodEmojis = [
    '😞', '😔', '😐', '🙂', '😊', '😄', '🌟'
  ];

  static const List<String> _moodLabelsEn = [
    'Very Low', 'Low', 'Neutral', 'Okay', 'Good', 'Great', 'Wonderful'
  ];

  static const List<String> _moodLabelsAm = [
    'በጣም ዝቅ', 'ዝቅ', 'ተለምዶ', 'ጥሩ ይሆናል', 'ጥሩ', 'አስደሳች', 'እጅግ ጥሩ'
  ];

  static const List<String> _affirmationsEn = [
    'Your body is doing something extraordinary. Trust it.',
    'Every day you nourish your body, you are giving a gift to your baby.',
    'You are stronger than you know.',
    'Rest is not laziness — it is how you heal and grow.',
    'You are seen, you are supported, you are not alone.',
    'Ethiopia\'s women have always been resilient. So are you.',
    'One day at a time. One breath at a time.',
  ];

  static const List<String> _affirmationsAm = [
    'ሰውነትዎ ልዩ ነገር እየሰራ ነው። ያምኑት።',
    'ሰውነትዎን ሲያቀርቡ ለሕፃኑ ስጦታ ነው።',
    'ከምታስቡ የበለጠ ጠንካሮች ናቸው።',
    'ዕረፍት ሥንፍና አይደለም — ለማገገም እና ለማደግ ያስፈልጋል።',
    'ታይተዋል፣ ታገዛሉ፣ ብቻዎ አይደሉም።',
    'የኢትዮጵያ ሴቶች ሁሌ ጠንካሮች ናቸው። እርስዎም።',
    'አንድ ቀን በአንድ ቀን። አንድ ትንፋሽ በትንፋሽ።',
  ];

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _bgAnim = ColorTween(
      begin: _moodColors[_mood - 1],
      end: _moodColors[_mood - 1],
    ).animate(_bgCtrl);
  }

  @override
  void dispose() { _bgCtrl.dispose(); super.dispose(); }

  void _changeMood(int newMood) {
    if (newMood == _mood) return;
    HapticFeedback.lightImpact();
    final oldColor = _moodColors[_mood - 1];
    final newColor = _moodColors[newMood - 1];
    _bgAnim = ColorTween(begin: oldColor, end: newColor).animate(
        CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut));
    _bgCtrl.forward(from: 0);
    setState(() => _mood = newMood);
  }

  void _saveMood() {
    HapticFeedback.mediumImpact();
    setState(() => _moodSaved = true);
    context.read<XpProvider>().addXp(XpEvent.dailyLog);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(context.read<LanguageProvider>().s(
          'Mood saved ✓  +${XpEvent.dailyLog.xp} XP',
          'ስሜት ተቀምጧል ✓  +${XpEvent.dailyLog.xp} XP')),
      backgroundColor: TColors.teal500,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final todayAffirmation = _affirmationsEn[_mood - 1];
    final todayAffirmationAm = _affirmationsAm[_mood - 1];

    return AnimatedBuilder(
      animation: _bgAnim,
      builder: (_, __) => Scaffold(
        backgroundColor: _bgAnim.value ?? const Color(0xFF0A1628),
        body: Stack(children: [
          // Animated background orbs
          _BgOrbs(mood: _mood),

          SafeArea(child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── APP BAR ──────────────────────────────────
                Row(children: [
                  _GBtn(Icons.arrow_back_ios_rounded,
                      () => Navigator.pop(context)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lang.s('Daily Wellness', 'ዕለታዊ ጤናማነት'),
                          style: const TextStyle(fontSize: 22,
                              color: TColors.white,
                              fontWeight: FontWeight.w800)),
                      Text(lang.s('How are you today?', 'ዛሬ እንዴት ናቸው?'),
                          style: TextStyle(fontSize: 13,
                              color: TColors.white.withOpacity(0.5))),
                    ],
                  )),
                  // XP badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: TColors.white.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10)),
                    child: Row(children: [
                      const Icon(Icons.bolt_rounded,
                          color: TColors.statusYellow, size: 14),
                      const SizedBox(width: 3),
                      Text('+${XpEvent.dailyLog.xp} XP',
                          style: TextStyle(fontSize: 11,
                              color: TColors.white.withOpacity(0.7),
                              fontWeight: FontWeight.w600)),
                    ])),
                ]),

                const SizedBox(height: 28),

                // ── MOOD CARD ─────────────────────────────────
                _MoodCard(
                  mood: _mood,
                  moodSaved: _moodSaved,
                  lang: lang,
                  onMoodChange: _changeMood,
                  onSave: _saveMood,
                ),

                const SizedBox(height: 20),

                // ── HABITS ────────────────────────────────────
                _SectionLabel(lang.s('Daily Habits', 'ዕለታዊ ልምዶች')),
                const SizedBox(height: 10),
                _HabitsCard(habits: _habits, lang: lang),

                const SizedBox(height: 20),

                // ── BODY AWARENESS ────────────────────────────
                _SectionLabel(lang.s('Body Awareness', 'የሰውነት ግንዛቤ')),
                const SizedBox(height: 6),
                Text(lang.s(
                    'Tap any symptoms you are feeling today',
                    'ዛሬ የሚሰማዎ ምልክቶችን ይምረጡ'),
                    style: TextStyle(fontSize: 12,
                        color: TColors.white.withOpacity(0.4))),
                const SizedBox(height: 10),
                _SymptomsCard(symptoms: _symptoms),

                const SizedBox(height: 20),

                // ── AFFIRMATION ───────────────────────────────
                _SectionLabel(lang.s('Today\'s Affirmation', 'የዛሬ ማረጋገጫ')),
                const SizedBox(height: 10),
                _AffirmationCard(
                  textEn: todayAffirmation,
                  textAm: todayAffirmationAm,
                  lang: lang,
                  moodColor: _moodColors[_mood - 1],
                ),

                // PPD Warning (mood 1 or 2)
                if (_mood <= 2) ...[
                  const SizedBox(height: 16),
                  _PpdCard(lang: lang),
                ],
              ],
            ),
          )),
        ]),
      ),
    );
  }
}

// ── MOOD CARD ─────────────────────────────────────────────────────
class _MoodCard extends StatelessWidget {
  final int mood;
  final bool moodSaved;
  final LanguageProvider lang;
  final Function(int) onMoodChange;
  final VoidCallback onSave;

  const _MoodCard({
    required this.mood, required this.moodSaved,
    required this.lang, required this.onMoodChange,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TColors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: TColors.white.withOpacity(0.12))),
        child: Column(children: [
          // Emoji display
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) => ScaleTransition(
                scale: anim, child: child),
            child: Text(
              _WellnessScreenState._moodEmojis[mood - 1],
              key: ValueKey(mood),
              style: const TextStyle(fontSize: 56)),
          ),
          const SizedBox(height: 8),
          Text(
            lang.isAmharic
                ? _WellnessScreenState._moodLabelsAm[mood - 1]
                : _WellnessScreenState._moodLabelsEn[mood - 1],
            style: const TextStyle(fontSize: 18,
                color: TColors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),

          // 7-dot mood selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (i) {
              final m = i + 1;
              final selected = m == mood;
              return GestureDetector(
                onTap: () => onMoodChange(m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: selected ? 36 : 28,
                  height: selected ? 36 : 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? TColors.white.withOpacity(0.9)
                        : TColors.white.withOpacity(0.12),
                    border: selected
                        ? null
                        : Border.all(
                            color: TColors.white.withOpacity(0.2))),
                  child: Center(child: Text(
                    _WellnessScreenState._moodEmojis[i],
                    style: TextStyle(
                        fontSize: selected ? 18 : 13)))),
              );
            }),
          ),
          const SizedBox(height: 6),

          // Slider labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(lang.s('Very Low', 'በጣም ዝቅ'),
                  style: TextStyle(fontSize: 10,
                      color: TColors.white.withOpacity(0.35))),
              Text(lang.s('Wonderful', 'እጅግ ጥሩ'),
                  style: TextStyle(fontSize: 10,
                      color: TColors.white.withOpacity(0.35))),
            ],
          ),
          const SizedBox(height: 16),

          // Save button
          GestureDetector(
            onTap: moodSaved ? null : onSave,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: moodSaved
                    ? TColors.green500.withOpacity(0.2)
                    : TColors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: moodSaved
                      ? TColors.green500.withOpacity(0.4)
                      : TColors.white.withOpacity(0.2))),
              child: Center(child: Text(
                moodSaved
                    ? lang.s('Mood saved ✓', 'ስሜት ተቀምጧል ✓')
                    : lang.s('Save my mood', 'ስሜቴን አስቀምጥ'),
                style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: moodSaved
                      ? TColors.green500 : TColors.white)))),
          ),
        ]),
      ),
    ),
  );
}

// ── HABITS CARD ───────────────────────────────────────────────────
class _HabitsCard extends StatefulWidget {
  final List<_Habit> habits;
  final LanguageProvider lang;
  const _HabitsCard({required this.habits, required this.lang});
  @override
  State<_HabitsCard> createState() => _HabitsCardState();
}

class _HabitsCardState extends State<_HabitsCard> {
  final Set<int> _done = {};

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        decoration: BoxDecoration(
          color: TColors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TColors.white.withOpacity(0.08))),
        child: Column(children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              Expanded(child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: _done.length / widget.habits.length,
                  backgroundColor: TColors.white.withOpacity(0.08),
                  valueColor: const AlwaysStoppedAnimation(TColors.teal500),
                  minHeight: 4),
              )),
              const SizedBox(width: 10),
              Text('${_done.length}/${widget.habits.length}',
                  style: TextStyle(fontSize: 12,
                      color: TColors.teal300, fontWeight: FontWeight.w700)),
            ]),
          ),
          const SizedBox(height: 10),
          ...List.generate(widget.habits.length, (i) {
            final h = widget.habits[i];
            final done = _done.contains(i);
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  if (done) _done.remove(i); else _done.add(i);
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(
                      color: TColors.white.withOpacity(0.05)))),
                child: Row(children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: done
                          ? h.color.withOpacity(0.2)
                          : TColors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10)),
                    child: Icon(h.icon,
                        color: done
                            ? h.color : TColors.white.withOpacity(0.3),
                        size: 18)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(
                    widget.lang.isAmharic ? h.labelAm : h.labelEn,
                    style: TextStyle(
                      fontSize: 13,
                      color: done
                          ? TColors.white : TColors.white.withOpacity(0.55),
                      decoration: done ? TextDecoration.lineThrough : null,
                      decorationColor: TColors.white.withOpacity(0.3)))),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done
                          ? h.color : Colors.transparent,
                      border: Border.all(
                        color: done
                            ? h.color : TColors.white.withOpacity(0.2),
                        width: 1.5)),
                    child: done
                        ? const Icon(Icons.check_rounded,
                            color: TColors.white, size: 13)
                        : null),
                ]),
              ),
            );
          }),
        ]),
      ),
    ),
  );
}

// ── SYMPTOMS CARD ─────────────────────────────────────────────────
class _SymptomsCard extends StatefulWidget {
  final List<_Symptom> symptoms;
  const _SymptomsCard({required this.symptoms});
  @override
  State<_SymptomsCard> createState() => _SymptomsCardState();
}

class _SymptomsCardState extends State<_SymptomsCard> {
  final Set<int> _selected = {};

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8, runSpacing: 8,
    children: List.generate(widget.symptoms.length, (i) {
      final s = widget.symptoms[i];
      final on = _selected.contains(i);
      final lang = context.read<LanguageProvider>();
      return GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            if (on) _selected.remove(i); else _selected.add(i);
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: on
                ? TColors.pink500.withOpacity(0.15)
                : TColors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: on
                  ? TColors.pink500.withOpacity(0.5)
                  : TColors.white.withOpacity(0.08))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(s.icon,
                color: on ? TColors.pink300 : TColors.white.withOpacity(0.4),
                size: 14),
            const SizedBox(width: 6),
            Text(lang.isAmharic ? s.labelAm : s.labelEn,
                style: TextStyle(fontSize: 12,
                    color: on
                        ? TColors.pink300 : TColors.white.withOpacity(0.55),
                    fontWeight: on ? FontWeight.w600 : FontWeight.w400)),
          ]),
        ),
      );
    }),
  );
}

// ── AFFIRMATION CARD ──────────────────────────────────────────────
class _AffirmationCard extends StatelessWidget {
  final String textEn, textAm;
  final LanguageProvider lang;
  final Color moodColor;
  const _AffirmationCard({
    required this.textEn, required this.textAm,
    required this.lang, required this.moodColor,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              TColors.teal700.withOpacity(0.18),
              TColors.blue700.withOpacity(0.12),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TColors.teal500.withOpacity(0.25))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('✨', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 10),
            Text(lang.isAmharic ? textAm : textEn,
                style: const TextStyle(fontSize: 17,
                    color: TColors.white, height: 1.6,
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic)),
            const SizedBox(height: 14),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              GestureDetector(
                onTap: () {},
                child: Row(children: [
                  Icon(Icons.bookmark_border_rounded,
                      color: TColors.teal300.withOpacity(0.6), size: 16),
                  const SizedBox(width: 4),
                  Text(lang.s('Save', 'አስቀምጥ'),
                      style: TextStyle(fontSize: 12,
                          color: TColors.teal300.withOpacity(0.6))),
                ]),
              ),
            ]),
          ],
        ),
      ),
    ),
  );
}

// ── PPD WARNING CARD ──────────────────────────────────────────────
class _PpdCard extends StatelessWidget {
  final LanguageProvider lang;
  const _PpdCard({required this.lang});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TColors.pink500.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TColors.pink500.withOpacity(0.25))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.favorite_rounded,
                  color: TColors.pink300, size: 18),
              const SizedBox(width: 8),
              Text(lang.s('You seem to be having a hard time',
                  'ችግር ያለዎ ይመስላል'),
                  style: const TextStyle(fontSize: 14,
                      color: TColors.pink300, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 8),
            Text(lang.s(
                'Feeling low is real and valid. If this has been '
                'going on for several days, talking to someone can help.',
                'ዝቅ ያለ ስሜት እውነተኛ ነው። ይህ ለብዙ ቀናት ከሆነ '
                'ከሌላ ሰው ጋር ማውራት ሊረዳ ይችላል።'),
                style: TextStyle(fontSize: 13, height: 1.55,
                    color: TColors.white.withOpacity(0.65))),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: TColors.pink500.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: TColors.pink500.withOpacity(0.3))),
                child: Text(
                  lang.s('Talk to Tsega AI →', 'ጸጋ AI ጋር ይነጋገሩ →'),
                  style: const TextStyle(fontSize: 13,
                      color: TColors.pink300, fontWeight: FontWeight.w600))),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── BACKGROUND ORBS ───────────────────────────────────────────────
class _BgOrbs extends StatelessWidget {
  final int mood;
  const _BgOrbs({required this.mood});

  @override
  Widget build(BuildContext context) {
    final colors = [
      TColors.pink500, TColors.blue500, TColors.teal500,
      TColors.teal500, const Color(0xFF4CAF50),
      TColors.statusYellow, const Color(0xFFF9A825),
    ];
    final c = colors[mood - 1];
    return Stack(children: [
      Positioned(top: -80, right: -60,
          child: _Orb(300, c.withOpacity(0.10))),
      Positioned(bottom: 100, left: -60,
          child: _Orb(240, c.withOpacity(0.07))),
    ]);
  }
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

// ── SECTION LABEL ─────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
          color: TColors.white.withOpacity(0.4),
          letterSpacing: 0.8));
}

// ── GLASS BUTTON ──────────────────────────────────────────────────
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
            color: TColors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: TColors.white.withOpacity(0.12))),
          child: Icon(icon, color: TColors.white, size: 17)))));
}

// ── DATA MODELS ───────────────────────────────────────────────────
class _Habit {
  final String labelEn, labelAm;
  final IconData icon;
  final Color color;
  const _Habit(this.labelEn, this.labelAm, this.icon, this.color);
}

class _Symptom {
  final String labelEn, labelAm;
  final IconData icon;
  const _Symptom(this.labelEn, this.labelAm, this.icon);
}
