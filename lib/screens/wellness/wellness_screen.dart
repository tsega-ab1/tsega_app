import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/stage_provider.dart';
import '../../core/providers/user_provider.dart';

class WellnessScreen extends StatefulWidget {
  const WellnessScreen({super.key});
  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen>
    with TickerProviderStateMixin {

  // ── Animation controllers ────────────────────────────────────
  late AnimationController _headerCtrl;
  late AnimationController _cardsCtrl;
  late AnimationController _floatCtrl;   // subtle floating background

  late Animation<double>  _headerFade;
  late Animation<Offset>  _headerSlide;
  late Animation<double>  _cardsFade;
  late Animation<double>  _floatAnim;

  // ── State ────────────────────────────────────────────────────
  int _selectedMood = -1;
  final List<int> _checkedHabits = [];

  @override
  void initState() {
    super.initState();

    // Header fades + slides down from top
    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _headerFade  = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeIn);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));

    // Cards stagger in from bottom
    _cardsCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _cardsFade = CurvedAnimation(parent: _cardsCtrl, curve: Curves.easeOut);

    // Background orbs float slowly
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    // Start animations with slight delays
    _headerCtrl.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _cardsCtrl.forward();
    });
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _cardsCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang  = context.watch<LanguageProvider>();
    final stage = context.watch<StageProvider>();
    final user  = context.watch<UserProvider>();
    final size  = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628), // deep navy base
      body: Stack(children: [

        // ── LAYER 1: Animated background orbs ───────────────────
        _AnimatedBackground(floatAnim: _floatAnim, size: size),

        // ── LAYER 2: Main scrollable content ────────────────────
        SafeArea(
          child: CustomScrollView(slivers: [

            // ── HEADER ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _headerFade,
                child: SlideTransition(
                  position: _headerSlide,
                  child: _Header(user: user, lang: lang),
                ),
              ),
            ),

            // ── MOOD CHECK-IN ────────────────────────────────────
            SliverToBoxAdapter(
              child: _StaggerItem(
                controller: _cardsCtrl,
                delay: 0.0,
                child: _MoodCard(
                  lang: lang,
                  selected: _selectedMood,
                  onSelect: (i) => setState(() => _selectedMood = i),
                ),
              ),
            ),

            // ── DAILY HABITS ─────────────────────────────────────
            SliverToBoxAdapter(
              child: _StaggerItem(
                controller: _cardsCtrl,
                delay: 0.15,
                child: _HabitsCard(
                  lang: lang,
                  stage: stage,
                  checked: _checkedHabits,
                  onToggle: (i) => setState(() {
                    _checkedHabits.contains(i)
                        ? _checkedHabits.remove(i)
                        : _checkedHabits.add(i);
                  }),
                ),
              ),
            ),

            // ── BODY AWARENESS ───────────────────────────────────
            SliverToBoxAdapter(
              child: _StaggerItem(
                controller: _cardsCtrl,
                delay: 0.30,
                child: _BodyAwarenessCard(lang: lang, stage: stage),
              ),
            ),

            // ── AFFIRMATION ──────────────────────────────────────
            SliverToBoxAdapter(
              child: _StaggerItem(
                controller: _cardsCtrl,
                delay: 0.45,
                child: _AffirmationCard(lang: lang),
              ),
            ),

            const SliverToBoxAdapter(
                child: SizedBox(height: 100)),
          ]),
        ),

        // ── LAYER 3: Back button ─────────────────────────────────
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          child: _GlassButton(
            icon: Icons.arrow_back_ios_rounded,
            onTap: () => Navigator.pop(context),
          ),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ANIMATED BACKGROUND — floating color orbs
// ═══════════════════════════════════════════════════════════════
class _AnimatedBackground extends StatelessWidget {
  final Animation<double> floatAnim;
  final Size size;
  const _AnimatedBackground({
      required this.floatAnim, required this.size});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatAnim,
      builder: (_, __) {
        // orbs drift up and down slightly
        final drift = floatAnim.value * 20;
        return Stack(children: [
          // Dark base gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0A1628),
                  Color(0xFF0D1F3C),
                  Color(0xFF0A1628),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Teal orb — top right
          Positioned(
            top: -50 + drift,
            right: -60,
            child: _Orb(size: 220,
                color: TColors.teal500.withOpacity(0.18)),
          ),
          // Pink orb — middle left
          Positioned(
            top: size.height * 0.3 - drift,
            left: -80,
            child: _Orb(size: 200,
                color: TColors.pink500.withOpacity(0.12)),
          ),
          // Blue orb — bottom center
          Positioned(
            bottom: 100 + drift * 0.5,
            right: size.width * 0.2,
            child: _Orb(size: 160,
                color: TColors.blue500.withOpacity(0.10)),
          ),
        ]);
      },
    );
  }
}

class _Orb extends StatelessWidget {
  final double size;
  final Color color;
  const _Orb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [BoxShadow(
        color: color,
        blurRadius: size,
        spreadRadius: size * 0.3,
      )],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
// HEADER
// ═══════════════════════════════════════════════════════════════
class _Header extends StatelessWidget {
  final UserProvider user;
  final LanguageProvider lang;
  const _Header({required this.user, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 64, 20, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Pill tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: TColors.teal500.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: TColors.teal500.withOpacity(0.4))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 6, height: 6,
              decoration: const BoxDecoration(
                color: TColors.teal300,
                shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(lang.s('Daily Wellness', 'ዕለታዊ ጤናማነት'),
                style: const TextStyle(
                    fontSize: 11, color: TColors.teal300,
                    fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          ]),
        ),
        const SizedBox(height: 12),
        Text(
          lang.s(
            'How are you\nfeeling today?',
            'ዛሬ እንዴት\nይሰማዎታል?'),
          style: const TextStyle(
              fontSize: 34, fontWeight: FontWeight.w800,
              color: TColors.white, height: 1.1,
              letterSpacing: -0.5),
        ),
        const SizedBox(height: 8),
        Text(
          lang.s(
            'Check in with yourself — it only takes a moment',
            'ከራስዎ ጋር ያረጋግጡ — ትንሽ ጊዜ ብቻ ይወስዳል'),
          style: TextStyle(
              fontSize: 14,
              color: TColors.white.withOpacity(0.55),
              height: 1.5),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// GLASS CARD BASE — reusable
// ═══════════════════════════════════════════════════════════════
class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double blur;
  final Color? borderColor;
  const _GlassCard({
    required this.child,
    this.padding,
    this.blur = 12,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        // THIS is the glass blur effect
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            // Semi-transparent white fill
            color: TColors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: borderColor ?? TColors.white.withOpacity(0.12),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MOOD CARD
// ═══════════════════════════════════════════════════════════════
class _MoodCard extends StatelessWidget {
  final LanguageProvider lang;
  final int selected;
  final Function(int) onSelect;
  const _MoodCard({
      required this.lang, required this.selected,
      required this.onSelect});

  static const _moods = [
    ('😊', 'Great',    'ጥሩ'),
    ('🙂', 'Good',     'ደህና'),
    ('😐', 'Okay',     'ቀጥ'),
    ('😔', 'Low',      'ዝቅ'),
    ('😩', 'Rough',    'ከባድ'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: _GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  gradient: TGradients.gradPink,
                  borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.favorite_rounded,
                    color: TColors.white, size: 18)),
              const SizedBox(width: 12),
              Text(lang.s('Mood Check-in', 'የስሜት ምዝገባ'),
                  style: const TextStyle(fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: TColors.white)),
            ]),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_moods.length, (i) {
                final m = _moods[i];
                final isSelected = selected == i;
                return GestureDetector(
                  onTap: () => onSelect(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? TColors.pink500.withOpacity(0.25)
                          : TColors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? TColors.pink500.withOpacity(0.7)
                            : TColors.white.withOpacity(0.08),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(children: [
                      // Emoji scales up when selected
                      AnimatedScale(
                        scale: isSelected ? 1.3 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Text(m.$1,
                            style: const TextStyle(fontSize: 26)),
                      ),
                      const SizedBox(height: 4),
                      Text(lang.isAmharic ? m.$3 : m.$2,
                          style: TextStyle(
                              fontSize: 10,
                              color: isSelected
                                  ? TColors.pink300
                                  : TColors.white.withOpacity(0.4),
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400)),
                    ]),
                  ),
                );
              }),
            ),
            if (selected >= 0) ...[
              const SizedBox(height: 16),
              AnimatedOpacity(
                opacity: selected >= 0 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TColors.pink500.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: TColors.pink500.withOpacity(0.2))),
                  child: Text(
                    _getResponse(selected, lang),
                    style: TextStyle(
                        fontSize: 13,
                        color: TColors.white.withOpacity(0.8),
                        height: 1.5),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getResponse(int mood, LanguageProvider lang) {
    final en = [
      'Wonderful! Keep that energy going 🌟',
      'That\'s great to hear. Keep taking care of yourself.',
      'That\'s okay — every day is different. Be gentle with yourself.',
      'I hear you. Rest if you need to. You\'re doing your best.',
      'That sounds hard. Remember — it\'s okay to ask for help.',
    ];
    final am = [
      'አስደናቂ! ያንን ኃይል ይቀጥሉ 🌟',
      'ጥሩ ነው። ራስዎን መንከባከብ ይቀጥሉ።',
      'ደህና ነው — እያንዳንዱ ቀን የተለየ ነው። ለራስዎ ቀላል ይሁኑ።',
      'ሰምቻለሁ። ማረፍ ከፈለጉ ያርፉ። ከሚችሉት ያደርጋሉ።',
      'ከባድ ይመስላል። እርዳታ መጠየቅ ደህና ነው — አያፍሩ።',
    ];
    return lang.isAmharic ? am[mood] : en[mood];
  }
}

// ═══════════════════════════════════════════════════════════════
// DAILY HABITS CARD
// ═══════════════════════════════════════════════════════════════
class _HabitsCard extends StatelessWidget {
  final LanguageProvider lang;
  final StageProvider stage;
  final List<int> checked;
  final Function(int) onToggle;
  const _HabitsCard({
      required this.lang, required this.stage,
      required this.checked, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    // Habits adapt to life stage
    final habits = _habitsForStage(stage, lang);
    final done = checked.length;
    final total = habits.length;
    final progress = total > 0 ? done / total : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: _GlassCard(
        borderColor: TColors.teal500.withOpacity(0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      gradient: TGradients.gradTeal,
                      borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.check_circle_outline_rounded,
                        color: TColors.white, size: 18)),
                  const SizedBox(width: 12),
                  Text(lang.s('Daily Habits', 'ዕለታዊ ልምዶች'),
                      style: const TextStyle(fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: TColors.white)),
                ]),
                Text('$done/$total',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: TColors.teal300)),
              ],
            ),
            const SizedBox(height: 14),

            // Animated progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (_, val, __) => LinearProgressIndicator(
                  value: val,
                  backgroundColor: TColors.white.withOpacity(0.08),
                  valueColor: AlwaysStoppedAnimation(
                      val >= 1.0 ? TColors.green500 : TColors.teal400),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Habit list
            ...List.generate(habits.length, (i) {
              final h = habits[i];
              final isChecked = checked.contains(i);
              return GestureDetector(
                onTap: () => onToggle(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isChecked
                        ? TColors.teal500.withOpacity(0.15)
                        : TColors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isChecked
                          ? TColors.teal500.withOpacity(0.4)
                          : TColors.white.withOpacity(0.06),
                    ),
                  ),
                  child: Row(children: [
                    Text(h.$1,
                        style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(
                      lang.isAmharic ? h.$3 : h.$2,
                      style: TextStyle(
                          fontSize: 14,
                          color: isChecked
                              ? TColors.teal300
                              : TColors.white.withOpacity(0.75),
                          fontWeight: isChecked
                              ? FontWeight.w600 : FontWeight.w400,
                          decoration: isChecked
                              ? TextDecoration.none : null),
                    )),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isChecked
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        key: ValueKey(isChecked),
                        color: isChecked
                            ? TColors.teal400
                            : TColors.white.withOpacity(0.2),
                        size: 22,
                      ),
                    ),
                  ]),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  List<(String, String, String)> _habitsForStage(
      StageProvider s, LanguageProvider lang) {
    if (s.isPregnancyMode) {
      return [
        ('💧', 'Drink 8 glasses of water', '8 ብርጭቆ ውሃ ጠጡ'),
        ('🚶', 'Take a 15-min walk', '15 ደቂቃ ሂዱ'),
        ('💊', 'Take iron supplement', 'ብረት ቫይታሚን ወሰዱ'),
        ('👣', 'Count baby kicks', 'የልጅ ምቶች ቆጠሩ'),
        ('😴', 'Sleep on your left side', 'በግራ ጎንዎ ተኙ'),
      ];
    }
    if (s.lifeStage == LifeStage.adolescence) {
      return [
        ('💧', 'Drink enough water today', 'በቂ ውሃ ጠጡ'),
        ('🥗', 'Eat one iron-rich meal', 'አንድ ብረት ያለው ምግብ 召し食べ'),
        ('📓', 'Log your cycle day', 'የዑደት ቀን ይመዝግቡ'),
        ('🧘', 'Take 5 deep breaths', '5 ጥልቅ እስትንፋስ ወሰዱ'),
        ('🌙', 'Sleep before 10pm', 'ከምሽቱ 10 በፊት ተኙ'),
      ];
    }
    return [
      ('💧', 'Drink 8 glasses of water', '8 ብርጭቆ ውሃ ጠጡ'),
      ('🥬', 'Eat gomen or misir today', 'ጎመን ወይም ምስር 召し食べ'),
      ('📅', 'Log your cycle', 'ዑደቱን ይመዝግቡ'),
      ('🚶', 'Move your body 20 min', 'ለ20 ደቂቃ ተንቀሳቀሱ'),
      ('😴', 'Get 7-8 hours sleep', '7-8 ሰዓት ይተኙ'),
    ];
  }
}

// ═══════════════════════════════════════════════════════════════
// BODY AWARENESS CARD
// ═══════════════════════════════════════════════════════════════
class _BodyAwarenessCard extends StatelessWidget {
  final LanguageProvider lang;
  final StageProvider stage;
  const _BodyAwarenessCard({required this.lang, required this.stage});

  @override
  Widget build(BuildContext context) {
    final symptoms = stage.isPregnancyMode
        ? _pregnancySymptoms : _cycleSymptoms;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: _GlassCard(
        borderColor: TColors.pink500.withOpacity(0.15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  gradient: TGradients.gradBlue,
                  borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.self_improvement_rounded,
                    color: TColors.white, size: 18)),
              const SizedBox(width: 12),
              Text(lang.s('Body Awareness', 'የሰውነት ንቃት'),
                  style: const TextStyle(fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: TColors.white)),
            ]),
            const SizedBox(height: 6),
            Text(lang.s('What are you noticing today?',
                'ዛሬ ምን እያስተዋሉ ነው?'),
                style: TextStyle(fontSize: 13,
                    color: TColors.white.withOpacity(0.5))),
            const SizedBox(height: 16),
            Wrap(spacing: 8, runSpacing: 8,
              children: symptoms.map((s) => _SymptomChip(
                emoji: s.$1,
                labelEn: s.$2,
                labelAm: s.$3,
                lang: lang,
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  static const _pregnancySymptoms = [
    ('🤢', 'Nausea',     'ማቅለሽለሽ'),
    ('😴', 'Fatigue',    'ድካም'),
    ('🔙', 'Back pain',  'የጀርባ ህመም'),
    ('🦵', 'Swelling',   'ማበጥ'),
    ('💓', 'Heartburn',  'የሆድ ቃጠሎ'),
    ('😊', 'Feeling good','ጥሩ ስሜት'),
    ('😰', 'Anxious',    'ጭንቀት'),
    ('🤔', 'Headache',   'ራስ ምታት'),
  ];

  static const _cycleSymptoms = [
    ('💢', 'Cramps',     'ቁርጠት'),
    ('😴', 'Fatigue',    'ድካም'),
    ('😤', 'Mood swings','ስሜት መለዋወጥ'),
    ('🎈', 'Bloating',   'ነፋስ'),
    ('🤕', 'Headache',   'ራስ ምታት'),
    ('😊', 'Feeling good','ጥሩ ስሜት'),
    ('🥛', 'Cravings',   'ምኞት'),
    ('😰', 'Anxious',    'ጭንቀት'),
  ];
}

class _SymptomChip extends StatefulWidget {
  final String emoji, labelEn, labelAm;
  final LanguageProvider lang;
  const _SymptomChip({
      required this.emoji, required this.labelEn,
      required this.labelAm, required this.lang});
  @override
  State<_SymptomChip> createState() => _SymptomChipState();
}

class _SymptomChipState extends State<_SymptomChip> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _selected = !_selected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _selected
              ? TColors.teal500.withOpacity(0.25)
              : TColors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _selected
                ? TColors.teal400.withOpacity(0.6)
                : TColors.white.withOpacity(0.1),
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(widget.emoji,
              style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            widget.lang.isAmharic ? widget.labelAm : widget.labelEn,
            style: TextStyle(
                fontSize: 13,
                color: _selected
                    ? TColors.teal300
                    : TColors.white.withOpacity(0.65),
                fontWeight: _selected
                    ? FontWeight.w600 : FontWeight.w400),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// AFFIRMATION CARD — daily motivational message
// ═══════════════════════════════════════════════════════════════
class _AffirmationCard extends StatelessWidget {
  final LanguageProvider lang;
  const _AffirmationCard({required this.lang});

  static const _affirmationsEn = [
    'Your body is doing something remarkable every single day.',
    'You are stronger than you know, braver than you believe.',
    'Taking care of yourself is not selfish — it is necessary.',
    'Every small healthy choice adds up to a beautiful life.',
    'You deserve to feel well, informed, and supported.',
    'Your health journey is uniquely yours — be proud of it.',
    'Rest is productive. Your body heals when you sleep.',
  ];

  static const _affirmationsAm = [
    'አካልዎ በእያንዳንዱ ቀን አስደናቂ ነገር እያደረገ ነው።',
    'ከሚያስቡት ይበልጥ ጠንካራ ናቸው፣ ከሚያምኑት ይበልጥ ደፋር ናቸው።',
    'ራስዎን መንከባከብ ስስታምነት አይደለም — አስፈላጊ ነው።',
    'እያንዳንዱ ትንሽ ጤናማ ምርጫ ወደ ውብ ሕይወት ይጨምራል።',
    'ጤናማ፣ ያወቁ፣ እና የተደገፉ ሆኖ ለመሰማት ይገባዎታል።',
    'የጤና ጉዞዎ ልዩ ነው — ኩራት ይሰማዎ።',
    'እረፍት ውጤታማ ነው። ሲተኙ አካልዎ ይድናል።',
  ];

  @override
  Widget build(BuildContext context) {
    final idx = DateTime.now().day % _affirmationsEn.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              // Gradient glass — different from plain glass
              gradient: LinearGradient(
                colors: [
                  TColors.teal700.withOpacity(0.3),
                  TColors.blue700.withOpacity(0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: TColors.teal400.withOpacity(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Text('✨',
                      style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(lang.s('Today\'s Affirmation',
                      'የዛሬ ማበረታቻ'),
                      style: TextStyle(
                          fontSize: 12,
                          color: TColors.teal300,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5)),
                ]),
                const SizedBox(height: 14),
                Text(
                  lang.isAmharic
                      ? _affirmationsAm[idx]
                      : _affirmationsEn[idx],
                  style: const TextStyle(
                      fontSize: 18,
                      color: TColors.white,
                      fontWeight: FontWeight.w600,
                      height: 1.5),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: TColors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: TColors.white.withOpacity(0.2))),
                    child: Text(lang.s('Save this', 'ያስቀምጡ'),
                        style: const TextStyle(
                            fontSize: 12,
                            color: TColors.white,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// STAGGER ITEM — animates children in sequence
// ═══════════════════════════════════════════════════════════════
class _StaggerItem extends StatelessWidget {
  final AnimationController controller;
  final double delay;   // 0.0 to 1.0
  final Widget child;
  const _StaggerItem({
      required this.controller,
      required this.delay,
      required this.child});

  @override
  Widget build(BuildContext context) {
    final start = delay;
    final end   = (delay + 0.5).clamp(0.0, 1.0);

    final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );

    final slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// GLASS BUTTON — back button and other icon buttons
// ═══════════════════════════════════════════════════════════════
class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: TColors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: TColors.white.withOpacity(0.2))),
            child: Icon(icon, color: TColors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

