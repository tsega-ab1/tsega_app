import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/providers/language_provider.dart';
import '../../models/models.dart';
import '../../services/storage_service.dart';
import '../../overlays/badge_overlay.dart';

class QuizScreen extends StatefulWidget {
  final EducationModule module;
  const QuizScreen({super.key, required this.module});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  int _current = 0;
  int? _selected;
  bool _answered = false;
  int _score = 0;
  bool _done = false;
  late AnimationController _ctrl;
  late Animation<Offset> _slide;

  List<QuizQuestion> get _questions => widget.module.quiz;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _slide = Tween<Offset>(
        begin: const Offset(1, 0), end: Offset.zero).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _selectAnswer(int i) {
    if (_answered) return;
    setState(() {
      _selected = i;
      _answered = true;
      if (i == _questions[_current].correctIndex) _score++;
    });
  }

  void _next() async {
    if (_current < _questions.length - 1) {
      setState(() {
        _current++;
        _selected = null;
        _answered = false;
      });
      _ctrl.reset();
      _ctrl.forward();
    } else {
      setState(() => _done = true);
      final passed = _score >= (_questions.length * 0.6).ceil();
      if (passed) {
        await StorageService.markModuleComplete(widget.module.id);
        // Check badge unlock
        final progress = StorageService.getModuleProgress();
        final doneCount = progress.values.where((v) => v).length;
        for (final badge in AchievementBadge.defaults) {
          if (doneCount >= badge.requiredModules) {
            await StorageService.unlockBadge(badge.id);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    if (_done) return _ResultScreen(
        score: _score, total: _questions.length,
        module: widget.module, lang: lang);

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(lang.quiz)),
        body: Center(child: Text(lang.s('No quiz available',
            'ፈተና አልተዘጋጀም'))),
      );
    }

    final q = _questions[_current];
    final options = lang.isAmharic ? q.optionsAm : q.optionsEn;

    return Scaffold(
      backgroundColor: TColors.cream,
      body: SafeArea(
        child: Column(children: [
          // Header
          Container(
            decoration: BoxDecoration(gradient: widget.module.gradient),
            padding: const EdgeInsets.fromLTRB(16, 16, 24, 24),
            child: Column(children: [
              Row(children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded,
                      color: TColors.white)),
                Expanded(child: Text(lang.quiz,
                    style: const TextStyle(
                        color: TColors.white, fontSize: 18,
                        fontWeight: FontWeight.w700))),
                Text('${_current + 1}/${_questions.length}',
                    style: TextStyle(
                        color: TColors.white.withOpacity(0.8))),
              ]),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_current + 1) / _questions.length,
                  backgroundColor: TColors.white.withOpacity(0.3),
                  color: TColors.white,
                  minHeight: 4,
                ),
              ),
            ]),
          ),

          Expanded(
            child: SlideTransition(
              position: _slide,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(lang.isAmharic ? q.questionAm : q.questionEn,
                        style: TTextStyles.headlineMedium.copyWith(height: 1.4)),
                    const SizedBox(height: 28),
                    ...List.generate(options.length, (i) {
                      Color bg = TColors.white;
                      Color border = TColors.border;
                      Color textCol = TColors.dark;

                      if (_answered) {
                        if (i == q.correctIndex) {
                          bg = TColors.green50;
                          border = TColors.green500;
                          textCol = TColors.green700;
                        } else if (i == _selected) {
                          bg = TColors.red100;
                          border = TColors.red400;
                          textCol = TColors.statusRed;
                        }
                      } else if (_selected == i) {
                        border = TColors.teal500;
                      }

                      return GestureDetector(
                        onTap: () => _selectAnswer(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: border, width: 2),
                          ),
                          child: Row(children: [
                            Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _answered && i == q.correctIndex
                                    ? TColors.green500
                                    : _answered && i == _selected
                                        ? TColors.red400
                                        : TColors.border,
                              ),
                              child: Center(child: Text(
                                String.fromCharCode(65 + i),
                                style: TextStyle(
                                    color: _answered ? TColors.white : TColors.gray,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(options[i],
                                style: TextStyle(
                                    color: textCol,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500))),
                            if (_answered && i == q.correctIndex)
                              const Icon(Icons.check_circle_rounded,
                                  color: TColors.green500),
                            if (_answered && i == _selected &&
                                i != q.correctIndex)
                              const Icon(Icons.cancel_rounded,
                                  color: TColors.red400),
                          ]),
                        ),
                      );
                    }),
                    const Spacer(),
                    if (_answered)
                      GestureDetector(
                        onTap: _next,
                        child: Container(
                          width: double.infinity, height: 52,
                          decoration: BoxDecoration(
                            gradient: widget.module.gradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(child: Text(
                            _current < _questions.length - 1
                                ? lang.next
                                : lang.s('See Results', 'ውጤቶቹን ተመልከቱ'),
                            style: const TextStyle(
                                color: TColors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16))),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── RESULT SCREEN ───────────────────────────────────────────────
class _ResultScreen extends StatelessWidget {
  final int score, total;
  final EducationModule module;
  final LanguageProvider lang;

  const _ResultScreen({
    required this.score, required this.total,
    required this.module, required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final passed = score >= (total * 0.6).ceil();
    final pct = total > 0 ? (score / total * 100).round() : 0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: module.gradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Trophy
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: TColors.white.withOpacity(0.2),
                  ),
                  child: Icon(
                    passed
                        ? Icons.emoji_events_rounded
                        : Icons.replay_rounded,
                    color: TColors.white, size: 60),
                ),
                const SizedBox(height: 28),
                Text(passed ? lang.quizPassed
                    : lang.s('Try Again', 'እንደገና ሞክሩ'),
                    style: const TextStyle(
                        color: TColors.white, fontSize: 28,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Text('$score / $total  ($pct%)',
                    style: TextStyle(
                        color: TColors.white.withOpacity(0.85),
                        fontSize: 18)),
                const SizedBox(height: 8),
                Text(
                  passed
                      ? lang.s(
                          'Module completed! You earned a badge.',
                          'ክፍሉ ተጠናቅቋል! ሽልማት አግኝተዋል።')
                      : lang.s(
                          'You need 60% to pass. Read the module again.',
                          '60% ያስፈልጋል። ክፍሉን እንደገና ያንብቡ።'),
                  style: TextStyle(
                      color: TColors.white.withOpacity(0.8),
                      fontSize: 14, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                GestureDetector(
                  onTap: () =>
                      Navigator.popUntil(context, (r) => r.isFirst),
                  child: Container(
                    width: double.infinity, height: 52,
                    decoration: BoxDecoration(
                      color: TColors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(child: Text(
                        lang.s('Back to Learning Hub', 'ወደ ትምህርት ማዕከሉ'),
                        style: TextStyle(
                            color: passed
                                ? TColors.teal700 : TColors.mid,
                            fontWeight: FontWeight.w700))),
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
