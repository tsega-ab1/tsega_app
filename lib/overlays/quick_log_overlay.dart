import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';

class QuickLogOverlay extends StatefulWidget {
  const QuickLogOverlay({super.key});
  @override
  State<QuickLogOverlay> createState() => _QuickLogOverlayState();
}

class _QuickLogOverlayState extends State<QuickLogOverlay> {
  String _mood = '';
  String _flow = 'none';
  final _moods = ['😊','😐','😢','😤','😴','🤢'];
  final _moodsAm = ['ደስተኛ','ቀጥ ያለ','አዝን','ቅሬተኛ','ደከሜ','ታምሜ'];

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Container(
      decoration: const BoxDecoration(
        color: TColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(24, 24, 24,
          MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4,
            decoration: BoxDecoration(color: TColors.border,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Text(lang.logToday,
            style: const TextStyle(fontSize: 20,
                fontWeight: FontWeight.w700, color: TColors.dark)),
        const SizedBox(height: 24),
        // Mood
        Align(alignment: Alignment.centerLeft,
          child: Text(lang.s('How are you feeling?', 'እንዴት ይሰማዎታል?'),
              style: const TextStyle(fontWeight: FontWeight.w600,
                  fontSize: 14, color: TColors.dark))),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_moods.length, (i) =>
            GestureDetector(
              onTap: () => setState(() => _mood = _moods[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: _mood == _moods[i]
                      ? TColors.teal100 : TColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _mood == _moods[i]
                        ? TColors.teal500 : TColors.border)),
                child: Center(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_moods[i], style: const TextStyle(fontSize: 20)),
                  ],
                )),
              ),
            )),
        ),
        const SizedBox(height: 20),
        // Flow
        Align(alignment: Alignment.centerLeft,
          child: Text(lang.s('Flow intensity', 'የፍሰት ጥንካሬ'),
              style: const TextStyle(fontWeight: FontWeight.w600,
                  fontSize: 14, color: TColors.dark))),
        const SizedBox(height: 12),
        Row(children: ['none','light','medium','heavy'].map((f) =>
          Expanded(child: GestureDetector(
            onTap: () => setState(() => _flow = f),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: _flow == f ? TGradients.gradPink : null,
                color: _flow == f ? null : TColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _flow == f ? Colors.transparent : TColors.border)),
              child: Center(child: Text(
                lang.s(f, _amFlow(f)),
                style: TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _flow == f ? TColors.white : TColors.gray),
              )),
            ),
          ))).toList(),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: TGradients.gradTeal,
              borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(lang.save,
                style: const TextStyle(color: TColors.white,
                    fontWeight: FontWeight.w700, fontSize: 16))),
          ),
        ),
      ]),
    );
  }

  String _amFlow(String f) {
    switch (f) {
      case 'none': return 'ምንም';
      case 'light': return 'ቀላል';
      case 'medium': return 'መካከለኛ';
      case 'heavy': return 'ከባድ';
      default: return f;
    }
  }
}
