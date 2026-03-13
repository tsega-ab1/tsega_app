import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/stage_provider.dart';

class StageSwitchOverlay extends StatelessWidget {
  const StageSwitchOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final stage = context.watch<StageProvider>();

    final stages = [
      (LifeStage.adolescence, Icons.eco_rounded,
       'Adolescence', 'ጉርምስና', 'Ages 12–18', 'ዕድሜ 12-18',
       TGradients.gradGreen),
      (LifeStage.reproductive, Icons.spa_rounded,
       'Reproductive', 'የማዋለድ', 'Ages 18–35', 'ዕድሜ 18-35',
       TGradients.gradTeal),
      (LifeStage.pregnancy, Icons.pregnant_woman_rounded,
       'Pregnancy', 'እርግዝና', 'Currently pregnant', 'አሁን ነፍሰ ጡር',
       TGradients.gradBlue),
      (LifeStage.postpartum, Icons.child_care_rounded,
       'Postpartum', 'ድህረ-ወሊድ', 'After birth', 'ከወሊድ በኋላ',
       TGradients.gradPink),
      (LifeStage.menopause, Icons.self_improvement_rounded,
       'Menopause', 'ወር አበባ ማቆሚያ', 'Ages 45+', 'ዕድሜ 45+',
       TGradients.gradGold),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: TColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4,
            decoration: BoxDecoration(
                color: TColors.border,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Text(lang.switchStage,
            style: const TextStyle(fontSize: 20,
                fontWeight: FontWeight.w700, color: TColors.dark)),
        const SizedBox(height: 6),
        Text(lang.s('Content updates instantly for your stage',
            'ይዘቱ ለደረጃዎ ወዲያውኑ ይለወጣል'),
            style: const TextStyle(fontSize: 13, color: TColors.gray)),
        const SizedBox(height: 20),
        ...stages.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () {
              context.read<StageProvider>().setLifeStage(s.$1);
              Navigator.pop(context);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: stage.lifeStage == s.$1 ? s.$7 : null,
                color: stage.lifeStage == s.$1 ? null : TColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: stage.lifeStage == s.$1
                      ? Colors.transparent : TColors.border)),
              child: Row(children: [
                Icon(s.$2,
                    color: stage.lifeStage == s.$1
                        ? TColors.white : TColors.teal500,
                    size: 22),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(lang.isAmharic ? s.$4 : s.$3,
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15,
                          color: stage.lifeStage == s.$1
                              ? TColors.white : TColors.dark)),
                  Text(lang.isAmharic ? s.$6 : s.$5,
                      style: TextStyle(fontSize: 12,
                          color: stage.lifeStage == s.$1
                              ? TColors.white.withOpacity(0.8)
                              : TColors.gray)),
                ]),
                const Spacer(),
                if (stage.lifeStage == s.$1)
                  const Icon(Icons.check_circle_rounded,
                      color: TColors.white, size: 22),
              ]),
            ),
          ),
        )),
        const SizedBox(height: 8),
      ]),
    );
  }
}
