import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/xp_provider.dart';
import '../../models/models.dart';
import '../../models/gamification_model.dart';
import '../../overlays/badge_unlock_overlay.dart';

// ════════════════════════════════════════════════════════════════
// QUIZ SCREEN
// 3-5 questions per module. Tap answer → immediate feedback.
// Pass = XP earned + optional badge unlock.
// Fail = retry allowed.
// ════════════════════════════════════════════════════════════════

class QuizScreen extends StatefulWidget {
  final EducationModule module;
  const QuizScreen({super.key, required this.module});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with TickerProviderStateMixin {
  int _current     = 0;
  int _score       = 0;
  int? _selected;       // index of chosen answer
  bool _answered   = false;
  bool _done       = false;

  late AnimationController _slideCtrl;
  late Animation<Offset>   _slideAnim;
  late AnimationController _shakeCtrl;
  late Animation<double>   _shakeAnim;

  List<QuizQuestion> get _questions =>
      widget.module.quiz.isNotEmpty ? widget.module.quiz : _demoQuestions;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _slideAnim = Tween<Offset>(
        begin: const Offset(0.3, 0), end: Offset.zero).animate(
        CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(_shakeCtrl);
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _answer(int idx) {
    if (_answered) return;
    final q = _questions[_current];
    final correct = idx == q.correctIndex;

    setState(() {
      _selected  = idx;
      _answered  = true;
      if (correct) _score++;
    });

    if (!correct) {
      _shakeCtrl.forward(from: 0);
    }

    // Auto advance after 1.5s
    Future.delayed(const Duration(milliseconds: 1600), _nextQuestion);
  }

  void _nextQuestion() {
    if (!mounted) return;
    if (_current < _questions.length - 1) {
      _slideCtrl.reset();
      setState(() {
        _current++;
        _selected = null;
        _answered = false;
      });
      _slideCtrl.forward();
    } else {
      setState(() => _done = true);
      _handleCompletion();
    }
  }

  void _handleCompletion() {
    final pass = _score >= (_questions.length * 0.7).ceil();
    if (pass) {
      context.read<XpProvider>().addXp(XpEvent.quizPassed);
      context.read<XpProvider>().addXp(XpEvent.moduleComplete);
    }
    // Check level up
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<XpProvider>().consumeLevelUp()) {
        // level up overlay handled by rewards screen
      }
    });
  }

  void _retry() {
    _slideCtrl.reset();
    setState(() {
      _current  = 0;
      _score    = 0;
      _selected = null;
      _answered = false;
      _done     = false;
    });
    _slideCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Stack(children: [
        Positioned(top: -60, right: -40,
            child: _Orb(260, widget.module.gradient.colors.first.withOpacity(0.12))),

        SafeArea(child: _done
            ? _ResultScreen(
                score: _score,
                total: _questions.length,
                module: widget.module,
                lang: lang,
                onRetry: _retry,
                onDone: () => Navigator.pop(context),
              )
            : Column(children: [
                // ── HEADER ────────────────────────────────────
                _QuizHeader(
                  module: widget.module,
                  current: _current,
                  total: _questions.length,
                  lang: lang,
                  onClose: () => Navigator.pop(context),
                ),

                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: (_current + (_answered ? 1 : 0)) / _questions.length,
                      backgroundColor: TColors.white.withOpacity(0.08),
                      valueColor: AlwaysStoppedAnimation(
                          widget.module.gradient.colors.first),
                      minHeight: 4,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── QUESTION ──────────────────────────────────
                Expanded(child: SlideTransition(
                  position: _slideAnim,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question text
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: TColors.white.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: TColors.white.withOpacity(0.08))),
                              child: Text(
                                lang.isAmharic
                                    ? _questions[_current].questionAm
                                    : _questions[_current].questionEn,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w700,
                                    color: TColors.white, height: 1.4)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Answer options
                        ...List.generate(
                          lang.isAmharic
                              ? _questions[_current].optionsAm.length
                              : _questions[_current].optionsEn.length,
                          (i) => _AnswerOption(
                            index: i,
                            text: lang.isAmharic
                                ? _questions[_current].optionsAm[i]
                                : _questions[_current].optionsEn[i],
                            selected: _selected == i,
                            correct: _answered &&
                                i == _questions[_current].correctIndex,
                            wrong: _answered &&
                                _selected == i &&
                                i != _questions[_current].correctIndex,
                            answered: _answered,
                            gradient: widget.module.gradient,
                            shakeAnim: _shakeCtrl,
                            onTap: () => _answer(i),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ])),
      ]),
    );
  }

  List<QuizQuestion> get _demoQuestions => [
    QuizQuestion(
      questionEn: 'Which Ethiopian food is the richest source of iron?',
      questionAm: 'የብረት ዋና ምንጭ የሆነ የኢትዮጵያ ምግብ የቱ ነው?',
      optionsEn: ['White rice', 'Misir wot', 'Pasta', 'Bread'],
      optionsAm: ['ነጭ ሩዝ', 'ምስር ወጥ', 'ፓስታ', 'ዳቦ'],
      correctIndex: 1,
    ),
    QuizQuestion(
      questionEn: 'What is the daily iron requirement for pregnant women?',
      questionAm: 'ለእርጉዝ ሴቶች ዕለታዊ የብረት ፍላጎት ምን ያህል ነው?',
      optionsEn: ['10mg', '15mg', '27mg', '50mg'],
      optionsAm: ['10mg', '15mg', '27mg', '50mg'],
      correctIndex: 2,
    ),
    QuizQuestion(
      questionEn: 'Which vitamin helps your body absorb iron better?',
      questionAm: 'ሰውነት ብረት ተሻሽሎ እንዲወስድ የሚረዳ ቪታሚን የቱ ነው?',
      optionsEn: ['Vitamin A', 'Vitamin B', 'Vitamin C', 'Vitamin D'],
      optionsAm: ['ቪታሚን A', 'ቪታሚን B', 'ቪታሚን C', 'ቪታሚን D'],
      correctIndex: 2,
    ),
    QuizQuestion(
      questionEn: 'What percentage of Ethiopian women are affected by iron deficiency anemia?',
      questionAm: 'ምን ያህል % የኢትዮጵያ ሴቶች የደም ማነስ አለባቸው?',
      optionsEn: ['5%', '12%', '23%', '40%'],
      optionsAm: ['5%', '12%', '23%', '40%'],
      correctIndex: 2,
    ),
  ];
}

// ── QUIZ HEADER ───────────────────────────────────────────────────
class _QuizHeader extends StatelessWidget {
  final EducationModule module;
  final int current, total;
  final LanguageProvider lang;
  final VoidCallback onClose;

  const _QuizHeader({
    required this.module, required this.current, required this.total,
    required this.lang, required this.onClose,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
    child: Row(children: [
      GestureDetector(
        onTap: onClose,
        child: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: TColors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: TColors.white.withOpacity(0.10))),
          child: const Icon(Icons.close_rounded,
              color: TColors.white, size: 18))),
      const SizedBox(width: 14),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lang.s('Quick Quiz', 'ፈጣን ፈተና'),
              style: const TextStyle(fontSize: 18,
                  color: TColors.white, fontWeight: FontWeight.w800)),
          Text(lang.s('${current + 1} of $total questions',
              '${current + 1} / $total ጥያቄዎች'),
              style: TextStyle(fontSize: 12,
                  color: TColors.white.withOpacity(0.45))),
        ],
      )),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: module.gradient,
          borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          const Icon(Icons.quiz_rounded, color: TColors.white, size: 14),
          const SizedBox(width: 4),
          Text(lang.isAmharic ? module.categoryAm : module.categoryEn,
              style: const TextStyle(fontSize: 11,
                  color: TColors.white, fontWeight: FontWeight.w600)),
        ])),
    ]),
  );
}

// ── ANSWER OPTION ─────────────────────────────────────────────────
class _AnswerOption extends StatelessWidget {
  final int index;
  final String text;
  final bool selected, correct, wrong, answered;
  final LinearGradient gradient;
  final AnimationController shakeAnim;
  final VoidCallback onTap;

  const _AnswerOption({
    required this.index, required this.text,
    required this.selected, required this.correct, required this.wrong,
    required this.answered, required this.gradient,
    required this.shakeAnim, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final letters = ['A', 'B', 'C', 'D'];

    Color bgColor     = TColors.white.withOpacity(0.05);
    Color borderColor = TColors.white.withOpacity(0.08);
    Color textColor   = TColors.white.withOpacity(0.85);
    Color letterBg    = TColors.white.withOpacity(0.08);
    Color letterColor = TColors.white.withOpacity(0.5);
    Widget? trailingIcon;

    if (correct) {
      bgColor     = TColors.green500.withOpacity(0.14);
      borderColor = TColors.green500.withOpacity(0.5);
      textColor   = TColors.white;
      letterBg    = TColors.green500;
      letterColor = TColors.white;
      trailingIcon = const Icon(Icons.check_circle_rounded,
          color: TColors.green500, size: 22);
    } else if (wrong) {
      bgColor     = TColors.red400.withOpacity(0.12);
      borderColor = TColors.red400.withOpacity(0.4);
      textColor   = TColors.white;
      letterBg    = TColors.red400;
      letterColor = TColors.white;
      trailingIcon = const Icon(Icons.cancel_rounded,
          color: TColors.red400, size: 22);
    } else if (answered && !selected) {
      bgColor   = TColors.white.withOpacity(0.02);
      textColor = TColors.white.withOpacity(0.3);
      letterColor = TColors.white.withOpacity(0.2);
    }

    Widget card = GestureDetector(
      onTap: answered ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5)),
        child: Row(children: [
          // Letter circle
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: letterBg, borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text(letters[index],
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                    color: letterColor)))),
          const SizedBox(width: 12),
          Expanded(child: Text(text,
              style: TextStyle(fontSize: 14, height: 1.4, color: textColor))),
          if (trailingIcon != null) ...[
            const SizedBox(width: 8),
            trailingIcon,
          ],
        ]),
      ),
    );

    // Shake animation for wrong answer
    if (wrong) {
      return AnimatedBuilder(
        animation: shakeAnim,
        builder: (_, child) {
          final shake = (shakeAnim.value * 3.14159 * 4).sin() * 8;
          return Transform.translate(
            offset: Offset(shake, 0),
            child: child);
        },
        child: card,
      );
    }
    return card;
  }
}

// ── RESULT SCREEN ─────────────────────────────────────────────────
class _ResultScreen extends StatefulWidget {
  final int score, total;
  final EducationModule module;
  final LanguageProvider lang;
  final VoidCallback onRetry, onDone;

  const _ResultScreen({
    required this.score, required this.total, required this.module,
    required this.lang, required this.onRetry, required this.onDone,
  });

  @override
  State<_ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<_ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _fade;

  bool get _passed =>
      widget.score >= (widget.total * 0.7).ceil();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _scale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final lang   = widget.lang;
    final passed = _passed;
    final xp     = passed ? XpEvent.quizPassed.xp + XpEvent.moduleComplete.xp : 0;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Container(
                width: 110, height: 110,
                decoration: BoxDecoration(
                  gradient: passed
                      ? widget.module.gradient
                      : const LinearGradient(colors: [
                          Color(0xFF555577), Color(0xFF333355)]),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                    color: (passed
                        ? widget.module.gradient.colors.first
                        : const Color(0xFF555577)).withOpacity(0.4),
                    blurRadius: 30, spreadRadius: 5)]),
                child: Icon(
                  passed
                      ? Icons.emoji_events_rounded
                      : Icons.refresh_rounded,
                  color: TColors.white, size: 52),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FadeTransition(opacity: _fade, child: Column(children: [
            Text(
              passed
                  ? lang.s('Quiz Passed! 🎉', 'ፈተናውን አለፉ! 🎉')
                  : lang.s('Not quite — try again', 'ሞክሩ — እንደገና'),
              style: const TextStyle(fontSize: 26,
                  color: TColors.white, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              lang.s('${widget.score} / ${widget.total} correct',
                  '${widget.score} / ${widget.total} ትክክለኛ'),
              style: TextStyle(fontSize: 16,
                  color: TColors.white.withOpacity(0.6))),

            if (passed) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: TColors.green500.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: TColors.green500.withOpacity(0.3))),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded,
                        color: TColors.statusYellow, size: 20),
                    const SizedBox(width: 6),
                    Text('+$xp XP ${lang.s('earned!', 'አግኝተዋል!')}',
                        style: const TextStyle(
                            fontSize: 16, color: TColors.white,
                            fontWeight: FontWeight.w800)),
                  ],
                )),
            ],

            const SizedBox(height: 32),

            // Buttons
            if (passed)
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: widget.onDone,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: widget.module.gradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(
                        color: widget.module.gradient.colors.first
                            .withOpacity(0.3),
                        blurRadius: 16, offset: const Offset(0, 6))]),
                    child: Center(child: Text(
                      lang.s('Complete ✓', 'ተጠናቀቀ ✓'),
                      style: const TextStyle(
                          color: TColors.white, fontSize: 16,
                          fontWeight: FontWeight.w700)))),
                ))
            else
              Column(children: [
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: widget.onRetry,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: widget.module.gradient,
                        borderRadius: BorderRadius.circular(14)),
                      child: Center(child: Text(
                        lang.s('Try Again', 'እንደገና ሞክሩ'),
                        style: const TextStyle(
                            color: TColors.white, fontSize: 16,
                            fontWeight: FontWeight.w700)))))),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: widget.onDone,
                  child: Text(lang.s('Back to module', 'ወደ ክፍሉ ተመለስ'),
                      style: TextStyle(fontSize: 14,
                          color: TColors.white.withOpacity(0.4)))),
              ]),
          ])),
        ],
      ),
    );
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
            blurRadius: size, spreadRadius: size * 0.2)]));
}

extension on double {
  double sin() => _sin(this);
  static double _sin(double x) {
    // Simple sin approximation for shake
    double result = x;
    double term = x;
    for (int i = 1; i < 8; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }
}
