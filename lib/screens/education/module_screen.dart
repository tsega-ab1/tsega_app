import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';
import '../../models/models.dart';
import 'quiz_screen.dart';

// ════════════════════════════════════════════════════════════════
// MODULE SCREEN
// Full article reader with read-progress bar
// Triggers QuizScreen when user reaches 90% of content
// ════════════════════════════════════════════════════════════════

class ModuleScreen extends StatefulWidget {
  final EducationModule module;
  const ModuleScreen({super.key, required this.module});

  @override
  State<ModuleScreen> createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  final _scrollCtrl = ScrollController();
  double _readProgress = 0.0;
  bool _quizUnlocked = false;
  bool _quizTriggered = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final max = _scrollCtrl.position.maxScrollExtent;
    if (max <= 0) return;
    final progress = (_scrollCtrl.offset / max).clamp(0.0, 1.0);
    setState(() {
      _readProgress = progress;
      if (progress >= 0.88 && !_quizUnlocked) {
        _quizUnlocked = true;
      }
    });
  }

  void _openQuiz() {
    if (_quizTriggered) return;
    _quizTriggered = true;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuizScreen(module: widget.module)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang   = context.watch<LanguageProvider>();
    final module = widget.module;
    final title   = lang.isAmharic ? module.titleAm : module.titleEn;
    final content = lang.isAmharic ? module.contentAm : module.contentEn;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Stack(children: [
        // Background
        Positioned(top: -60, right: -40,
            child: _Orb(260, TColors.teal500.withOpacity(0.10))),

        SafeArea(child: Column(children: [
          // ── EXPANDED HEADER ─────────────────────────────────
          _Header(
            module: module,
            title: title,
            lang: lang,
            readProgress: _readProgress,
            onBack: () => Navigator.pop(context),
          ),

          // ── READ PROGRESS BAR ────────────────────────────────
          Container(
            height: 3,
            color: const Color(0xFF0A1628),
            child: AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 100),
              widthFactor: _readProgress,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  gradient: module.gradient,
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(2),
                      bottomRight: Radius.circular(2))),
              ),
            ),
          ),

          // ── CONTENT ──────────────────────────────────────────
          Expanded(child: SingleChildScrollView(
            controller: _scrollCtrl,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Duration + category
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: TColors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      Icon(Icons.access_time_rounded,
                          color: TColors.white.withOpacity(0.4), size: 12),
                      const SizedBox(width: 4),
                      Text(module.duration,
                          style: TextStyle(fontSize: 11,
                              color: TColors.white.withOpacity(0.4))),
                    ])),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: module.gradient,
                      borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      lang.isAmharic
                          ? module.categoryAm : module.categoryEn,
                      style: const TextStyle(fontSize: 11,
                          color: TColors.white, fontWeight: FontWeight.w600)),
                  ),
                ]),
                const SizedBox(height: 20),

                // Article content
                _ArticleContent(
                  content: content.isEmpty
                      ? _demoContent(lang.isAmharic)
                      : content,
                  gradient: module.gradient,
                  lang: lang,
                ),

                const SizedBox(height: 32),

                // Progress indicator
                if (!_quizUnlocked)
                  Center(child: Column(children: [
                    Text(
                      lang.s('Keep reading to unlock the quiz',
                          'ፈተናውን ለመክፈት ማንበቡን ይቀጥሉ'),
                      style: TextStyle(fontSize: 12,
                          color: TColors.white.withOpacity(0.35))),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 120,
                      child: LinearProgressIndicator(
                        value: _readProgress,
                        backgroundColor: TColors.white.withOpacity(0.08),
                        valueColor: AlwaysStoppedAnimation(
                            module.gradient.colors.first),
                        minHeight: 3,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ])),
              ],
            ),
          )),
        ])),

        // ── QUIZ BUTTON (appears when ready) ─────────────────
        if (_quizUnlocked)
          Positioned(
            bottom: 24, left: 20, right: 20,
            child: GestureDetector(
              onTap: _openQuiz,
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  gradient: module.gradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(
                    color: module.gradient.colors.first.withOpacity(0.35),
                    blurRadius: 20, offset: const Offset(0, 8))]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.quiz_rounded,
                        color: TColors.white, size: 22),
                    const SizedBox(width: 10),
                    Text(lang.s('Take the Quiz →', 'ፈተናውን ይውሰዱ →'),
                        style: const TextStyle(
                            color: TColors.white, fontSize: 16,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
      ]),
    );
  }

  String _demoContent(bool am) => am
      ? '''ብረት ለጤና ጠቃሚ ማዕድን ነው። ሰውነት ኦክሲጅን ወደ ሁሉም ሕዋሳት ለማጓጓዝ ሄሞግሎቢን ለመሥራት ይጠቀምበታል።

**ለምን ብረት አስፈላጊ ነው?**

በእርግዝና ወቅት የሰውነትዎ የደም መጠን እስከ 50% ይጨምራል። ይህ ማለት ሕፃኑን ለማቅረብ ተጨማሪ ብረት ያስፈልጋል ማለት ነው።

**ምን ያህል ይፈልጋሉ?**

ለዕርጉዝ ሴቶች ዕለታዊ ፍላጎት ወደ 27mg ነው — ከዕርጉዝ ካልሆኑ ሴቶች ሁለት እጥፍ ያህል።

**በኢትዮጵያ ምን ምግቦች ብረት ይሰጣሉ?**

• ምስር ወጥ — ከፍ ያለ ብረት
• ጎመን — ፎሌትና ብረት  
• ጤፍ ኢንጀራ — ብረት + ካልሲየም
• ሽምብራ — ተክል ላይ የተመሠረተ ብረት
• አቮካዶ — ብረት መምጠጥ ለማሻሻል ቪታሚን C

**ጠቃሚ ምክር**

ለምሳሌ ቲማቲም ወይም ብርቱካን ያሉ ቪታሚን C ያላቸው ምግቦች ከብረት ምንጮች ጋር ብትበሉ ሰውነት ብረቱን ተሻሽሎ ይወስዳል።

የደም ማነስ (አኒሚያ) ኢትዮጵያ ውስጥ ለ23% ሴቶች ተጋላጭ ነው። ምልክቶቹ ድካም፣ ፊት ቢጫ መሆን እና ትንፋሽ ማጠር ናቸው።'''
      : '''Iron is an essential mineral for health. Your body uses it to make hemoglobin, which carries oxygen to every cell in your body.

**Why is iron so important?**

During pregnancy your blood volume increases by up to 50%. This means you need significantly more iron to supply both yourself and your growing baby.

**How much do you need?**

The daily requirement for pregnant women is around 27mg — roughly double what non-pregnant women need.

**Which Ethiopian foods are rich in iron?**

• Misir wot — high iron content
• Gomen — folate and iron together
• Teff injera — iron + calcium in every meal
• Shimbra (chickpeas) — plant-based iron
• Avocado — with Vitamin C to boost absorption

**Practical tip**

Eating iron-rich foods together with Vitamin C sources — such as tomatoes or orange — helps your body absorb significantly more iron from the same meal.

Iron deficiency anemia affects 23% of women in Ethiopia. Symptoms include fatigue, pale skin, and shortness of breath. The good news: it is preventable with the right foods.''';
}

// ── HEADER ────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final EducationModule module;
  final String title;
  final LanguageProvider lang;
  final double readProgress;
  final VoidCallback onBack;

  const _Header({
    required this.module, required this.title, required this.lang,
    required this.readProgress, required this.onBack,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(gradient: module.gradient),
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Back button
      GestureDetector(
        onTap: onBack,
        child: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: TColors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.arrow_back_ios_rounded,
              color: TColors.white, size: 17)),
      ),
      const SizedBox(height: 16),

      // Module icon
      Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          color: TColors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16)),
        child: Icon(module.icon, color: TColors.white, size: 28)),
      const SizedBox(height: 12),

      // Title
      Text(title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
              color: TColors.white, height: 1.2)),
      const SizedBox(height: 6),

      // Read progress
      Row(children: [
        Text(lang.s('Reading progress', 'የማንበብ ሂደት'),
            style: TextStyle(fontSize: 11,
                color: TColors.white.withOpacity(0.65))),
        const SizedBox(width: 8),
        Text('${(readProgress * 100).toInt()}%',
            style: const TextStyle(fontSize: 11,
                color: TColors.white, fontWeight: FontWeight.w700)),
      ]),
    ]),
  );
}

// ── ARTICLE CONTENT ───────────────────────────────────────────────
class _ArticleContent extends StatelessWidget {
  final String content;
  final LinearGradient gradient;
  final LanguageProvider lang;

  const _ArticleContent({
    required this.content, required this.gradient, required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final lines = content.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.trim().isEmpty) return const SizedBox(height: 10);

        // Bold heading **text**
        if (line.trim().startsWith('**') && line.trim().endsWith('**')) {
          final text = line.trim().replaceAll('**', '');
          return Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 16),
            child: Text(text, style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w800,
              color: gradient.colors.first, height: 1.3)),
          );
        }

        // Bullet point
        if (line.trim().startsWith('•')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    color: gradient.colors.first,
                    shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  line.trim().substring(1).trim(),
                  style: TextStyle(fontSize: 15, height: 1.7,
                      color: TColors.white.withOpacity(0.8)))),
              ],
            ),
          );
        }

        // Normal paragraph
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(line,
              style: TextStyle(fontSize: 15, height: 1.75,
                  color: TColors.white.withOpacity(0.8))),
        );
      }).toList(),
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
