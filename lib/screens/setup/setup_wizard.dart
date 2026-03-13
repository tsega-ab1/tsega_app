import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/stage_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../services/storage_service.dart';
import '../../widgets/common/gradient_button.dart';
import '../home/home_screen.dart';

class SetupWizard extends StatefulWidget {
  const SetupWizard({super.key});
  @override
  State<SetupWizard> createState() => _SetupWizardState();
}

class _SetupWizardState extends State<SetupWizard> {
  int _step = 0;
  final _totalSteps = 5;

  // Collected data
  String _name = '';
  DateTime? _dob;
  String _region = 'Addis Ababa';
  String _partnerPhone = '';
  String _emergencyContact = '';
  String _emergencyName = '';
  DateTime? _lmpDate;

  void _next() {
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  void _prev() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _finish() async {
    final user = UserModel(
      name: _name.isEmpty ? 'Friend' : _name,
      dob: _dob,
      region: _region,
      phone: '',
      partnerPhone: _partnerPhone.isEmpty ? null : _partnerPhone,
      emergencyContact: _emergencyContact.isEmpty ? null : _emergencyContact,
      emergencyName: _emergencyName.isEmpty ? null : _emergencyName,
    );
    context.read<UserProvider>().setUser(user);
    if (_lmpDate != null) {
      context.read<StageProvider>().setLmpDate(_lmpDate!);
    }
    await StorageService.saveUser(user);
    await StorageService.setFirstLaunchDone();
    if (!mounted) return;
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final stage = context.watch<StageProvider>();

    return Scaffold(
      backgroundColor: TColors.cream,
      body: SafeArea(
        child: Column(children: [
          // Progress header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _step > 0 ? _prev : null,
                    child: Icon(Icons.arrow_back_rounded,
                        color: _step > 0 ? TColors.dark : Colors.transparent),
                  ),
                  Text('${lang.s('Step', 'ደረጃ')} ${_step + 1} / $_totalSteps',
                      style: TTextStyles.labelMedium),
                  TextButton(
                    onTap: _next,
                    onPressed: _next,
                    child: Text(lang.skip,
                        style: const TextStyle(color: TColors.gray)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_step + 1) / _totalSteps,
                  backgroundColor: TColors.border,
                  color: TColors.teal500,
                  minHeight: 4,
                ),
              ),
            ]),
          ),
          // Step content
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _buildStep(lang, stage),
          )),
          // Bottom button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: GradientButton(
              label: _step == _totalSteps - 1
                  ? lang.getStarted
                  : lang.next,
              gradient: TGradients.gradTeal,
              onTap: _next,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildStep(LanguageProvider lang, StageProvider stage) {
    switch (_step) {
      case 0: return _StepNameLanguage(
          name: _name,
          onNameChanged: (v) => setState(() => _name = v));
      case 1: return _StepAgeRegion(
          dob: _dob, region: _region,
          onDobChanged: (v) => setState(() => _dob = v),
          onRegionChanged: (v) => setState(() => _region = v));
      case 2: return _StepLifeStage();
      case 3: return _StepStageDetail(
          isPregnancy: stage.isPregnancyMode,
          lmpDate: _lmpDate,
          onLmpChanged: (v) => setState(() => _lmpDate = v));
      case 4: return _StepEmergency(
          partnerPhone: _partnerPhone,
          emergencyContact: _emergencyContact,
          emergencyName: _emergencyName,
          onPartnerChanged: (v) => setState(() => _partnerPhone = v),
          onContactChanged: (v) => setState(() => _emergencyContact = v),
          onNameChanged: (v) => setState(() => _emergencyName = v));
      default: return const SizedBox();
    }
  }
}

// ─── STEP 1: NAME ────────────────────────────────────────────────
class _StepNameLanguage extends StatelessWidget {
  final String name;
  final ValueChanged<String> onNameChanged;
  const _StepNameLanguage({required this.name, required this.onNameChanged});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.person_rounded, color: TColors.teal500, size: 48),
      const SizedBox(height: 20),
      Text(lang.s('What\'s your name?', 'ስምዎ ማን ነው?'),
          style: TTextStyles.headlineLarge),
      const SizedBox(height: 8),
      Text(lang.s('We\'ll use this to personalize your experience',
          'ልምዱን ለማሳደድ ይጠቅማል'),
          style: TTextStyles.bodyLarge),
      const SizedBox(height: 32),
      TextField(
        onChanged: onNameChanged,
        decoration: InputDecoration(
          hintText: lang.s('Your full name', 'ሙሉ ስምዎ'),
          filled: true, fillColor: TColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: TColors.border)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: TColors.teal500, width: 2)),
        ),
      ),
    ]);
  }
}

// ─── STEP 2: AGE + REGION ────────────────────────────────────────
class _StepAgeRegion extends StatelessWidget {
  final DateTime? dob;
  final String region;
  final ValueChanged<DateTime?> onDobChanged;
  final ValueChanged<String> onRegionChanged;

  const _StepAgeRegion({
    required this.dob, required this.region,
    required this.onDobChanged, required this.onRegionChanged});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.calendar_today_rounded,
          color: TColors.teal500, size: 48),
      const SizedBox(height: 20),
      Text(lang.s('About you', 'ስለ እርስዎ'),
          style: TTextStyles.headlineLarge),
      const SizedBox(height: 32),
      Text(lang.s('Date of Birth', 'የልደት ቀን'),
          style: TTextStyles.headlineSmall),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime(2000),
            firstDate: DateTime(1950),
            lastDate: DateTime.now(),
          );
          onDobChanged(picked);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: TColors.border),
          ),
          child: Row(children: [
            const Icon(Icons.calendar_today_rounded,
                color: TColors.teal500),
            const SizedBox(width: 12),
            Text(
              dob != null
                  ? '${dob!.day}/${dob!.month}/${dob!.year}'
                  : lang.s('Select date', 'ቀን ይምረጡ'),
              style: TextStyle(
                  color: dob != null ? TColors.dark : TColors.gray,
                  fontSize: 16)),
          ]),
        ),
      ),
      const SizedBox(height: 24),
      Text(lang.s('Your Region', 'ክልልዎ'),
          style: TTextStyles.headlineSmall),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: TColors.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: region,
            isExpanded: true,
            items: AppConstants.regions.map((r) =>
                DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (v) { if (v != null) onRegionChanged(v); },
          ),
        ),
      ),
    ]);
  }
}

// ─── STEP 3: LIFE STAGE ──────────────────────────────────────────
class _StepLifeStage extends StatelessWidget {
  const _StepLifeStage();

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final stage = context.watch<StageProvider>();
    final stages = [
      (LifeStage.adolescence, Icons.eco_rounded,
       lang.s('Adolescence', 'ጉርምስና'), lang.s('Ages 12–18', 'ዕድሜ 12-18'),
       TGradients.gradGreen),
      (LifeStage.reproductive, Icons.spa_rounded,
       lang.s('Reproductive', 'የማዋለድ'), lang.s('Ages 18–35', 'ዕድሜ 18-35'),
       TGradients.gradTeal),
      (LifeStage.pregnancy, Icons.pregnant_woman_rounded,
       lang.s('Pregnancy', 'እርግዝና'), lang.s('Currently pregnant', 'አሁን ነፍሰ ጡር'),
       TGradients.gradBlue),
      (LifeStage.postpartum, Icons.child_care_rounded,
       lang.s('Postpartum', 'ድህረ-ወሊድ'), lang.s('After birth', 'ከወሊድ በኋላ'),
       TGradients.gradPink),
      (LifeStage.menopause, Icons.self_improvement_rounded,
       lang.s('Menopause', 'ወር አበባ ማቆሚያ'), lang.s('Ages 45+', 'ዕድሜ 45+'),
       TGradients.gradGold),
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.timeline_rounded, color: TColors.teal500, size: 48),
      const SizedBox(height: 20),
      Text(lang.s('Your life stage', 'የህይወት ደረጃዎ'),
          style: TTextStyles.headlineLarge),
      const SizedBox(height: 8),
      Text(lang.s('Content adapts to your stage',
          'ይዘቱ ለደረጃዎ ይለወጣል'),
          style: TTextStyles.bodyLarge),
      const SizedBox(height: 24),
      ...stages.map((s) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () => context.read<StageProvider>().setLifeStage(s.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: stage.lifeStage == s.$1 ? s.$5 : null,
              color: stage.lifeStage == s.$1 ? null : TColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: stage.lifeStage == s.$1
                    ? Colors.transparent
                    : TColors.border),
            ),
            child: Row(children: [
              Icon(s.$2,
                  color: stage.lifeStage == s.$1
                      ? TColors.white : TColors.teal500),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.$3, style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15,
                    color: stage.lifeStage == s.$1
                        ? TColors.white : TColors.dark)),
                Text(s.$4, style: TextStyle(
                    fontSize: 12,
                    color: stage.lifeStage == s.$1
                        ? TColors.white.withOpacity(0.8) : TColors.gray)),
              ]),
              const Spacer(),
              if (stage.lifeStage == s.$1)
                const Icon(Icons.check_circle_rounded,
                    color: TColors.white),
            ]),
          ),
        ),
      )),
    ]);
  }
}

// ─── STEP 4: STAGE DETAIL ────────────────────────────────────────
class _StepStageDetail extends StatelessWidget {
  final bool isPregnancy;
  final DateTime? lmpDate;
  final ValueChanged<DateTime?> onLmpChanged;

  const _StepStageDetail({
    required this.isPregnancy,
    required this.lmpDate,
    required this.onLmpChanged,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    if (!isPregnancy) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.water_drop_rounded,
            color: TColors.pink500, size: 48),
        const SizedBox(height: 20),
        Text(lang.s('Cycle details', 'የዑደት ዝርዝሮች'),
            style: TTextStyles.headlineLarge),
        const SizedBox(height: 8),
        Text(lang.s('When did your last period start?',
            'የመጨረሻ ወር አበባዎ መቼ ጀመረ?'),
            style: TTextStyles.bodyLarge),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now().subtract(
                  const Duration(days: 14)),
              firstDate: DateTime.now().subtract(
                  const Duration(days: 90)),
              lastDate: DateTime.now(),
            );
            onLmpChanged(picked);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: TColors.border),
            ),
            child: Row(children: [
              const Icon(Icons.calendar_today_rounded,
                  color: TColors.pink500),
              const SizedBox(width: 12),
              Text(
                lmpDate != null
                    ? '${lmpDate!.day}/${lmpDate!.month}/${lmpDate!.year}'
                    : lang.s('Select date', 'ቀን ይምረጡ'),
                style: TextStyle(
                    color: lmpDate != null ? TColors.dark : TColors.gray,
                    fontSize: 16)),
            ]),
          ),
        ),
      ]);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.pregnant_woman_rounded,
          color: TColors.teal500, size: 48),
      const SizedBox(height: 20),
      Text(lang.s('Pregnancy details', 'የእርግዝና ዝርዝሮች'),
          style: TTextStyles.headlineLarge),
      const SizedBox(height: 8),
      Text(lang.s('First day of your last period (LMP)',
          'የመጨረሻ ወር አበባ የመጀመሪያ ቀን'),
          style: TTextStyles.bodyLarge),
      const SizedBox(height: 32),
      GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now().subtract(
                const Duration(days: 100)),
            firstDate: DateTime.now().subtract(
                const Duration(days: 280)),
            lastDate: DateTime.now(),
          );
          onLmpChanged(picked);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: TColors.border),
          ),
          child: Row(children: [
            const Icon(Icons.calendar_today_rounded,
                color: TColors.teal500),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                lmpDate != null
                    ? '${lmpDate!.day}/${lmpDate!.month}/${lmpDate!.year}'
                    : lang.s('Select LMP date', 'LMP ቀን ይምረጡ'),
                style: TextStyle(
                    color: lmpDate != null ? TColors.dark : TColors.gray,
                    fontSize: 16)),
              if (lmpDate != null)
                Text(
                  lang.s(
                    'Week ${DateTime.now().difference(lmpDate!).inDays ~/ 7} of pregnancy',
                    'የእርግዝና ሳምንት ${DateTime.now().difference(lmpDate!).inDays ~/ 7}'),
                  style: const TextStyle(
                      color: TColors.teal500,
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
          ]),
        ),
      ),
    ]);
  }
}

// ─── STEP 5: EMERGENCY ───────────────────────────────────────────
class _StepEmergency extends StatelessWidget {
  final String partnerPhone, emergencyContact, emergencyName;
  final ValueChanged<String> onPartnerChanged;
  final ValueChanged<String> onContactChanged;
  final ValueChanged<String> onNameChanged;

  const _StepEmergency({
    required this.partnerPhone, required this.emergencyContact,
    required this.emergencyName, required this.onPartnerChanged,
    required this.onContactChanged, required this.onNameChanged,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.emergency_rounded, color: TColors.red400, size: 48),
      const SizedBox(height: 20),
      Text(lang.s('Safety contacts', 'የደህንነት ዕውቂያዎች'),
          style: TTextStyles.headlineLarge),
      const SizedBox(height: 8),
      Text(lang.s(
          'These will be notified in an emergency',
          'እነዚህ በአደጋ ጊዜ ያሳውቃሉ'),
          style: TTextStyles.bodyLarge),
      const SizedBox(height: 32),
      _Field(
          label: lang.s('Partner phone (optional)', 'የሸሪካ ስልክ (አማራጭ)'),
          icon: Icons.favorite_rounded,
          iconColor: TColors.pink500,
          onChanged: onPartnerChanged),
      const SizedBox(height: 16),
      _Field(
          label: lang.s('Emergency contact name', 'የአደጋ ዕውቂያ ስም'),
          icon: Icons.person_rounded,
          iconColor: TColors.teal500,
          onChanged: onNameChanged),
      const SizedBox(height: 16),
      _Field(
          label: lang.s('Emergency contact phone', 'የአደጋ ዕውቂያ ስልክ'),
          icon: Icons.phone_rounded,
          iconColor: TColors.teal500,
          keyboardType: TextInputType.phone,
          onChanged: onContactChanged),
    ]);
  }
}

class _Field extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;

  const _Field({
    required this.label, required this.icon,
    required this.iconColor, required this.onChanged,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) => TextField(
    onChanged: onChanged,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: iconColor, size: 20),
      filled: true, fillColor: TColors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: TColors.border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: TColors.teal500, width: 2)),
    ),
  );
}
