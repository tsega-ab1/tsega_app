import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';

class ReminderOverlay extends StatefulWidget {
  const ReminderOverlay({super.key});
  @override
  State<ReminderOverlay> createState() => _ReminderOverlayState();
}

class _ReminderOverlayState extends State<ReminderOverlay> {
  final _reminders = [
    _Rem('Daily Log', 'ዕለታዊ ምዝገባ', Icons.edit_note_rounded, TColors.pink500, true, '08:00 AM'),
    _Rem('Take Iron Supplement', 'ብረት ቫይታሚን ውሰድ', Icons.medication_rounded, TColors.teal500, true, '09:00 AM'),
    _Rem('ANC Visit', 'ANC ጉብኝት', Icons.local_hospital_rounded, TColors.blue500, false, 'Mar 25'),
    _Rem('Kick Counter', 'ምቶች ቆጣሪ', Icons.touch_app_rounded, TColors.teal500, true, '08:00 PM'),
    _Rem('Weekly Check-in', 'ሳምንታዊ ምዝገባ', Icons.fact_check_rounded, TColors.green500, false, 'Mondays'),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Container(
      decoration: const BoxDecoration(
        color: TColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4,
            decoration: BoxDecoration(color: TColors.border,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Text(lang.s('Reminders', 'ማስታወሻዎች'),
            style: const TextStyle(fontSize: 20,
                fontWeight: FontWeight.w700, color: TColors.dark)),
        const SizedBox(height: 16),
        ..._reminders.map((r) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: TColors.white,
            borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: r.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
              child: Icon(r.icon, color: r.color, size: 20)),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lang.isAmharic ? r.nameAm : r.nameEn,
                    style: const TextStyle(fontSize: 14,
                        fontWeight: FontWeight.w600, color: TColors.dark)),
                Text(r.time, style: const TextStyle(
                    fontSize: 12, color: TColors.gray)),
              ],
            )),
            Switch(
              value: r.on,
              activeColor: r.color,
              onChanged: (v) => setState(() => r.on = v),
            ),
          ]),
        )),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity, padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: TGradients.gradTeal,
              borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(lang.s('Save Reminders', 'ማስታወሻዎች ያስቀምጡ'),
                style: const TextStyle(color: TColors.white,
                    fontWeight: FontWeight.w700))),
          ),
        ),
        const SizedBox(height: 8),
      ]),
    );
  }
}

class _Rem {
  final String nameEn, nameAm, time;
  final IconData icon;
  final Color color;
  bool on;
  _Rem(this.nameEn, this.nameAm, this.icon, this.color, this.on, this.time);
}
