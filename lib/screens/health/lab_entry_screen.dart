import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/providers/language_provider.dart';
import '../../models/models.dart';
import '../../services/storage_service.dart';
import '../../services/api_service.dart';
import '../../widgets/common/gradient_button.dart';
import 'ai_risk_screen.dart';

class LabEntryScreen extends StatefulWidget {
  const LabEntryScreen({super.key});
  @override
  State<LabEntryScreen> createState() => _LabEntryScreenState();
}

class _LabEntryScreenState extends State<LabEntryScreen> {
  final _hbCtrl = TextEditingController();
  final _sysCtrl = TextEditingController();
  final _diaCtrl = TextEditingController();
  final _bsCtrl = TextEditingController();
  final _wtCtrl = TextEditingController();
  final _upCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_hbCtrl, _sysCtrl, _diaCtrl, _bsCtrl, _wtCtrl,
                     _upCtrl, _notesCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _analyze() async {
    if (_hbCtrl.text.isEmpty && _sysCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<LanguageProvider>()
            .s('Enter at least one value', 'ቢያንስ አንድ ዋጋ ያስገቡ'))));
      return;
    }
    setState(() => _saving = true);

    final data = {
      if (_hbCtrl.text.isNotEmpty)
        'hemoglobin': double.tryParse(_hbCtrl.text),
      if (_sysCtrl.text.isNotEmpty)
        'systolic': double.tryParse(_sysCtrl.text),
      if (_diaCtrl.text.isNotEmpty)
        'diastolic': double.tryParse(_diaCtrl.text),
      if (_bsCtrl.text.isNotEmpty)
        'bloodSugar': double.tryParse(_bsCtrl.text),
      if (_wtCtrl.text.isNotEmpty)
        'weight': double.tryParse(_wtCtrl.text),
      if (_upCtrl.text.isNotEmpty)
        'urineProtein': double.tryParse(_upCtrl.text),
    };

    final assessment = await ApiService.analyzeLabResult(data);
    final riskLevel = assessment?['riskLevel'] ?? 'green';
    final flags = List<String>.from(assessment?['flags'] ?? []);
    final recommendation = assessment?['recommendation'] ?? '';

    final result = LabResult(
      date: DateTime.now(),
      hemoglobin: double.tryParse(_hbCtrl.text),
      systolic: double.tryParse(_sysCtrl.text),
      diastolic: double.tryParse(_diaCtrl.text),
      bloodSugar: double.tryParse(_bsCtrl.text),
      weight: double.tryParse(_wtCtrl.text),
      urineProtein: double.tryParse(_upCtrl.text),
      notes: _notesCtrl.text,
      riskLevel: riskLevel,
    );

    await StorageService.addLabResult(result);
    if (!mounted) return;
    setState(() => _saving = false);

    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => AiRiskScreen(
          result: result,
          flags: flags,
          recommendation: recommendation,
        )));
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: TColors.cream,
      body: SafeArea(
        child: Column(children: [
          // Header
          Container(
            decoration: const BoxDecoration(gradient: TGradients.gradBlue),
            padding: const EdgeInsets.fromLTRB(16, 16, 24, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Row(children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: TColors.white)),
                Text(lang.addResult,
                    style: const TextStyle(
                        color: TColors.white, fontSize: 20,
                        fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  lang.s(
                    'Enter your lab values for AI analysis',
                    'ለ AI ትንተና የላብ ዋጋዎችዎን ያስገቡ'),
                  style: TextStyle(
                      color: TColors.white.withOpacity(0.85),
                      fontSize: 13)),
              ),
            ]),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _LabSection(
                  icon: Icons.bloodtype_rounded,
                  iconColor: TColors.red400,
                  title: lang.hemoglobin,
                  subtitle: lang.s('Normal: 12–16 g/dL',
                      'መደበኛ: 12-16 g/dL'),
                  controller: _hbCtrl,
                  unit: 'g/dL',
                  hint: '12.5',
                ),
                const SizedBox(height: 16),
                _LabSection(
                  icon: Icons.monitor_heart_rounded,
                  iconColor: TColors.pink500,
                  title: lang.bloodPressure,
                  subtitle: lang.s('Normal: <120/<80 mmHg',
                      'መደበኛ: <120/<80 mmHg'),
                  controller: _sysCtrl,
                  unit: 'mmHg',
                  hint: '120',
                  secondController: _diaCtrl,
                  secondHint: '80',
                  secondUnit: 'diastolic',
                ),
                const SizedBox(height: 16),
                _LabSection(
                  icon: Icons.water_drop_rounded,
                  iconColor: TColors.blue500,
                  title: lang.bloodSugar,
                  subtitle: lang.s('Fasting: 70–100 mg/dL',
                      'ጾም: 70-100 mg/dL'),
                  controller: _bsCtrl,
                  unit: 'mg/dL',
                  hint: '85',
                ),
                const SizedBox(height: 16),
                _LabSection(
                  icon: Icons.scale_rounded,
                  iconColor: TColors.teal500,
                  title: lang.weight,
                  subtitle: lang.s('In kilograms', 'ኪሎ ግራም'),
                  controller: _wtCtrl,
                  unit: 'kg',
                  hint: '60',
                ),
                const SizedBox(height: 16),
                _LabSection(
                  icon: Icons.science_rounded,
                  iconColor: TColors.green500,
                  title: lang.urineProtein,
                  subtitle: lang.s('Normal: 0–0.15 g/dL',
                      'መደበኛ: 0-0.15 g/dL'),
                  controller: _upCtrl,
                  unit: 'g/dL',
                  hint: '0.05',
                ),
                const SizedBox(height: 16),
                // Notes
                TextField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: lang.s('Additional notes', 'ተጨማሪ ማስታወሻዎች'),
                    prefixIcon: const Icon(Icons.notes_rounded,
                        color: TColors.gray),
                  ),
                ),
                const SizedBox(height: 32),
                GradientButton(
                  label: lang.s('Analyze with AI', 'ከ AI ጋር ይተንትኑ'),
                  gradient: TGradients.gradBlue,
                  loading: _saving,
                  onTap: _analyze,
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _LabSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle, unit, hint;
  final TextEditingController controller;
  final TextEditingController? secondController;
  final String? secondHint, secondUnit;

  const _LabSection({
    required this.icon, required this.iconColor,
    required this.title, required this.subtitle,
    required this.controller, required this.unit, required this.hint,
    this.secondController, this.secondHint, this.secondUnit,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: TColors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: TColors.border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TTextStyles.labelLarge),
            Text(subtitle, style: TTextStyles.bodySmall),
          ],
        )),
      ]),
      const SizedBox(height: 14),
      if (secondController == null)
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: hint,
            suffixText: unit,
            isDense: true,
          ),
        )
      else
        Row(children: [
          Expanded(child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: hint,
              suffixText: 'sys',
              isDense: true,
            ),
          )),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('/', style: TextStyle(fontSize: 24,
                color: TColors.gray))),
          Expanded(child: TextField(
            controller: secondController!,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: secondHint,
              suffixText: 'dia',
              isDense: true,
            ),
          )),
        ]),
    ]),
  );
}
