import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';

class DangerChecklistOverlay extends StatefulWidget {
  const DangerChecklistOverlay({super.key});
  @override
  State<DangerChecklistOverlay> createState() => _DangerChecklistOverlayState();
}

class _DangerChecklistOverlayState extends State<DangerChecklistOverlay> {
  final _signs = [
    _DS('Severe headache that won\'t go away',
        'የማይቆም ከፍተኛ ራስ ምታት',
        'May indicate preeclampsia or high blood pressure',
        'ቅድመ-ወሊድ ከፍተኛ ደም ግፊት ሊሆን ይችላል',
        Icons.psychology_rounded, false),
    _DS('Blurred or double vision',
        'ደብዛዛ ወይም ድርብ ዕይታ',
        'Can be a sign of preeclampsia',
        'የቅድመ-ወሊድ ከፍተኛ ደም ግፊት ምልክት ሊሆን ይችላል',
        Icons.visibility_off_rounded, false),
    _DS('Sudden swelling of face, hands, or feet',
        'ፊት፣ እጅ፣ ወይም እግር ድንገተኛ ማበጥ',
        'Especially with headache — go to hospital',
        'በተለይ ከራስ ምታት ጋር — ሆስፒታል ሂዱ',
        Icons.front_hand_rounded, false),
    _DS('Heavy vaginal bleeding',
        'ከፍተኛ ብልት ደም መፍሰስ',
        'Any bleeding in pregnancy needs immediate care',
        'ማንኛውም ደም ፈሰሶ ወዲያውኑ ሕክምና ያስፈልጋል',
        Icons.water_drop_rounded, false),
    _DS('Baby not moving for 2+ hours',
        'ልጅ ለ2+ ሰዓት ያለ እንቅስቃሴ',
        'Count kicks — less than 10 in 2 hours is concerning',
        'ምቶቹን ቁጠሩ — በ2 ሰዓት 10 ያነሰ ያሳስባል',
        Icons.child_care_rounded, false),
    _DS('Fever above 38°C (100.4°F)',
        'ከ38°C በላይ ትኩሳት',
        'May indicate infection — go to health center',
        'ኢንፌክሽን ሊሆን ይችላል — ጤና ጣቢያ ሂዱ',
        Icons.thermostat_rounded, false),
    _DS('Difficulty breathing or chest pain',
        'የመተንፈስ ችግር ወይም የደረት ህመም',
        'Can indicate blood clots or heart issues',
        'የደም ቅዳ ወይም የልብ ችግር ሊሆን ይችላል',
        Icons.air_rounded, false),
    _DS('Severe abdominal pain or cramping',
        'ከፍተኛ የሆድ ህመም ወይም ቁርጠት',
        'Could indicate placental abruption',
        'የእፁ መላቀቅ ሊሆን ይችላል',
        Icons.sick_rounded, false),
  ];

  int get _checked => _signs.where((s) => s.checked).length;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: TColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          decoration: const BoxDecoration(
            gradient: TGradients.gradEmergency,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.warning_rounded, color: TColors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(child: Text(lang.dangerSigns,
                  style: const TextStyle(fontSize: 18,
                      color: TColors.white, fontWeight: FontWeight.w700))),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close_rounded, color: TColors.white)),
            ]),
            const SizedBox(height: 6),
            Text(lang.s(
                'Check symptoms you are experiencing now',
                'አሁን እያጋጠሙዎ ያሉ ምልክቶችን ምልክት ያድርጉ'),
                style: TextStyle(fontSize: 12,
                    color: TColors.white.withOpacity(0.8))),
          ]),
        ),
        // Alert banner when signs checked
        if (_checked > 0)
          Container(
            padding: const EdgeInsets.all(14),
            color: TColors.red100,
            child: Row(children: [
              const Icon(Icons.emergency_rounded,
                  color: TColors.red400, size: 22),
              const SizedBox(width: 10),
              Expanded(child: Text(
                lang.s(
                  '$_checked danger sign${_checked > 1 ? 's' : ''} checked — seek care immediately',
                  '$_checked አደጋ ምልክት${_checked > 1 ? 'ዎች' : ''} ምልክት ተደርጓል — ወዲያውኑ ሕክምና ይጠይቁ'),
                style: const TextStyle(fontSize: 13,
                    color: TColors.red400, fontWeight: FontWeight.w700))),
            ]),
          ),
        // Scrollable checklist
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _signs.length,
          itemBuilder: (_, i) {
            final s = _signs[i];
            return GestureDetector(
              onTap: () => setState(() => s.checked = !s.checked),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: s.checked ? TColors.red100 : TColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: s.checked ? TColors.red400.withOpacity(0.5) : TColors.border)),
                child: Row(children: [
                  Icon(s.icon,
                      color: s.checked ? TColors.red400 : TColors.gray,
                      size: 22),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lang.isAmharic ? s.nameAm : s.nameEn,
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14,
                              color: s.checked ? TColors.red400 : TColors.dark)),
                      Text(lang.isAmharic ? s.descAm : s.descEn,
                          style: const TextStyle(fontSize: 12,
                              color: TColors.gray, height: 1.3)),
                    ],
                  )),
                  Checkbox(
                    value: s.checked,
                    activeColor: TColors.red400,
                    onChanged: (v) => setState(() => s.checked = v ?? false),
                  ),
                ]),
              ),
            );
          },
        )),
        // Bottom CTA
        Padding(
          padding: const EdgeInsets.all(16),
          child: _checked > 0
              ? GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: double.infinity, padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: TGradients.gradEmergency,
                      borderRadius: BorderRadius.circular(14)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.phone_rounded,
                          color: TColors.white, size: 22),
                      const SizedBox(width: 10),
                      Text(lang.s('Call 907 — Ambulance',
                          '907 ደውሉ — አምቡላንስ'),
                          style: const TextStyle(color: TColors.white,
                              fontWeight: FontWeight.w800, fontSize: 16)),
                    ]),
                  ),
                )
              : Text(lang.s(
                  'If you experience any of these signs, go to hospital immediately.',
                  'ከእነዚህ ምልክቶቹ ማንኛቸውንም ካጋጠሙዎ፣ ወዲያውኑ ሆስፒታል ይሂዱ።'),
                  style: const TextStyle(fontSize: 13, color: TColors.gray),
                  textAlign: TextAlign.center),
        ),
        const SizedBox(height: 8),
      ]),
    );
  }
}

class _DS {
  final String nameEn, nameAm, descEn, descAm;
  final IconData icon;
  bool checked;
  _DS(this.nameEn, this.nameAm, this.descEn, this.descAm, this.icon, this.checked);
}
