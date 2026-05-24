import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/partner_provider.dart';
import 'partner_home_screen.dart';

// ── PARTNER WELCOME ─────────────────────────────────────────────
class PartnerWelcomeScreen extends StatefulWidget {
  const PartnerWelcomeScreen({super.key});
  @override
  State<PartnerWelcomeScreen> createState() => _PartnerWelcomeScreenState();
}

class _PartnerWelcomeScreenState extends State<PartnerWelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade, _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slide = Tween<double>(begin: 40, end: 0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Stack(children: [
        Positioned(top: -60, right: -40,
            child: _Orb(280, TColors.teal500.withOpacity(0.12))),
        Positioned(bottom: -60, left: -40,
            child: _Orb(240, TColors.blue500.withOpacity(0.10))),
        SafeArea(child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Opacity(
            opacity: _fade.value,
            child: Transform.translate(
              offset: Offset(0, _slide.value),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    // Partner badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: TColors.teal500.withOpacity(0.12),
                        border: Border.all(
                            color: TColors.teal500.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.favorite_rounded,
                            color: TColors.teal400, size: 14),
                        const SizedBox(width: 6),
                        Text(lang.s('Partner Mode', 'የሸሪካ ሁነታ'),
                            style: const TextStyle(
                                fontSize: 12, color: TColors.teal300,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5)),
                      ]),
                    ),
                    const SizedBox(height: 28),
                    // Main heading
                    Text(lang.s('Welcome,\nPartner.', 'እንኳን ደህና\nመጡ፣ ሸሪካ።'),
                        style: const TextStyle(
                            fontSize: 48, fontWeight: FontWeight.w800,
                            color: TColors.white, height: 1.1,
                            letterSpacing: -1)),
                    const SizedBox(height: 20),
                    Text(lang.s(
                        'Your partner has invited you to join Tsega. '
                        'You will see her health journey, get alerts for danger signs, '
                        'and learn how to support her every week.',
                        'ሸሪካዎ ጸጋ ለመቀላቀል ጋብዘዎታል። '
                        'የጤና ጉዞዋን ያያሉ፣ '
                        'ለአደጋ ምልክቶች ማስጠንቀቂያ ያገኛሉ።'),
                        style: TextStyle(fontSize: 16, height: 1.7,
                            color: TColors.white.withOpacity(0.55))),
                    const SizedBox(height: 48),
                    // Feature highlights
                    ...[
                      (Icons.visibility_rounded,
                       lang.s('See her health journey', 'የጤና ጉዞዋን ይከታተሉ'),
                       TColors.teal500),
                      (Icons.warning_amber_rounded,
                       lang.s('Instant danger sign alerts', 'ወዲያውኑ የአደጋ ምልክት ማስጠንቀቂያ'),
                       TColors.pink500),
                      (Icons.menu_book_rounded,
                       lang.s('Weekly partner education', 'ሳምንታዊ የሸሪካ ትምህርት'),
                       TColors.blue500),
                      (Icons.chat_bubble_rounded,
                       lang.s('Private messaging with her', 'ከእሷ ጋር የግል ተደጋጋፊ'),
                       const Color(0xFF7C4DFF)),
                    ].map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: item.$3.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10)),
                          child: Icon(item.$1, color: item.$3, size: 18)),
                        const SizedBox(width: 14),
                        Text(item.$2,
                            style: const TextStyle(
                                fontSize: 15, color: TColors.white,
                                fontWeight: FontWeight.w500)),
                      ]),
                    )).toList(),
                    const Spacer(),
                    // CTA
                    GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const PartnerCodeEntryScreen())),
                      child: Container(
                        width: double.infinity, height: 56,
                        decoration: BoxDecoration(
                          gradient: TGradients.gradTeal,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(
                            color: TColors.teal500.withOpacity(0.3),
                            blurRadius: 20, offset: const Offset(0, 8))]),
                        child: Center(child: Text(
                          lang.s('Enter Invitation Code →',
                              'የጋብዣ ኮድ ያስገቡ →'),
                          style: const TextStyle(
                              color: TColors.white, fontSize: 16,
                              fontWeight: FontWeight.w700)))),
                    ),
                    const SizedBox(height: 16),
                    Center(child: Text(
                      lang.s('Already have the app? This is the right place.',
                          'መተግበሪያው አለዎት? ትክክለኛው ቦታ ነው።'),
                      style: TextStyle(fontSize: 12,
                          color: TColors.white.withOpacity(0.3)),
                      textAlign: TextAlign.center)),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        )),
      ]),
    );
  }
}

// ── CODE ENTRY SCREEN ────────────────────────────────────────────
class PartnerCodeEntryScreen extends StatefulWidget {
  const PartnerCodeEntryScreen({super.key});
  @override
  State<PartnerCodeEntryScreen> createState() =>
      _PartnerCodeEntryScreenState();
}

class _PartnerCodeEntryScreenState extends State<PartnerCodeEntryScreen> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  bool _error   = false;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    final code = _ctrl.text.trim().toUpperCase();
    if (code.length < 6) {
      setState(() => _error = true);
      return;
    }
    setState(() { _loading = true; _error = false; });
    final partner = context.read<PartnerProvider>();
    final ok = await partner.validateAndLink(code);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const PartnerLinkSuccessScreen()),
        (_) => false);
    } else {
      setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Stack(children: [
        Positioned(top: -60, right: -40,
            child: _Orb(280, TColors.teal500.withOpacity(0.10))),
        SafeArea(child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: _GlassBtn(icon: Icons.arrow_back_ios_rounded)),
              const SizedBox(height: 40),
              // Icon
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  gradient: TGradients.gradTeal,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(
                    color: TColors.teal500.withOpacity(0.3),
                    blurRadius: 20)]),
                child: const Icon(Icons.qr_code_rounded,
                    color: TColors.white, size: 32)),
              const SizedBox(height: 28),
              Text(lang.s('Enter your\ninvitation code',
                  'የጋብዣ ኮድ\nያስገቡ'),
                  style: const TextStyle(
                      fontSize: 36, fontWeight: FontWeight.w800,
                      color: TColors.white, height: 1.1,
                      letterSpacing: -0.5)),
              const SizedBox(height: 12),
              Text(lang.s(
                  'Your partner sent you a 6-character code from the Tsega app.',
                  'ሸሪካዎ ከጸጋ መተግበሪያ 6-ቁምፊ ኮድ ልኮልዎታል።'),
                  style: TextStyle(fontSize: 15,
                      color: TColors.white.withOpacity(0.5), height: 1.5)),
              const SizedBox(height: 40),
              // Code input
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: TColors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _error
                          ? TColors.red400.withOpacity(0.5)
                          : TColors.teal500.withOpacity(0.3))),
                    child: TextField(
                      controller: _ctrl,
                      textAlign: TextAlign.center,
                      textCapitalization: TextCapitalization.characters,
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.w800,
                          color: TColors.white, letterSpacing: 8),
                      onChanged: (v) {
                        if (v.length == 2 && !v.contains('-')) {
                          _ctrl.text = '$v-';
                          _ctrl.selection = TextSelection.fromPosition(
                              TextPosition(offset: _ctrl.text.length));
                        }
                        setState(() => _error = false);
                      },
                      onSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        hintText: 'TG-0000',
                        hintStyle: TextStyle(
                            fontSize: 28, letterSpacing: 8,
                            color: TColors.white.withOpacity(0.15),
                            fontWeight: FontWeight.w800),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 20)),
                    ),
                  ),
                ),
              ),
              if (_error) ...[
                const SizedBox(height: 10),
                Text(lang.s(
                    'Invalid code. Check with your partner and try again.',
                    'የተሳሳተ ኮድ። ከሸሪካዎ ጋር ያረጋግጡ እና እንደገና ይሞክሩ።'),
                    style: const TextStyle(
                        fontSize: 13, color: TColors.red400)),
              ],
              const Spacer(),
              // Submit
              GestureDetector(
                onTap: _loading ? null : _submit,
                child: Container(
                  width: double.infinity, height: 56,
                  decoration: BoxDecoration(
                    gradient: TGradients.gradTeal,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(
                      color: TColors.teal500.withOpacity(0.3),
                      blurRadius: 20, offset: const Offset(0, 8))]),
                  child: Center(child: _loading
                      ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(
                              color: TColors.white, strokeWidth: 2))
                      : Text(lang.s('Connect', 'ያገናኙ'),
                          style: const TextStyle(
                              color: TColors.white, fontSize: 16,
                              fontWeight: FontWeight.w700)))),
              ),
              const SizedBox(height: 24),
            ],
          ),
        )),
      ]),
    );
  }
}

// ── LINK SUCCESS SCREEN ──────────────────────────────────────────
class PartnerLinkSuccessScreen extends StatefulWidget {
  const PartnerLinkSuccessScreen({super.key});
  @override
  State<PartnerLinkSuccessScreen> createState() =>
      _PartnerLinkSuccessScreenState();
}

class _PartnerLinkSuccessScreenState extends State<PartnerLinkSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _scale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final lang    = context.watch<LanguageProvider>();
    final partner = context.watch<PartnerProvider>();
    final name    = partner.healthView?.womanName ?? 'her';

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Stack(children: [
        Positioned(top: -60, right: -40,
            child: _Orb(300, TColors.teal500.withOpacity(0.15))),
        SafeArea(child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      gradient: TGradients.gradTeal,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                        color: TColors.teal500.withOpacity(0.4),
                        blurRadius: 40, spreadRadius: 8)]),
                    child: const Icon(Icons.favorite_rounded,
                        color: TColors.white, size: 56)),
                ),
              ),
              const SizedBox(height: 32),
              FadeTransition(
                opacity: _fade,
                child: Column(children: [
                  Text(lang.s('You\'re connected!', 'ተሳስረዋል!'),
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.w800,
                          color: TColors.white)),
                  const SizedBox(height: 12),
                  Text(lang.s(
                      'You are now supporting $name on her health journey.\n'
                      'She has been notified that you joined.',
                      'አሁን $nameን በጤና ጉዞዋ ላይ እያገዙ ነዎት።\n'
                      'እርስዎ እንደተቀላቀሉ ተነግሯታል።'),
                      style: TextStyle(fontSize: 16, height: 1.6,
                          color: TColors.white.withOpacity(0.6)),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  // What's next chips
                  ...[
                    lang.s('See her Week ${partner.healthView?.pregnancyWeek ?? ''} status',
                        'የሳምንት ${partner.healthView?.pregnancyWeek ?? ''} ሁኔታዋን ይዩ'),
                    lang.s('Learn danger signs', 'የአደጋ ምልክቶችን ይወቁ'),
                    lang.s('Send her a message', 'ደብዳቤ ይላኩ'),
                  ].map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: TColors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: TColors.teal500.withOpacity(0.2))),
                      child: Row(children: [
                        const Icon(Icons.check_circle_rounded,
                            color: TColors.teal400, size: 16),
                        const SizedBox(width: 10),
                        Text(t, style: const TextStyle(
                            fontSize: 14, color: TColors.white)),
                      ]),
                    ),
                  )).toList(),
                ]),
              ),
              const Spacer(),
              FadeTransition(
                opacity: _fade,
                child: GestureDetector(
                  onTap: () => Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(
                          builder: (_) => const PartnerHomeScreen()),
                      (_) => false),
                  child: Container(
                    width: double.infinity, height: 56,
                    decoration: BoxDecoration(
                      gradient: TGradients.gradTeal,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(
                        color: TColors.teal500.withOpacity(0.3),
                        blurRadius: 20, offset: const Offset(0, 8))]),
                    child: Center(child: Text(
                      lang.s('Enter Partner Mode →', 'የሸሪካ ሁነታ ይጀምሩ →'),
                      style: const TextStyle(
                          color: TColors.white, fontSize: 16,
                          fontWeight: FontWeight.w700)))),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        )),
      ]),
    );
  }
}

// ── SHARED WIDGETS ───────────────────────────────────────────────
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

class _GlassBtn extends StatelessWidget {
  final IconData icon;
  const _GlassBtn({required this.icon});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: TColors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: TColors.white.withOpacity(0.12))),
        child: Icon(icon, color: TColors.white, size: 18))));
}
