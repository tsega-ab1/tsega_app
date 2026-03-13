import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/stage_provider.dart';
import '../../widgets/common/gradient_button.dart';
import '../setup/setup_wizard.dart';

// ─── LANGUAGE SELECTION ──────────────────────────────────────────
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});
  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  AppLanguage _selected = AppLanguage.english;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: TGradients.gradTeal),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.language_rounded,
                    color: TColors.white, size: 64),
                const SizedBox(height: 24),
                const Text('Select Language\nቋንቋ ይምረጡ',
                    style: TextStyle(fontSize: 28,
                        color: TColors.white,
                        fontWeight: FontWeight.w700, height: 1.4),
                    textAlign: TextAlign.center),
                const SizedBox(height: 48),
                _LangOption(
                  label: 'English',
                  sublabel: 'Continue in English',
                  selected: _selected == AppLanguage.english,
                  onTap: () => setState(
                      () => _selected = AppLanguage.english),
                ),
                const SizedBox(height: 16),
                _LangOption(
                  label: 'አማርኛ',
                  sublabel: 'በአማርኛ ይቀጥሉ',
                  selected: _selected == AppLanguage.amharic,
                  onTap: () => setState(
                      () => _selected = AppLanguage.amharic),
                ),
                const SizedBox(height: 48),
                GradientButton(
                  label: _selected == AppLanguage.english
                      ? 'Continue' : 'ቀጥሉ',
                  gradient: const LinearGradient(
                    colors: [TColors.white, Color(0xFFE0F7F7)]),
                  textColor: TColors.teal700,
                  onTap: () {
                    context.read<LanguageProvider>().setLanguage(_selected);
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(
                            builder: (_) => const PhoneAuthScreen()));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  final String label, sublabel;
  final bool selected;
  final VoidCallback onTap;
  const _LangOption({
    required this.label, required this.sublabel,
    required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: selected
            ? TColors.white
            : TColors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: selected
                ? TColors.white
                : TColors.white.withOpacity(0.3),
            width: 2),
      ),
      child: Row(children: [
        Icon(selected
            ? Icons.radio_button_checked_rounded
            : Icons.radio_button_off_rounded,
            color: selected ? TColors.teal700 : TColors.white),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700,
              color: selected ? TColors.teal700 : TColors.white)),
          Text(sublabel, style: TextStyle(
              fontSize: 13,
              color: selected
                  ? TColors.teal500
                  : TColors.white.withOpacity(0.7))),
        ]),
      ]),
    ),
  );
}

// ─── PHONE AUTH ──────────────────────────────────────────────────
class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});
  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() { _phoneCtrl.dispose(); super.dispose(); }

  void _sendOtp() async {
    if (_phoneCtrl.text.length < 9) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.push(context,
        MaterialPageRoute(builder: (_) =>
            OtpScreen(phone: _phoneCtrl.text)));
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: TColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  gradient: TGradients.gradTeal,
                  borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.phone_android_rounded,
                    color: TColors.white, size: 28),
              ),
              const SizedBox(height: 24),
              Text(lang.s('Enter your phone number', 'ስልክ ቁጥርዎን ያስገቡ'),
                  style: TTextStyles.headlineLarge),
              const SizedBox(height: 8),
              Text(lang.s(
                  'We\'ll send a verification code to your phone',
                  'ወደ ስልክዎ የማረጋገጫ ኮድ እናላካለን'),
                  style: TTextStyles.bodyLarge),
              const SizedBox(height: 40),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  prefixText: '+251 ',
                  prefixStyle: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600,
                      color: TColors.teal700),
                  hintText: '9XX XXX XXX',
                  filled: true,
                  fillColor: TColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: TColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                        color: TColors.teal500, width: 2),
                  ),
                ),
              ),
              const Spacer(),
              GradientButton(
                label: lang.s('Send Code', 'ኮድ ይላኩ'),
                gradient: TGradients.gradTeal,
                loading: _loading,
                onTap: _sendOtp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── OTP SCREEN ──────────────────────────────────────────────────
class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpCtrl = TextEditingController();
  bool _loading = false;

  void _verify() async {
    if (_otpCtrl.text.length < 4) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const UserStateScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: TColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: TColors.dark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.s('Verify your number', 'ቁጥርዎን ያረጋግጡ'),
                style: TTextStyles.headlineLarge),
            const SizedBox(height: 8),
            Text('${lang.s('Code sent to', 'ኮድ ተልኳል')} +251 ${widget.phone}',
                style: TTextStyles.bodyLarge),
            const SizedBox(height: 40),
            TextField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(
                  fontSize: 32, fontWeight: FontWeight.w700,
                  letterSpacing: 12),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                counterText: '',
                hintText: '------',
                filled: true,
                fillColor: TColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: TColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                      color: TColors.teal500, width: 2),
                ),
              ),
            ),
            const Spacer(),
            GradientButton(
              label: lang.s('Verify', 'አረጋግጥ'),
              gradient: TGradients.gradTeal,
              loading: _loading,
              onTap: _verify,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── USER STATE SELECTOR ─────────────────────────────────────────
class UserStateScreen extends StatelessWidget {
  const UserStateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: TColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.favorite_rounded,
                  color: TColors.pink500, size: 56),
              const SizedBox(height: 24),
              Text(lang.s('What brings you here?', 'ለምን መጡ?'),
                  style: TTextStyles.headlineLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                lang.s(
                  'Choose your journey — you can always switch later',
                  'ጉዞዎን ይምረጡ — ቆይተው መቀየር ይችላሉ'),
                style: TTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _StateCard(
                icon: Icons.water_drop_rounded,
                titleEn: 'Track my period\n& fertility',
                titleAm: 'ወር አበቤን እና\nፈጠራዬን ለመከታተል',
                subEn: 'Cycle tracking, ovulation, and wellness',
                subAm: 'የወር አበባ ክትትል፣ ፅንሰ-ሀሳብ እና ጤናማነት',
                gradient: TGradients.gradPink,
                onTap: () {
                  context.read<StageProvider>()
                      .setUserState(UserState.period);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(
                          builder: (_) => const SetupWizard()));
                },
              ),
              const SizedBox(height: 16),
              _StateCard(
                icon: Icons.pregnant_woman_rounded,
                titleEn: 'I am pregnant',
                titleAm: 'እኔ ነፍሰ ጡር ነኝ',
                subEn: 'Week-by-week pregnancy companion',
                subAm: 'ሳምንት-በ-ሳምንት የእርግዝና ጓደኛ',
                gradient: TGradients.gradTeal,
                onTap: () {
                  context.read<StageProvider>()
                      .setUserState(UserState.pregnancy);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(
                          builder: (_) => const SetupWizard()));
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  final IconData icon;
  final String titleEn, titleAm, subEn, subAm;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _StateCard({
    required this.icon, required this.titleEn, required this.titleAm,
    required this.subEn, required this.subAm,
    required this.gradient, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: TColors.teal700.withOpacity(0.2),
                blurRadius: 20, offset: const Offset(0, 8))
          ],
        ),
        child: Row(children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: TColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: TColors.white, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lang.isAmharic ? titleAm : titleEn,
                  style: const TextStyle(fontSize: 18,
                      color: TColors.white,
                      fontWeight: FontWeight.w700, height: 1.3)),
              const SizedBox(height: 4),
              Text(lang.isAmharic ? subAm : subEn,
                  style: TextStyle(fontSize: 13,
                      color: TColors.white.withOpacity(0.85))),
            ],
          )),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: TColors.white, size: 20),
        ]),
      ),
    );
  }
}
