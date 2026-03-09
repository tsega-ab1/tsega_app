import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

void main() {
  runApp(const TsegaApp());
}

// ─── THEME COLORS ───────────────────────────────────────────────
class TColors {
  // Primary teal family
  static const teal900 = Color(0xFF004D4D);
  static const teal700 = Color(0xFF006B6B);
  static const teal500 = Color(0xFF009999);
  static const teal300 = Color(0xFF4DC4C4);
  static const teal100 = Color(0xFFB2E8E8);
  static const teal50  = Color(0xFFE0F7F7);

  // Blue family (health)
  static const blue700 = Color(0xFF1565C0);
  static const blue500 = Color(0xFF2196F3);
  static const blue300 = Color(0xFF64B5F6);
  static const blue100 = Color(0xFFBBDEFB);
  static const blue50  = Color(0xFFE3F2FD);

  // Green family (wellness)
  static const green700 = Color(0xFF2E7D32);
  static const green500 = Color(0xFF4CAF50);
  static const green300 = Color(0xFF81C784);
  static const green100 = Color(0xFFC8E6C9);
  static const green50  = Color(0xFFE8F5E9);

  // Pink/Red family (feminine)
  static const pink700 = Color(0xFFC2185B);
  static const pink500 = Color(0xFFE91E63);
  static const pink300 = Color(0xFFF06292);
  static const pink100 = Color(0xFFF8BBD0);
  static const pink50  = Color(0xFFFCE4EC);
  static const red400  = Color(0xFFEF5350);
  static const red100  = Color(0xFFFFCDD2);

  // Neutrals
  static const dark   = Color(0xFF1A1A2E);
  static const mid    = Color(0xFF4A4A6A);
  static const gray   = Color(0xFF8A8AAA);
  static const border = Color(0xFFE0E0F0);
  static const cream  = Color(0xFFF8F8FF);
  static const white  = Color(0xFFFFFFFF);

  // Gradients
  static const gradTeal = LinearGradient(
    colors: [teal700, teal500, blue500],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const gradBlue = LinearGradient(
    colors: [blue700, blue500, teal300],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const gradGreen = LinearGradient(
    colors: [teal500, green500, green300],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const gradPink = LinearGradient(
    colors: [pink700, pink500, pink300],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const gradSoft = LinearGradient(
    colors: [Color(0xFFF8F8FF), Color(0xFFE0F7F7), Color(0xFFE3F2FD)],
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
  );
}

// ─── APP ────────────────────────────────────────────────────────
class TsegaApp extends StatelessWidget {
  const TsegaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tsega ጸጋ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: TColors.teal700),
        scaffoldBackgroundColor: TColors.cream,
      ),
      home: const SplashScreen(),
    );
  }
}

// ─── SPLASH ─────────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade, _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: TColors.gradTeal),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Logo circle
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: TColors.white.withOpacity(0.15),
                    border: Border.all(color: TColors.white.withOpacity(0.4), width: 2),
                  ),
                  child: const Center(
                    child: Text('ጸጋ', style: TextStyle(fontSize: 52,
                        color: TColors.white, fontWeight: FontWeight.w300)),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('TSEGA', style: TextStyle(fontSize: 36,
                    color: TColors.white, fontWeight: FontWeight.w700,
                    letterSpacing: 6)),
                const SizedBox(height: 8),
                Text('Precision Health for Every Woman',
                    style: TextStyle(fontSize: 14, color: TColors.white.withOpacity(0.85),
                        letterSpacing: 1.2)),
                const SizedBox(height: 48),
                SizedBox(width: 40, height: 40,
                  child: CircularProgressIndicator(
                    color: TColors.white.withOpacity(0.7), strokeWidth: 2)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── ONBOARDING ─────────────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  final _pages = [
    _OnboardPage(
      gradient: TColors.gradTeal,
      emoji: '🌸',
      title: 'Your health,\nevery stage',
      sub: 'From your first period through menopause — Tsega understands your body at every life stage.',
    ),
    _OnboardPage(
      gradient: TColors.gradBlue,
      emoji: '🤖',
      title: 'AI that knows\nEthiopia',
      sub: 'Our AI is calibrated for Ethiopian altitude, diet, and fasting seasons — not Western baselines.',
    ),
    _OnboardPage(
      gradient: TColors.gradGreen,
      emoji: '💚',
      title: 'Detect risks\n2–4 weeks early',
      sub: 'Tsega predicts preeclampsia, anemia, and PCOS before symptoms appear — giving you time to act.',
    ),
    _OnboardPage(
      gradient: TColors.gradPink,
      emoji: '👨‍👩‍👧',
      title: 'Your partner,\ninformed',
      sub: 'Educate the people who love you. SMS alerts and danger sign guidance for partners and family.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        PageView.builder(
          controller: _pageCtrl,
          onPageChanged: (i) => setState(() => _page = i),
          itemCount: _pages.length,
          itemBuilder: (_, i) => _OnboardPageWidget(data: _pages[i]),
        ),
        // Dots + button
        Positioned(
          bottom: 48, left: 24, right: 24,
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == _page ? 24 : 8, height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: TColors.white.withOpacity(i == _page ? 1 : 0.4),
                ),
              ))),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                if (_page < _pages.length - 1) {
                  _pageCtrl.nextPage(duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut);
                } else {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const LifeStageScreen()));
                }
              },
              child: Container(
                height: 56, decoration: BoxDecoration(
                  color: TColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: TColors.white.withOpacity(0.5), width: 1.5),
                ),
                child: Center(child: Text(
                  _page < _pages.length - 1 ? 'Continue →' : 'Get Started',
                  style: const TextStyle(color: TColors.white, fontSize: 16,
                      fontWeight: FontWeight.w600),
                )),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _OnboardPage {
  final LinearGradient gradient;
  final String emoji, title, sub;
  const _OnboardPage({required this.gradient, required this.emoji,
    required this.title, required this.sub});
}

class _OnboardPageWidget extends StatelessWidget {
  final _OnboardPage data;
  const _OnboardPageWidget({super.key, required this.data});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: data.gradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(data.emoji, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 40),
            Text(data.title, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 36, color: TColors.white,
                  fontWeight: FontWeight.w700, height: 1.2)),
            const SizedBox(height: 20),
            Text(data.sub, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: TColors.white.withOpacity(0.85),
                  height: 1.6)),
          ]),
        ),
      ),
    );
  }
}

// ─── LIFE STAGE SELECTOR ────────────────────────────────────────
class LifeStageScreen extends StatelessWidget {
  const LifeStageScreen({super.key});

  final _stages = const [
    {'emoji': '🌱', 'label': 'Adolescence', 'sub': 'Ages 12–18', 'grad': TColors.gradGreen},
    {'emoji': '🌸', 'label': 'Reproductive', 'sub': 'Cycle tracking', 'grad': TColors.gradPink},
    {'emoji': '🤰', 'label': 'Pregnancy', 'sub': 'Week by week', 'grad': TColors.gradTeal},
    {'emoji': '🍼', 'label': 'Postpartum', 'sub': 'Recovery care', 'grad': TColors.gradBlue},
    {'emoji': '🌿', 'label': 'Menopause', 'sub': 'Transition support', 'grad': TColors.gradGreen},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: TColors.gradSoft),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 20),
              const Text('Welcome to Tsega ጸጋ',
                style: TextStyle(fontSize: 14, color: TColors.teal700,
                    fontWeight: FontWeight.w600, letterSpacing: 1)),
              const SizedBox(height: 8),
              const Text('What is your\ncurrent life stage?',
                style: TextStyle(fontSize: 30, color: TColors.dark,
                    fontWeight: FontWeight.w700, height: 1.2)),
              const SizedBox(height: 8),
              const Text('We\'ll personalize everything for you.',
                style: TextStyle(fontSize: 14, color: TColors.gray)),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: _stages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final s = _stages[i];
                    return GestureDetector(
                      onTap: () => Navigator.pushReplacement(ctx,
                          MaterialPageRoute(builder: (_) => const MainShell())),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: TColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: TColors.border),
                          boxShadow: [BoxShadow(
                            color: TColors.teal700.withOpacity(0.06),
                            blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: Row(children: [
                          Container(width: 52, height: 52,
                            decoration: BoxDecoration(
                              gradient: s['grad'] as LinearGradient,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(child: Text(s['emoji'] as String,
                                style: const TextStyle(fontSize: 24)))),
                          const SizedBox(width: 16),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(s['label'] as String,
                              style: const TextStyle(fontSize: 17,
                                  fontWeight: FontWeight.w700, color: TColors.dark)),
                            Text(s['sub'] as String,
                              style: const TextStyle(fontSize: 13, color: TColors.gray)),
                          ])),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: TColors.gray),
                        ]),
                      ),
                    );
                  },
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─── MAIN SHELL with floating AI button ─────────────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  final _screens = const [
    HomeScreen(),
    CycleScreen(),
    InsightsScreen(),
    EducationScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        _screens[_tab],
        // Floating AI Chat Button
        Positioned(
          right: 20, bottom: 88,
          child: _FloatingAIButton(),
        ),
      ]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: TColors.white,
          boxShadow: [BoxShadow(color: TColors.teal700.withOpacity(0.08),
              blurRadius: 20, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_rounded, label: 'Home', index: 0, current: _tab, onTap: (i) => setState(() => _tab = i)),
                _NavItem(icon: Icons.calendar_month_rounded, label: 'Cycle', index: 1, current: _tab, onTap: (i) => setState(() => _tab = i)),
                _NavItem(icon: Icons.auto_awesome_rounded, label: 'Insights', index: 2, current: _tab, onTap: (i) => setState(() => _tab = i)),
                _NavItem(icon: Icons.menu_book_rounded, label: 'Learn', index: 3, current: _tab, onTap: (i) => setState(() => _tab = i)),
                _NavItem(icon: Icons.person_rounded, label: 'Profile', index: 4, current: _tab, onTap: (i) => setState(() => _tab = i)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index, current;
  final Function(int) onTap;
  const _NavItem({required this.icon, required this.label,
    required this.index, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: active ? TColors.gradTeal : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 22, color: active ? TColors.white : TColors.gray),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10,
              color: active ? TColors.white : TColors.gray,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
        ]),
      ),
    );
  }
}

// ─── FLOATING AI BUTTON ──────────────────────────────────────────
class _FloatingAIButton extends StatefulWidget {
  @override
  State<_FloatingAIButton> createState() => _FloatingAIButtonState();
}

class _FloatingAIButtonState extends State<_FloatingAIButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this,
        duration: const Duration(seconds: 2), lowerBound: 0.9, upperBound: 1.0)
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulse,
      child: GestureDetector(
        onTap: () => showModalBottomSheet(
          context: context, isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const AIChatSheet(),
        ),
        child: Container(
          width: 58, height: 58,
          decoration: BoxDecoration(
            gradient: TColors.gradTeal,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: TColors.teal500.withOpacity(0.5),
                  blurRadius: 16, spreadRadius: 2),
            ],
          ),
          child: const Center(
            child: Text('AI', style: TextStyle(color: TColors.white,
                fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 0.5)),
          ),
        ),
      ),
    );
  }
}

// ─── AI CHAT SHEET ───────────────────────────────────────────────
class AIChatSheet extends StatefulWidget {
  const AIChatSheet({super.key});
  @override
  State<AIChatSheet> createState() => _AIChatSheetState();
}

class _AIChatSheetState extends State<AIChatSheet> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _msgs = <_ChatMsg>[
    _ChatMsg(false, 'Hi Selam! 👋 I\'m your Tsega AI assistant. I\'m here to help with cycle tracking, pregnancy questions, danger signs, and more.\n\nWhat\'s on your mind today?'),
  ];

  final _quickReplies = [
    'Is my cycle normal?',
    'What are danger signs?',
    'My Hb is 11.2 g/dL — is that okay?',
    'I have a headache today',
  ];

  final _responses = {
    'Is my cycle normal?': 'Based on your last 3 logged cycles (27, 28, 28 days), your cycle is very regular! ✅\n\nNormal range: 21–35 days. Yours is right on target.\n\n📍 Ethiopian note: Stress during fasting seasons (Tsome) can cause a 1–3 day shift — this is normal.',
    'What are danger signs?': '⚠️ Danger signs during pregnancy:\n\n🔴 Severe headache that won\'t go away\n🔴 Blurred vision or spots\n🔴 Severe swelling in hands/face\n🔴 Upper stomach pain (under ribs)\n🔴 Less baby movement than usual\n🔴 Heavy vaginal bleeding\n\nIf you experience ANY of these — go to hospital immediately. Don\'t wait.',
    'My Hb is 11.2 g/dL — is that okay?': '📊 Your Hemoglobin: 11.2 g/dL\n\n⚡ Ethiopian altitude adjustment (Addis Ababa, 2,300m):\nYour adjusted threshold is 11.0 g/dL (lower than sea-level 12.0).\n\n✅ Your result: Borderline — mild anemia risk.\n\nRecommendation: Take your iron supplements daily, eat injera with lentils (rich in iron), and get retested in 4 weeks. Ask your doctor about IV iron if supplements don\'t improve it.',
    'I have a headache today': '💭 Logging your headache...\n\nA few questions to assess:\n• Severity 1–10?\n• Any vision changes (blurred, spots)?\n• Any swelling in hands or face?\n• What week of pregnancy are you?\n\n⚠️ If your headache is severe + you have blurred vision or swelling — please go to the hospital today. This could be a preeclampsia warning sign.\n\n💊 If mild: rest, drink water, avoid bright screens.',
  };

  void _send(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _msgs.add(_ChatMsg(true, text));
      _ctrl.clear();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      final reply = _responses[text] ??
          'That\'s a great question! Based on your health profile, I\'d recommend logging this symptom and consulting your healthcare provider if it persists. I\'m tracking this for your health history. 📝';
      setState(() => _msgs.add(_ChatMsg(false, reply)));
      Future.delayed(const Duration(milliseconds: 100), () {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(children: [
        // Handle
        Container(margin: const EdgeInsets.only(top: 12),
          width: 40, height: 4,
          decoration: BoxDecoration(color: TColors.border,
              borderRadius: BorderRadius.circular(2))),
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          decoration: const BoxDecoration(gradient: TColors.gradTeal,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          child: Row(children: [
            Container(width: 40, height: 40,
              decoration: BoxDecoration(
                color: TColors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(child: Text('AI',
                style: TextStyle(color: TColors.white,
                    fontWeight: FontWeight.w800, fontSize: 13)))),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Tsega AI Assistant',
                style: TextStyle(color: TColors.white,
                    fontWeight: FontWeight.w700, fontSize: 16)),
              Text('Powered by MedGemma · Ethiopian health context',
                style: TextStyle(color: Colors.white70, fontSize: 11)),
            ])),
            IconButton(icon: const Icon(Icons.close, color: TColors.white),
              onPressed: () => Navigator.pop(context)),
          ]),
        ),
        // Messages
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(16),
            itemCount: _msgs.length,
            itemBuilder: (_, i) {
              final m = _msgs[i];
              return _ChatBubble(msg: m);
            },
          ),
        ),
        // Quick replies
        if (_msgs.length < 3)
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quickReplies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => _send(_quickReplies[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: TColors.teal300),
                    borderRadius: BorderRadius.circular(20),
                    color: TColors.teal50,
                  ),
                  child: Text(_quickReplies[i],
                    style: const TextStyle(fontSize: 12, color: TColors.teal700,
                        fontWeight: FontWeight.w500)),
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        // Input
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                onSubmitted: _send,
                decoration: InputDecoration(
                  hintText: 'Ask anything about your health...',
                  hintStyle: const TextStyle(color: TColors.gray, fontSize: 14),
                  filled: true, fillColor: TColors.teal50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _send(_ctrl.text),
              child: Container(width: 48, height: 48,
                decoration: const BoxDecoration(
                    gradient: TColors.gradTeal, shape: BoxShape.circle),
                child: const Icon(Icons.send_rounded, color: TColors.white, size: 20)),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _ChatMsg { final bool isUser; final String text;
  const _ChatMsg(this.isUser, this.text); }

class _ChatBubble extends StatelessWidget {
  final _ChatMsg msg;
  const _ChatBubble({super.key, required this.msg});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!msg.isUser) ...[
            Container(width: 32, height: 32,
              decoration: const BoxDecoration(gradient: TColors.gradTeal, shape: BoxShape.circle),
              child: const Center(child: Text('AI',
                style: TextStyle(color: TColors.white, fontSize: 10, fontWeight: FontWeight.w800)))),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: msg.isUser ? TColors.gradPink : null,
                color: msg.isUser ? null : TColors.teal50,
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomRight: msg.isUser ? const Radius.circular(4) : null,
                  bottomLeft: msg.isUser ? null : const Radius.circular(4),
                ),
              ),
              child: Text(msg.text,
                style: TextStyle(fontSize: 14, height: 1.5,
                    color: msg.isUser ? TColors.white : TColors.dark)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── HOME SCREEN ─────────────────────────────────────────────────
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.cream,
      body: CustomScrollView(slivers: [
        // App bar
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: TColors.teal700,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: TColors.gradTeal),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Welcome back,',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const Text('Selam ሰላም 👋',
                          style: TextStyle(color: TColors.white, fontSize: 24,
                              fontWeight: FontWeight.w700)),
                      ])),
                      Container(width: 44, height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: TColors.gradPink,
                          border: Border.all(color: TColors.white, width: 2),
                        ),
                        child: const Center(child: Text('S',
                          style: TextStyle(color: TColors.white,
                              fontWeight: FontWeight.w700, fontSize: 18)))),
                    ]),
                    const SizedBox(height: 16),
                    // Lifecycle flow
                    const _LifecycleBar(),
                  ]),
                ),
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              // Alert card
              _AlertCard(),
              const SizedBox(height: 16),
              // Quick stats row
              Row(children: [
                Expanded(child: _StatCard('Cycle Day', '14', '🌸', TColors.gradPink, 'Fertile window')),
                const SizedBox(width: 12),
                Expanded(child: _StatCard('Hb Level', '11.2', '🩸', TColors.gradBlue, 'g/dL · borderline')),
                const SizedBox(width: 12),
                Expanded(child: _StatCard('Risk Score', 'Low', '✅', TColors.gradGreen, 'All good today')),
              ]),
              const SizedBox(height: 20),
              // Daily health log
              _DailyLogCard(),
              const SizedBox(height: 16),
              // AI insight card
              _AIInsightCard(),
              const SizedBox(height: 16),
              // Partner card
              _PartnerCard(),
              const SizedBox(height: 80),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _LifecycleBar extends StatelessWidget {
  const _LifecycleBar();
  @override
  Widget build(BuildContext context) {
    final stages = ['Repro.', 'Precon.', 'Pregnancy', 'Postpart.', 'Menopause'];
    final active = 2;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Lifecycle Stage', style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 0.5)),
      const SizedBox(height: 8),
      Row(children: List.generate(stages.length * 2 - 1, (i) {
        if (i.isOdd) return Expanded(child: Container(height: 2,
            color: TColors.white.withOpacity(i ~/ 2 < active ? 1 : 0.3)));
        final idx = i ~/ 2;
        final isActive = idx == active;
        final isPast = idx < active;
        return Column(children: [
          Container(width: isActive ? 14 : 10, height: isActive ? 14 : 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? TColors.white : isPast ? TColors.white.withOpacity(0.7) : TColors.white.withOpacity(0.3),
              boxShadow: isActive ? [BoxShadow(color: TColors.white.withOpacity(0.5), blurRadius: 8, spreadRadius: 2)] : [],
            )),
          const SizedBox(height: 4),
          Text(stages[idx], style: TextStyle(fontSize: 9,
              color: TColors.white.withOpacity(isActive ? 1 : 0.6),
              fontWeight: isActive ? FontWeight.w700 : FontWeight.normal)),
        ]);
      })),
    ]);
  }
}

class _AlertCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFB74D).withOpacity(0.5)),
      ),
      child: Row(children: [
        const Text('⚠️', style: TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ANC Appointment Reminder',
            style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFE65100), fontSize: 14)),
          SizedBox(height: 2),
          Text('Your next visit is in 3 days (April 23). We\'ve pre-filled your risk report for Dr. Abebe.',
            style: TextStyle(fontSize: 12, color: Color(0xFFBF360C), height: 1.4)),
        ])),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, emoji, sub;
  final LinearGradient grad;
  const _StatCard(this.label, this.value, this.emoji, this.grad, this.sub);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: TColors.teal700.withOpacity(0.07),
            blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 20,
            fontWeight: FontWeight.w800, color: TColors.dark)),
        Text(label, style: const TextStyle(fontSize: 11,
            fontWeight: FontWeight.w600, color: TColors.mid)),
        const SizedBox(height: 2),
        Text(sub, style: const TextStyle(fontSize: 10, color: TColors.gray)),
      ]),
    );
  }
}

class _DailyLogCard extends StatefulWidget {
  @override
  State<_DailyLogCard> createState() => _DailyLogCardState();
}

class _DailyLogCardState extends State<_DailyLogCard> {
  int _mood = 2;
  bool _logged = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: TColors.teal700.withOpacity(0.07),
            blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Daily Health Log',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: TColors.dark))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: TColors.green50, borderRadius: BorderRadius.circular(12)),
            child: const Text('Active ✓',
              style: TextStyle(fontSize: 11, color: TColors.green700, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 16),
        // Two column layout
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Manual Clinical Signs',
              style: TextStyle(fontSize: 11, color: TColors.gray, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            _LogRow('🌡️', 'Temp', '36.8°C'),
            _LogRow('💧', 'Cervical Mucus', 'Watery'),
            _LogRow('🩸', 'Blood Flow', 'None today'),
          ])),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Wearable Data',
              style: TextStyle(fontSize: 11, color: TColors.gray, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            _LogRow('❤️', 'Heart Rate', '74 BPM'),
            _LogRow('🦶', 'Steps', '4,110'),
            _LogRow('😴', 'Sleep', '6.5 hrs'),
          ])),
        ]),
        const SizedBox(height: 16),
        const Text('Mood today',
          style: TextStyle(fontSize: 12, color: TColors.mid, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['😔', '😐', '🙂', '😊', '🤩'].asMap().entries.map((e) =>
            GestureDetector(
              onTap: () => setState(() => _mood = e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: e.key == _mood ? TColors.teal50 : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: e.key == _mood ? TColors.teal500 : TColors.border,
                    width: e.key == _mood ? 2 : 1),
                ),
                child: Center(child: Text(e.value, style: const TextStyle(fontSize: 22))),
              ),
            )).toList()),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => setState(() => _logged = !_logged),
          child: Container(
            height: 48, decoration: BoxDecoration(
              gradient: _logged ? TColors.gradGreen : TColors.gradTeal,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(
              _logged ? '✓ Logged Successfully!' : 'Log New Symptom',
              style: const TextStyle(color: TColors.white,
                  fontWeight: FontWeight.w700, fontSize: 14))),
          ),
        ),
      ]),
    );
  }
}

class _LogRow extends StatelessWidget {
  final String icon, label, value;
  const _LogRow(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Text(icon, style: const TextStyle(fontSize: 14)),
      const SizedBox(width: 6),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 10, color: TColors.gray)),
        Text(value, style: const TextStyle(fontSize: 12,
            fontWeight: FontWeight.w600, color: TColors.dark)),
      ])),
    ]),
  );
}

class _AIInsightCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004D4D), Color(0xFF006B6B), Color(0xFF1565C0)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: TColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10)),
            child: const Text('Tsega AI · MedGemma',
              style: TextStyle(color: TColors.white, fontSize: 11, fontWeight: FontWeight.w600))),
          const Spacer(),
          const Text('🤖', style: TextStyle(fontSize: 20)),
        ]),
        const SizedBox(height: 14),
        const Text('Predictive Insight for Selam',
          style: TextStyle(color: TColors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('Your cycle regularity is consistent (27–28 days). Hemoglobin trend: 11.2 g/dL — altitude-adjusted risk is borderline. Consider tracking Basal Body Temperature for enhanced precision.',
          style: TextStyle(color: TColors.white.withOpacity(0.85), fontSize: 13, height: 1.5)),
        const SizedBox(height: 14),
        // Risk indicators
        Row(children: [
          _RiskBadge('Anemia', 'Moderate', const Color(0xFFFFA726)),
          const SizedBox(width: 8),
          _RiskBadge('Preeclampsia', 'Low', TColors.green300),
          const SizedBox(width: 8),
          _RiskBadge('PCOS', 'Low', TColors.green300),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: TColors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: TColors.white.withOpacity(0.2)),
          ),
          child: const Row(children: [
            Text('View Full Analysis', style: TextStyle(color: TColors.white,
                fontWeight: FontWeight.w600, fontSize: 13)),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: TColors.white, size: 12),
          ]),
        ),
      ]),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  final String label, level;
  final Color color;
  const _RiskBadge(this.label, this.level, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.2),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.5)),
    ),
    child: Column(children: [
      Text(label, style: const TextStyle(color: TColors.white, fontSize: 10)),
      Text(level, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    ]),
  );
}

class _PartnerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFCE4EC), Color(0xFFF3E5F5)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TColors.pink100),
      ),
      child: Row(children: [
        const Text('👨‍👩‍👧', style: TextStyle(fontSize: 36)),
        const SizedBox(width: 16),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Partner Engaged ✓',
            style: TextStyle(fontWeight: FontWeight.w700, color: TColors.pink700, fontSize: 14)),
          SizedBox(height: 4),
          Text('Abebe received today\'s health summary via SMS. He\'s been educated on preeclampsia danger signs.',
            style: TextStyle(fontSize: 12, color: TColors.mid, height: 1.4)),
        ])),
      ]),
    );
  }
}

// ─── CYCLE SCREEN ────────────────────────────────────────────────
class CycleScreen extends StatefulWidget {
  const CycleScreen({super.key});
  @override
  State<CycleScreen> createState() => _CycleScreenState();
}

class _CycleScreenState extends State<CycleScreen> {
  int _selectedDay = 14;
  final _today = 14;

  // Day types: 0=normal, 1=period, 2=fertile, 3=ovulation
  final Map<int, int> _dayTypes = {
    1: 1, 2: 1, 3: 1, 4: 1, 5: 1,
    10: 2, 11: 2, 12: 2, 13: 2,
    14: 3,
    15: 2, 16: 2,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.cream,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 120,
          backgroundColor: TColors.pink700,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: TColors.gradPink),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Cycle Tracker', style: TextStyle(
                        color: TColors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                    Text('March 2026 · Day $_today of 28',
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ]),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            // Cycle summary row
            Row(children: [
              Expanded(child: _CycleStat('Next Period', 'Mar 28', '🩸', TColors.gradPink)),
              const SizedBox(width: 12),
              Expanded(child: _CycleStat('Ovulation', 'Mar 14', '💚', TColors.gradGreen)),
              const SizedBox(width: 12),
              Expanded(child: _CycleStat('Cycle Avg', '28 days', '📊', TColors.gradBlue)),
            ]),
            const SizedBox(height: 20),
            // Calendar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: TColors.pink700.withOpacity(0.07),
                    blurRadius: 16, offset: const Offset(0, 4))],
              ),
              child: Column(children: [
                // Weekday labels
                Row(children: ['S','M','T','W','T','F','S'].map((d) =>
                    Expanded(child: Center(child: Text(d,
                      style: const TextStyle(fontSize: 12, color: TColors.gray,
                          fontWeight: FontWeight.w600))))).toList()),
                const SizedBox(height: 12),
                // Day grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7, mainAxisSpacing: 6, crossAxisSpacing: 4),
                  itemCount: 31,
                  itemBuilder: (_, i) {
                    final day = i + 1;
                    final type = _dayTypes[day] ?? 0;
                    final isSelected = day == _selectedDay;
                    final isToday = day == _today;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDay = day),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: isSelected ? TColors.gradPink :
                            type == 1 ? const LinearGradient(colors: [Color(0xFFE91E63), Color(0xFFF06292)]) :
                            type == 2 ? const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF81C784)]) :
                            type == 3 ? const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF64B5F6)]) : null,
                          color: isSelected || type != 0 ? null : TColors.cream,
                          borderRadius: BorderRadius.circular(10),
                          border: isToday ? Border.all(color: TColors.pink500, width: 2) : null,
                        ),
                        child: Center(child: Text('$day',
                          style: TextStyle(fontSize: 13,
                            color: isSelected || type != 0 ? TColors.white : TColors.dark,
                            fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.normal))),
                      ),
                    );
                  },
                ),
              ]),
            ),
            const SizedBox(height: 16),
            // Legend
            Wrap(spacing: 12, runSpacing: 8, children: [
              _Legend('🩸', 'Period', TColors.pink500),
              _Legend('💚', 'Fertile Window', TColors.green500),
              _Legend('💙', 'Ovulation', TColors.blue500),
              _Legend('⚪', 'Normal', TColors.gray),
            ]),
            const SizedBox(height: 20),
            // Symptom log
            _SymptomLogger(),
            const SizedBox(height: 80),
          ]),
        )),
      ]),
    );
  }
}

class _CycleStat extends StatelessWidget {
  final String label, value, emoji;
  final LinearGradient grad;
  const _CycleStat(this.label, this.value, this.emoji, this.grad);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: TColors.white, borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: TColors.pink700.withOpacity(0.06),
          blurRadius: 10, offset: const Offset(0, 3))],
    ),
    child: Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 20)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 15,
          fontWeight: FontWeight.w800, color: TColors.dark)),
      Text(label, style: const TextStyle(fontSize: 10, color: TColors.gray)),
    ]),
  );
}

class _Legend extends StatelessWidget {
  final String emoji, label;
  final Color color;
  const _Legend(this.emoji, this.label, this.color);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Text(emoji, style: const TextStyle(fontSize: 14)),
    const SizedBox(width: 4),
    Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
  ]);
}

class _SymptomLogger extends StatefulWidget {
  @override
  State<_SymptomLogger> createState() => _SymptomLoggerState();
}

class _SymptomLoggerState extends State<_SymptomLogger> {
  final _symptoms = {'Cramps': false, 'Headache': false, 'Bloating': false,
    'Fatigue': false, 'Nausea': false, 'Back Pain': false, 'Mood Swings': false, 'Spotting': false};

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: TColors.white, borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: TColors.pink700.withOpacity(0.07),
          blurRadius: 16, offset: const Offset(0, 4))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Log Today\'s Symptoms',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: TColors.dark)),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: _symptoms.keys.map((s) {
        final active = _symptoms[s]!;
        return GestureDetector(
          onTap: () => setState(() => _symptoms[s] = !active),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: active ? TColors.gradPink : null,
              color: active ? null : TColors.pink50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: active ? Colors.transparent : TColors.pink100),
            ),
            child: Text(s, style: TextStyle(
              color: active ? TColors.white : TColors.pink700,
              fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        );
      }).toList()),
    ]),
  );
}

// ─── INSIGHTS SCREEN ─────────────────────────────────────────────
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.cream,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true, expandedHeight: 110,
          backgroundColor: TColors.blue700,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: TColors.gradBlue),
              child: const SafeArea(child: Padding(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('AI Health Insights', style: TextStyle(
                      color: TColors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                  Text('Powered by MedGemma · Updated today',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                ]),
              )),
            ),
          ),
        ),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            // Overall score
            _OverallScore(),
            const SizedBox(height: 20),
            // Risk cards
            _RiskCard(
              title: 'Anemia Risk',
              level: 'Moderate',
              levelColor: const Color(0xFFF57C00),
              gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF2196F3), Color(0xFF64B5F6)]),
              icon: '🩸',
              description: 'Hb: 11.2 g/dL · Altitude-adjusted threshold at 2,300m: 11.0 g/dL\nYour iron stores are borderline. Current trend: stable.',
              bars: [('Hemoglobin', 0.56), ('Iron Stores', 0.40), ('Folate', 0.70)],
              action: 'Take iron supplements daily with Vitamin C (e.g., orange juice)',
            ),
            const SizedBox(height: 14),
            _RiskCard(
              title: 'Preeclampsia Risk',
              level: 'Low',
              levelColor: TColors.green500,
              gradient: TColors.gradGreen,
              icon: '💚',
              description: 'BP trend: 118/75 (stable). No protein in urine. No facial edema detected in last selfie scan.',
              bars: [('Blood Pressure', 0.25), ('Urine Protein', 0.05), ('Edema Score', 0.10)],
              action: 'Continue regular ANC visits. Next BP check: April 23.',
            ),
            const SizedBox(height: 14),
            _RiskCard(
              title: 'PCOS Indicators',
              level: 'Low',
              levelColor: TColors.green500,
              gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF009999)]),
              icon: '🌿',
              description: 'Cycle regularity: 27–28 days (consistent). No androgen-linked symptoms logged.',
              bars: [('Cycle Regularity', 0.85), ('Symptom Load', 0.15), ('Metabolic Risk', 0.20)],
              action: 'No action needed. Keep tracking monthly cycles.',
            ),
            const SizedBox(height: 20),
            // Trend chart (visual)
            _TrendChart(),
            const SizedBox(height: 80),
          ]),
        )),
      ]),
    );
  }
}

class _OverallScore extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF004D4D), Color(0xFF1565C0)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Overall Health Score', style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 4),
        const Text('82 / 100', style: TextStyle(color: TColors.white,
            fontSize: 36, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('Good — 3 active insights to review',
          style: TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 0.82, minHeight: 8,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation(Color(0xFF81C784)),
          ),
        ),
      ])),
      const SizedBox(width: 20),
      Container(width: 80, height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
          border: Border.all(color: Colors.white30, width: 2),
        ),
        child: const Center(child: Text('😊', style: TextStyle(fontSize: 36)))),
    ]),
  );
}

class _RiskCard extends StatefulWidget {
  final String title, level, description, action, icon;
  final Color levelColor;
  final LinearGradient gradient;
  final List<(String, double)> bars;
  const _RiskCard({required this.title, required this.level, required this.levelColor,
    required this.gradient, required this.icon, required this.description,
    required this.bars, required this.action});
  @override
  State<_RiskCard> createState() => _RiskCardState();
}

class _RiskCardState extends State<_RiskCard> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => setState(() => _expanded = !_expanded),
    child: Container(
      decoration: BoxDecoration(
        color: TColors.white, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: TColors.teal700.withOpacity(0.07),
            blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(18).copyWith(
              bottomLeft: _expanded ? Radius.zero : null,
              bottomRight: _expanded ? Radius.zero : null),
          ),
          child: Row(children: [
            Text(widget.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.title, style: const TextStyle(color: TColors.white,
                  fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: widget.levelColor.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: widget.levelColor.withOpacity(0.6)),
                  ),
                  child: Text(widget.level, style: TextStyle(
                      color: widget.levelColor, fontSize: 11, fontWeight: FontWeight.w700))),
              ]),
            ])),
            Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: TColors.white),
          ]),
        ),
        if (_expanded) Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.description, style: const TextStyle(
                color: TColors.mid, fontSize: 13, height: 1.5)),
            const SizedBox(height: 14),
            ...widget.bars.map((b) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(b.$1,
                    style: const TextStyle(fontSize: 12, color: TColors.mid, fontWeight: FontWeight.w500))),
                  Text('${(b.$2 * 100).round()}%',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: TColors.teal700)),
                ]),
                const SizedBox(height: 4),
                ClipRRect(borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(value: b.$2, minHeight: 8,
                    backgroundColor: TColors.teal50,
                    valueColor: AlwaysStoppedAnimation(widget.gradient.colors.last))),
              ]),
            )),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: TColors.teal50,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                const Text('💡', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(child: Text(widget.action,
                  style: const TextStyle(fontSize: 12, color: TColors.teal700, height: 1.4))),
              ]),
            ),
          ]),
        ),
      ]),
    ),
  );
}

class _TrendChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = [10.8, 11.0, 11.2, 11.0, 11.2, 11.3, 11.2];
    final labels = ['Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar', 'Apr'];
    final maxVal = 12.0;
    final minVal = 10.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TColors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: TColors.blue700.withOpacity(0.07),
            blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Hemoglobin Trend (g/dL)',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: TColors.dark)),
        const SizedBox(height: 4),
        const Text('Last 7 months · Altitude-adjusted reference: 11.0 g/dL',
          style: TextStyle(fontSize: 11, color: TColors.gray)),
        const SizedBox(height: 20),
        SizedBox(
          height: 140,
          child: CustomPaint(
            painter: _LineChartPainter(data: data, maxVal: maxVal, minVal: minVal),
            size: Size.infinite,
          ),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: labels.map((l) => Text(l, style: const TextStyle(
              fontSize: 10, color: TColors.gray))).toList()),
        const SizedBox(height: 12),
        Row(children: [
          Container(width: 12, height: 3, decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [TColors.blue700, TColors.teal500]),
            borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 6),
          const Text('Your Hb', style: TextStyle(fontSize: 11, color: TColors.mid)),
          const SizedBox(width: 16),
          Container(width: 12, height: 2, color: TColors.red400.withOpacity(0.5)),
          const SizedBox(width: 6),
          const Text('Min threshold (alt. adjusted)', style: TextStyle(fontSize: 11, color: TColors.mid)),
        ]),
      ]),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final double maxVal, minVal;
  const _LineChartPainter({required this.data, required this.maxVal, required this.minVal});

  @override
  void paint(Canvas canvas, Size size) {
    final range = maxVal - minVal;
    final pts = List.generate(data.length, (i) => Offset(
      i * size.width / (data.length - 1),
      size.height - (data[i] - minVal) / range * size.height,
    ));

    // Gradient fill
    final fillPath = Path()..moveTo(pts.first.dx, size.height);
    for (final p in pts) fillPath.lineTo(p.dx, p.dy);
    fillPath..lineTo(pts.last.dx, size.height)..close();
    canvas.drawPath(fillPath, Paint()
      ..shader = LinearGradient(
        colors: [TColors.blue500.withOpacity(0.3), TColors.teal300.withOpacity(0.05)],
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));

    // Line
    final linePaint = Paint()
      ..shader = const LinearGradient(colors: [TColors.blue700, TColors.teal500])
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 2.5 ..style = PaintingStyle.stroke ..strokeCap = StrokeCap.round;
    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final cp1 = Offset((pts[i-1].dx + pts[i].dx) / 2, pts[i-1].dy);
      final cp2 = Offset((pts[i-1].dx + pts[i].dx) / 2, pts[i].dy);
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Threshold line
    final threshY = size.height - (11.0 - minVal) / range * size.height;
    canvas.drawLine(Offset(0, threshY), Offset(size.width, threshY),
      Paint()..color = TColors.red400.withOpacity(0.5)..strokeWidth = 1.5
        ..style = PaintingStyle.stroke);

    // Dots
    for (final p in pts) {
      canvas.drawCircle(p, 5, Paint()..color = TColors.white);
      canvas.drawCircle(p, 4, Paint()..color = TColors.blue500);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── EDUCATION SCREEN ────────────────────────────────────────────
class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  final _modules = const [
    _Module('Understanding Your Cycle', '8 min', '🌸', TColors.gradPink, 'Reproductive Health', true),
    _Module('Danger Signs in Pregnancy', '6 min', '⚠️', TColors.gradTeal, 'Pregnancy Safety', false),
    _Module('Nutrition for Ethiopian Mothers', '10 min', '🥗', TColors.gradGreen, 'Nutrition', false),
    _Module('What is Anemia? (ደም ማነስ)', '7 min', '🩸', TColors.gradBlue, 'Lab Literacy', true),
    _Module('Understanding Your Lab Results', '12 min', '🧪', TColors.gradBlue, 'Lab Literacy', false),
    _Module('Preeclampsia — Early Signs', '9 min', '💊', TColors.gradTeal, 'Pregnancy Safety', false),
    _Module('Partner Support Guide', '5 min', '👨‍👩‍👧', TColors.gradPink, 'Family', true),
    _Module('Postpartum Recovery', '11 min', '🍼', TColors.gradGreen, 'Postpartum', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.cream,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true, expandedHeight: 130,
          backgroundColor: TColors.green700,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: TColors.gradGreen),
              child: const SafeArea(child: Padding(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Health Education', style: TextStyle(
                      color: TColors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                  Text('Amharic + English · Audio available · Clinician-validated',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                  SizedBox(height: 12),
                  Row(children: [
                    _Pill('All'), SizedBox(width: 8),
                    _Pill('Pregnancy'), SizedBox(width: 8),
                    _Pill('Cycle'), SizedBox(width: 8),
                    _Pill('Nutrition'),
                  ]),
                ]),
              )),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(delegate: SliverChildBuilderDelegate(
            (ctx, i) {
              if (i >= _modules.length) return const SizedBox(height: 80);
              final m = _modules[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ModuleCard(module: m),
              );
            },
            childCount: _modules.length + 1,
          )),
        ),
      ]),
    );
  }
}

class _Module {
  final String title, duration, emoji, category;
  final LinearGradient gradient;
  final bool completed;
  const _Module(this.title, this.duration, this.emoji, this.gradient, this.category, this.completed);
}

class _Pill extends StatelessWidget {
  final String label;
  const _Pill(this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
      color: TColors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: TColors.white.withOpacity(0.4)),
    ),
    child: Text(label, style: const TextStyle(color: TColors.white, fontSize: 12)),
  );
}

class _ModuleCard extends StatelessWidget {
  final _Module module;
  const _ModuleCard({super.key, required this.module});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: TColors.white, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: TColors.teal700.withOpacity(0.06),
          blurRadius: 12, offset: const Offset(0, 3))],
    ),
    child: Row(children: [
      Container(
        width: 72, height: 80,
        decoration: BoxDecoration(
          gradient: module.gradient,
          borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
        ),
        child: Center(child: Text(module.emoji, style: const TextStyle(fontSize: 28))),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: TColors.teal50, borderRadius: BorderRadius.circular(8)),
            child: Text(module.category, style: const TextStyle(fontSize: 10, color: TColors.teal700))),
          if (module.completed) ...[
            const SizedBox(width: 6),
            const Text('✓ Done', style: TextStyle(fontSize: 10, color: TColors.green700,
                fontWeight: FontWeight.w600)),
          ],
        ]),
        const SizedBox(height: 4),
        Text(module.title, style: const TextStyle(fontSize: 14,
            fontWeight: FontWeight.w600, color: TColors.dark)),
        const SizedBox(height: 2),
        Text('🎧 ${module.duration}', style: const TextStyle(fontSize: 12, color: TColors.gray)),
      ])),
      const Padding(
        padding: EdgeInsets.only(right: 16),
        child: Icon(Icons.play_circle_filled_rounded, color: TColors.teal500, size: 32)),
    ]),
  );
}

// ─── PROFILE SCREEN ──────────────────────────────────────────────
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.cream,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 200, pinned: true,
          backgroundColor: TColors.pink700,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: TColors.gradPink),
              child: SafeArea(child: Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: TColors.gradTeal,
                      border: Border.all(color: TColors.white, width: 3),
                    ),
                    child: const Center(child: Text('S',
                      style: TextStyle(color: TColors.white,
                          fontSize: 34, fontWeight: FontWeight.w700)))),
                  const SizedBox(height: 10),
                  const Text('Selam Tadesse', style: TextStyle(
                      color: TColors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                  const Text('Pregnancy · Week 17 · 29 years old',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ))),
            ),
          ),
        ),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            // Health profile
            _Section('Health Profile', [
              _InfoRow('Life Stage', 'Pregnancy — Week 17', '🤰'),
              _InfoRow('Due Date', 'September 8, 2026', '📅'),
              _InfoRow('Blood Type', 'O+', '🩸'),
              _InfoRow('Altitude', 'Addis Ababa · 2,300m', '⛰️'),
              _InfoRow('Language', 'Amharic + English', '🇪🇹'),
              _InfoRow('Hospital', 'St. Paul\'s · Dr. Abebe', '🏥'),
            ]),
            const SizedBox(height: 16),
            // Partner
            _Section('Partner Info', [
              _InfoRow('Partner', 'Abebe Tadesse', '👨'),
              _InfoRow('Phone', '+251 91X XXX XXXX', '📱'),
              _InfoRow('SMS Alerts', 'Enabled ✓', '✉️'),
              _InfoRow('ANC Attendance', '2 of 4 visits', '🏥'),
            ]),
            const SizedBox(height: 16),
            // Settings tiles
            _Section('Settings', [
              _SettingRow('Notification Reminders', Icons.notifications_rounded, true),
              _SettingRow('Wearable Connected', Icons.watch_rounded, true),
              _SettingRow('Audio Modules (Amharic)', Icons.volume_up_rounded, true),
              _SettingRow('Share Data with Doctor', Icons.share_rounded, false),
              _SettingRow('Dark Mode', Icons.dark_mode_rounded, false),
            ]),
            const SizedBox(height: 16),
            // Emergency SOS
            Container(
              width: double.infinity, height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFC0392B), Color(0xFFE74C3C)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('🚨', style: TextStyle(fontSize: 20)),
                SizedBox(width: 10),
                Text('Emergency SOS — Call 907',
                  style: TextStyle(color: TColors.white,
                      fontWeight: FontWeight.w700, fontSize: 16)),
              ])),
            ),
            const SizedBox(height: 80),
          ]),
        )),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section(this.title, this.children);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 13, color: TColors.gray,
          fontWeight: FontWeight.w600, letterSpacing: 0.5)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(color: TColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: TColors.teal700.withOpacity(0.06),
                blurRadius: 12, offset: const Offset(0, 3))]),
        child: Column(children: children),
      ),
    ],
  );
}

class _InfoRow extends StatelessWidget {
  final String label, value, emoji;
  const _InfoRow(this.label, this.value, this.emoji);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: TColors.border.withOpacity(0.5)))),
    child: Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 18)),
      const SizedBox(width: 12),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: TColors.gray))),
      Text(value, style: const TextStyle(fontSize: 13,
          fontWeight: FontWeight.w600, color: TColors.dark)),
    ]),
  );
}

class _SettingRow extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool initial;
  const _SettingRow(this.label, this.icon, this.initial);
  @override
  State<_SettingRow> createState() => _SettingRowState();
}

class _SettingRowState extends State<_SettingRow> {
  late bool _val;
  @override
  void initState() { super.initState(); _val = widget.initial; }
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: TColors.border.withOpacity(0.5)))),
    child: Row(children: [
      Container(width: 34, height: 34,
        decoration: BoxDecoration(
          gradient: TColors.gradTeal, borderRadius: BorderRadius.circular(9)),
        child: Icon(widget.icon, color: TColors.white, size: 18)),
      const SizedBox(width: 12),
      Expanded(child: Text(widget.label,
        style: const TextStyle(fontSize: 13, color: TColors.dark, fontWeight: FontWeight.w500))),
      Switch(
        value: _val,
        onChanged: (v) => setState(() => _val = v),
        activeColor: TColors.teal500,
        activeTrackColor: TColors.teal100,
      ),
    ]),
  );
}
