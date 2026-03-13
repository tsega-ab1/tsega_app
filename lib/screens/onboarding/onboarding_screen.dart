import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';
import '../auth/language_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _page = 0;
  late AnimationController _textCtrl;
  late Animation<Offset> _textSlide;
  late Animation<double> _textFade;

  final _pages = [
    _OPage(
      gradient: TGradients.gradTeal,
      icon: Icons.spa_rounded,
      titleEn: 'Your health,\nevery stage',
      titleAm: 'ጤናዎ፣\nበእያንዳንዱ ደረጃ',
      subEn: 'From your first period through menopause — Tsega understands your body at every life stage.',
      subAm: 'ከመጀመሪያ ወር አበባ እስከ ማቆሚያ — ጸጋ በእያንዳንዱ የህይወት ደረጃ አካልዎን ይረዳል።',
    ),
    _OPage(
      gradient: TGradients.gradBlue,
      icon: Icons.psychology_rounded,
      titleEn: 'AI that knows\nEthiopia',
      titleAm: 'ኢትዮጵያን\nያውቃል',
      subEn: 'Our AI is calibrated for Ethiopian altitude, diet, and fasting seasons — not Western baselines.',
      subAm: 'ሰው ሰራሽ ብልሃታችን ለኢትዮጵያ ከፍታ፣ አመጋገብ እና የጾም ወቅቶች ተዘጋጅቷል።',
    ),
    _OPage(
      gradient: TGradients.gradGreen,
      icon: Icons.health_and_safety_rounded,
      titleEn: 'Detect risks\n2–4 weeks early',
      titleAm: 'አደጋዎችን\n2-4 ሳምንት ቀደም',
      subEn: 'Tsega predicts preeclampsia, anemia, and PCOS before symptoms appear — giving you time to act.',
      subAm: 'ጸጋ ምልክቶች ከመታየታቸው በፊት ቅድመ-ወሊድ ከፍተኛ ደም ግፊት ይተነብያል።',
    ),
    _OPage(
      gradient: TGradients.gradPink,
      icon: Icons.family_restroom_rounded,
      titleEn: 'Your partner,\ninformed',
      titleAm: 'ሸሪካዎ፣\nያሳወቀ',
      subEn: 'Educate the people who love you. SMS alerts and danger sign guidance for partners and family.',
      subAm: 'የሚወዷቸውን ሰዎች ያስተምሩ። ለሸሪካዎ እና ቤተሰቦ SMS ማንቂያዎች።',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _textSlide = Tween<Offset>(
        begin: const Offset(0, 0.3), end: Offset.zero).animate(
        CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _textFade = CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn);
    _textCtrl.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  void _onPageChanged(int i) {
    setState(() => _page = i);
    _textCtrl.reset();
    _textCtrl.forward();
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final p = _pages[_page];
    return Scaffold(
      body: Stack(children: [
        PageView.builder(
          controller: _pageCtrl,
          onPageChanged: _onPageChanged,
          itemCount: _pages.length,
          itemBuilder: (_, i) {
            final page = _pages[i];
            return Container(
              decoration: BoxDecoration(gradient: page.gradient),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon container
                      Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: TColors.white.withOpacity(0.2),
                          border: Border.all(
                              color: TColors.white.withOpacity(0.4), width: 2),
                        ),
                        child: Icon(page.icon,
                            color: TColors.white, size: 56),
                      ),
                      const SizedBox(height: 48),
                      SlideTransition(
                        position: _textSlide,
                        child: FadeTransition(
                          opacity: _textFade,
                          child: Column(children: [
                            Text(
                              lang.isAmharic ? page.titleAm : page.titleEn,
                              style: const TextStyle(fontSize: 30,
                                  color: TColors.white,
                                  fontWeight: FontWeight.w700, height: 1.2),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              lang.isAmharic ? page.subAm : page.subEn,
                              style: TextStyle(fontSize: 15,
                                  color: TColors.white.withOpacity(0.88),
                                  height: 1.6),
                              textAlign: TextAlign.center,
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        // Bottom controls
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dots
                Row(children: List.generate(_pages.length, (i) =>
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 6),
                      width: i == _page ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _page
                            ? TColors.white
                            : TColors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ))),
                // Next / Get started button
                GestureDetector(
                  onTap: _next,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    decoration: BoxDecoration(
                      color: TColors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      _page == _pages.length - 1
                          ? lang.getStarted
                          : lang.next,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: TColors.teal700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class _OPage {
  final LinearGradient gradient;
  final IconData icon;
  final String titleEn, titleAm, subEn, subAm;
  const _OPage({
    required this.gradient, required this.icon,
    required this.titleEn, required this.titleAm,
    required this.subEn, required this.subAm,
  });
}
