import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/providers/language_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final entries = [
      ('Mar 12','ማርች 12','😊',lang.s('Mood: Happy','ስሜት: ደስተኛ'),lang.s('Flow: Light','ፍሰት: ቀላል')),
      ('Mar 11','ማርች 11','😐',lang.s('Mood: Neutral','ስሜት: ቀጥ ያለ'),lang.s('Flow: Medium','ፍሰት: መካከለኛ')),
      ('Mar 10','ማርች 10','😢',lang.s('Mood: Low','ስሜት: ዝቅ ያለ'),lang.s('Flow: Heavy','ፍሰት: ከባድ')),
      ('Mar 9', 'ማርች 9', '😴',lang.s('Mood: Tired','ስሜት: ደካሜ'),lang.s('Flow: None','ፍሰት: ምንም')),
    ];
    return Scaffold(
      backgroundColor: TColors.cream,
      appBar: AppBar(
        backgroundColor: TColors.teal700, foregroundColor: TColors.white,
        title: Text(lang.history), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: entries.map((e) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: TColors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: TColors.teal700.withOpacity(0.05),
              blurRadius: 8, offset: const Offset(0, 2))]),
          child: Row(children: [
            Container(width: 52, height: 52,
              decoration: BoxDecoration(color: TColors.pink50,
                borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(e.$3, style: const TextStyle(fontSize: 26)))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(lang.isAmharic ? e.$2 : e.$1,
                  style: const TextStyle(fontSize: 13, color: TColors.gray)),
              Text(e.$4, style: const TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w700, color: TColors.dark)),
              Text(e.$5, style: const TextStyle(fontSize: 12, color: TColors.gray)),
            ])),
          ]),
        )).toList(),
      ),
    );
  }
}
