import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/stage_provider.dart';

class WeekByWeekScreen extends StatelessWidget {
  const WeekByWeekScreen({super.key});

  static const _dataEn = {
    4:  ('The Embryo', 'Your baby is the size of a poppy seed. The neural tube — brain and spinal cord — is forming.'),
    8:  ('The Fetus', 'Tiny fingers and toes are forming. Heart is beating at 150 beats per minute.'),
    12: ('End of First Trimester', 'Organs are formed. Miscarriage risk drops significantly. You may start to show.'),
    16: ('Growing Fast', 'Baby can hear your voice! Start talking and singing to them.'),
    20: ('Halfway There!', 'You may feel kicks for the first time. Anatomy scan reveals baby\'s development.'),
    24: ('Viability Week', 'If born now, baby has a chance of survival with intensive care.'),
    28: ('Third Trimester Begins', 'Baby opens eyes and responds to light. Brain development is rapid.'),
    32: ('Preparing for Birth', 'Baby is practicing breathing movements. Gaining weight fast now.'),
    36: ('Almost Ready', 'Baby is full term at 37 weeks. Start preparing your hospital bag!'),
    40: ('Due Date', 'Your baby is ready to meet you! Most babies arrive between weeks 38–42.'),
  };

  static const _dataAm = {
    4:  ('ፅንስ', 'ልጅዎ የፓፒ ዘር መጠን ነው። የነርቭ ቱቦ — አዕምሮ እና አከርካሪ — እየተፈጠረ ነው።'),
    8:  ('ፅንስ', 'ትንንሽ ጣቶች እና ጣቶቻቸው እየተፈጠሩ ናቸው። ልብ በደቂቃ 150 ጊዜ ይደቃ።'),
    12: ('የመጀመሪያ ሦስት ወር መጨረሻ', 'የሰውነት ክፍሎች ተፈጥረዋል። የፅንስ መጣል ስጋት ይቀንሳል።'),
    16: ('ፈጥኖ ያድጋል', 'ልጅ ድምፅዎን ሊሰማ ይችላል! ማናገር እና ዘፈን ይጀምሩ።'),
    20: ('እዚህ ደርሰዋል!', 'ምቶቹን ለመጀመሪያ ጊዜ ሊሰሙ ይችሉ ይሆናል። አናቶሚ ስካን ያሳያል።'),
    24: ('ሕይወት ሊኖር የሚችልበት ሳምንት', 'አሁን ቢወለድ፣ ልጁ ጥልቅ ክብካቤ ካለ የሕይወት ዕድል አለው።'),
    28: ('ሦስተኛ ሦስት ወር ይጀምራል', 'ልጅ ዓይን ከፍቶ ለብርሃን ይሠጣጣ። ምሰሶ እድገት ፈጣን ነው።'),
    32: ('ለወሊድ ዝግጁ', 'ልጅ የመተንፈስ እንቅስቃሴ ይለማምዳል። አሁን ክብደቱ ፈጥኖ ይጨምራል።'),
    36: ('ሊደርስ ቀረው', 'ልጅ በ37 ሳምንት ሙሉ ጊዜ ነው። ሆስፒታል ቦርሳዎን ያዘጋጁ!'),
    40: ('የወሊድ ቀን', 'ልጅዎ ሊያገኙዎት ዝግጁ ነው! አብዛኞቹ ልጆች በሳምንት 38-42 ይወለዳሉ።'),
  };

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final stage = context.watch<StageProvider>();
    final currentWeek = stage.pregnancyWeek;

    return Scaffold(
      backgroundColor: TColors.cream,
      appBar: AppBar(
        backgroundColor: TColors.teal700,
        foregroundColor: TColors.white,
        title: Text(lang.weekByWeek),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _dataEn.length,
        itemBuilder: (_, i) {
          final week = _dataEn.keys.elementAt(i);
          final en = _dataEn[week]!;
          final am = _dataAm[week]!;
          final isCurrent = currentWeek >= (i == 0 ? 0 : _dataEn.keys.elementAt(i-1))
              && currentWeek < week;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: isCurrent ? TGradients.gradTeal : null,
              color: isCurrent ? null : TColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                color: TColors.teal700.withOpacity(0.06),
                blurRadius: 10, offset: const Offset(0, 3))]),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? TColors.white.withOpacity(0.2)
                        : TColors.teal50,
                    borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text('$week',
                      style: TextStyle(fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isCurrent ? TColors.white : TColors.teal700))),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isCurrent) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: TColors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8)),
                        child: Text(lang.s('You are here', 'አሁን ያሉ ደረጃ'),
                            style: const TextStyle(fontSize: 10,
                                color: TColors.white,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(lang.isAmharic ? am.$1 : en.$1,
                        style: TextStyle(fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isCurrent ? TColors.white : TColors.dark)),
                    const SizedBox(height: 4),
                    Text(lang.isAmharic ? am.$2 : en.$2,
                        style: TextStyle(fontSize: 13, height: 1.5,
                            color: isCurrent
                                ? TColors.white.withOpacity(0.85)
                                : TColors.mid)),
                  ],
                )),
              ]),
            ),
          );
        },
      ),
    );
  }
}
