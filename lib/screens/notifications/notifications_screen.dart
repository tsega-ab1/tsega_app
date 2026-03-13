import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final notifs = [
      (Icons.local_hospital_rounded, TColors.teal500,
       'ANC Visit Reminder', 'ANC ጉብኝት ማስታወሻ',
       'Your next ANC visit is on March 25', 'ቀጣዩ ANC ጉብኝትዎ ማርች 25 ነው',
       '2 hours ago', 'ከ2 ሰዓት በፊት'),
      (Icons.warning_rounded, TColors.red400,
       'Danger Sign Alert', 'አደጋ ምልክት ማንቂያ',
       'You reported severe headache. Please seek care.', 'ከፍተኛ ራስ ምታት ሪፖርት አድርገዋል። እባክዎን ሕክምና ይጠይቁ።',
       'Yesterday', 'ትናንት'),
      (Icons.lightbulb_rounded, TColors.statusYellow,
       'Daily Health Tip', 'የዕለቱ ጤና ምክር',
       'Iron-rich foods: Misir, Gomen, Teff injera', 'ብረት ያለው ምግብ: ምስር፣ ጎመን፣ ጤፍ እንጀራ',
       'Mar 11', 'ማርች 11'),
      (Icons.favorite_rounded, TColors.pink500,
       'Partner Connected', 'ሸሪካ ተቀላቀለ',
       'Abebe has joined your Tsega family', 'አበበ የጸጋ ቤተሰብዎ ተቀላቀለ',
       'Mar 10', 'ማርች 10'),
    ];

    return Scaffold(
      backgroundColor: TColors.cream,
      appBar: AppBar(
        backgroundColor: TColors.teal700, foregroundColor: TColors.white,
        title: Text(lang.s('Notifications','ማሳወቂያዎች')), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: notifs.map((n) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: TColors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: TColors.teal700.withOpacity(0.05),
              blurRadius: 8, offset: const Offset(0, 2))]),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 40, height: 40,
              decoration: BoxDecoration(color: n.$2.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
              child: Icon(n.$1, color: n.$2, size: 20)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(lang.isAmharic ? n.$4 : n.$3,
                  style: const TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w700, color: TColors.dark)),
              const SizedBox(height: 3),
              Text(lang.isAmharic ? n.$6 : n.$5,
                  style: const TextStyle(fontSize: 13, color: TColors.mid, height: 1.4)),
              const SizedBox(height: 4),
              Text(lang.isAmharic ? n.$8 : n.$7,
                  style: const TextStyle(fontSize: 11, color: TColors.gray)),
            ])),
          ]),
        )).toList(),
      ),
    );
  }
}
