import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/providers/language_provider.dart';
import '../../models/models.dart';
import '../../widgets/common/gradient_button.dart';

// ─── AI RISK SCREEN ──────────────────────────────────────────────
class AiRiskScreen extends StatefulWidget {
  final LabResult result;
  final List<String> flags;
  final String recommendation;

  const AiRiskScreen({
    super.key,
    required this.result,
    required this.flags,
    required this.recommendation,
  });

  @override
  State<AiRiskScreen> createState() => _AiRiskScreenState();
}

class _AiRiskScreenState extends State<AiRiskScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Color get _riskColor => widget.result.riskColor;
  LinearGradient get _gradient => widget.result.riskLevel == 'red'
      ? TGradients.gradEmergency
      : widget.result.riskLevel == 'yellow'
          ? const LinearGradient(colors: [Color(0xFFF9A825), Color(0xFFFFD54F)])
          : TGradients.gradGreen;

  IconData get _riskIcon => widget.result.riskLevel == 'red'
      ? Icons.warning_rounded
      : widget.result.riskLevel == 'yellow'
          ? Icons.info_rounded
          : Icons.check_circle_rounded;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final riskLabel = widget.result.riskLevel == 'red'
        ? lang.riskHigh
        : widget.result.riskLevel == 'yellow'
            ? lang.riskModerate
            : lang.riskLow;

    return Scaffold(
      backgroundColor: TColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            // Risk hero
            Container(
              width: double.infinity,
              decoration: BoxDecoration(gradient: _gradient),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
              child: Column(children: [
                FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: TColors.white.withOpacity(0.2),
                        border: Border.all(
                            color: TColors.white.withOpacity(0.5),
                            width: 3),
                      ),
                      child: Icon(_riskIcon,
                          color: TColors.white, size: 52),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(lang.aiRiskAssessment,
                    style: TextStyle(
                        color: TColors.white.withOpacity(0.8),
                        fontSize: 12, letterSpacing: 1.5)),
                const SizedBox(height: 6),
                Text(riskLabel,
                    style: const TextStyle(
                        color: TColors.white, fontSize: 28,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: TColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.result.date.day}/${widget.result.date.month}/${widget.result.date.year}',
                    style: const TextStyle(
                        color: TColors.white, fontWeight: FontWeight.w600)),
                ),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AI Findings
                  if (widget.flags.isNotEmpty) ...[
                    Text(lang.s('AI Findings', 'AI ግኝቶች'),
                        style: TTextStyles.headlineMedium),
                    const SizedBox(height: 12),
                    ...widget.flags.map((f) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _riskColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _riskColor.withOpacity(0.2)),
                      ),
                      child: Row(children: [
                        Icon(_riskIcon, color: _riskColor, size: 18),
                        const SizedBox(width: 10),
                        Expanded(child: Text(f,
                            style: TTextStyles.bodyMedium
                                .copyWith(color: TColors.dark))),
                      ]),
                    )),
                    const SizedBox(height: 20),
                  ],

                  // Recommendation
                  Text(lang.s('Recommendation', 'ምክረ ሀሳብ'),
                      style: TTextStyles.headlineMedium),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: TColors.border),
                    ),
                    child: Text(widget.recommendation,
                        style: TTextStyles.bodyLarge.copyWith(height: 1.6)),
                  ),
                  const SizedBox(height: 24),

                  // Your values
                  Text(lang.s('Your Values', 'ዋጋዎችዎ'),
                      style: TTextStyles.headlineMedium),
                  const SizedBox(height: 12),
                  _ValuesGrid(result: widget.result, lang: lang),
                  const SizedBox(height: 32),

                  // Actions
                  GradientButton(
                    label: lang.shareWithDoctor,
                    gradient: _gradient,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const ShareDoctorScreen())),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => Navigator.popUntil(
                        context, (r) => r.isFirst),
                    child: Container(
                      width: double.infinity, height: 52,
                      decoration: BoxDecoration(
                        color: TColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: TColors.border),
                      ),
                      child: Center(child: Text(
                          lang.s('Back to Home', 'ወደ ቤት'),
                          style: TTextStyles.labelLarge)),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _ValuesGrid extends StatelessWidget {
  final LabResult result;
  final LanguageProvider lang;
  const _ValuesGrid({required this.result, required this.lang});

  @override
  Widget build(BuildContext context) {
    final items = [
      if (result.hemoglobin != null)
        (lang.hemoglobin, '${result.hemoglobin} g/dL',
         Icons.bloodtype_rounded, TColors.red400),
      if (result.systolic != null)
        (lang.bloodPressure, result.bloodPressure,
         Icons.monitor_heart_rounded, TColors.pink500),
      if (result.bloodSugar != null)
        (lang.bloodSugar, '${result.bloodSugar} mg/dL',
         Icons.water_drop_rounded, TColors.blue500),
      if (result.weight != null)
        (lang.weight, '${result.weight} kg',
         Icons.scale_rounded, TColors.teal500),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12, crossAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: items.map((item) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: TColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.$4, color: item.$4, size: 18),
            const SizedBox(height: 6),
            Text(item.$2, style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800,
                color: item.$4)),
            Text(item.$1, style: TTextStyles.bodySmall),
          ],
        ),
      )).toList(),
    );
  }
}

// ─── LAB RESULT DETAIL ───────────────────────────────────────────
class LabResultDetailScreen extends StatelessWidget {
  final LabResult result;
  const LabResultDetailScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: TColors.cream,
      appBar: AppBar(
        title: Text(lang.s('Lab Result Detail', 'የላብ ውጤት ዝርዝር')),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: result.riskColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: result.riskColor.withOpacity(0.3)),
            ),
            child: Row(children: [
              Icon(Icons.calendar_today_rounded,
                  color: result.riskColor),
              const SizedBox(width: 12),
              Text(
                '${result.date.day}/${result.date.month}/${result.date.year}',
                style: TTextStyles.headlineMedium),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: result.riskColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(result.riskLevel.toUpperCase(),
                    style: const TextStyle(
                        color: TColors.white,
                        fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          _ValuesGrid(result: result, lang: lang),
          if (result.notes != null && result.notes!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(lang.s('Notes', 'ማስታወሻዎች'),
                style: TTextStyles.headlineMedium),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: TColors.border),
              ),
              child: Text(result.notes!,
                  style: TTextStyles.bodyLarge),
            ),
          ],
        ]),
      ),
    );
  }
}

// ─── SHARE DOCTOR SCREEN ─────────────────────────────────────────
class ShareDoctorScreen extends StatelessWidget {
  const ShareDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    // Generate a mock 6-char code
    final code = 'TS${DateTime.now().millisecond.toString().padLeft(4, '0')}';

    return Scaffold(
      backgroundColor: TColors.cream,
      appBar: AppBar(
        title: Text(lang.shareWithDoctor),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: TGradients.gradTeal,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(children: [
                const Icon(Icons.qr_code_rounded,
                    color: TColors.white, size: 80),
                const SizedBox(height: 20),
                Text(lang.s('Your secure code', 'ደህንነቱ የተጠበቀ ኮድዎ'),
                    style: TextStyle(
                        color: TColors.white.withOpacity(0.8),
                        fontSize: 13)),
                const SizedBox(height: 8),
                Text(code, style: const TextStyle(
                    color: TColors.white, fontSize: 40,
                    fontWeight: FontWeight.w800, letterSpacing: 6)),
                const SizedBox(height: 16),
                Text(lang.s(
                    'Show this code to your doctor or health worker to pull your latest health data.',
                    'ቅርብ የጤና ዳታዎን ለማምጣት ይህን ኮድ ለዶክተርዎ ወይም ለጤና ሰራተኛ ያሳዩ።'),
                    style: TextStyle(
                        color: TColors.white.withOpacity(0.85),
                        fontSize: 13, height: 1.5),
                    textAlign: TextAlign.center),
              ]),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: TColors.border),
              ),
              child: Column(children: [
                const Icon(Icons.timer_outlined,
                    color: TColors.teal500, size: 32),
                const SizedBox(height: 12),
                Text(lang.s(
                    'Code valid for 24 hours',
                    'ኮዱ ለ24 ሰዓት ይሰራል'),
                    style: TTextStyles.labelLarge),
                const SizedBox(height: 4),
                Text(lang.s(
                    'Only your connected healthcare provider can access your data.',
                    'የተገናኘው ጤና ሰጭዎ ብቻ ዳታዎን ማግኘት ይችላል።'),
                    style: TTextStyles.bodyMedium,
                    textAlign: TextAlign.center),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
