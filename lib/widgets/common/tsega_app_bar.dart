import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/stage_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../overlays/stage_switch_overlay.dart';

class TsegaAppBar extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const TsegaAppBar({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final stage = context.watch<StageProvider>();
    final user = context.watch<UserProvider>();
    return Container(
      decoration: const BoxDecoration(gradient: TGradients.gradTeal),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(children: [
            GestureDetector(
              onTap: () => scaffoldKey.currentState?.openDrawer(),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: TColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.menu_rounded,
                    color: TColors.white, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TSEGA ጸጋ',
                    style: TextStyle(fontSize: 16,
                        color: TColors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2)),
                Text(lang.s('Precision Health', 'ትክክለኛ ጤና'),
                    style: TextStyle(fontSize: 11,
                        color: TColors.white.withOpacity(0.75))),
              ],
            )),
            // Stage badge button
            GestureDetector(
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const StageSwitchOverlay(),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: TColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: TColors.white.withOpacity(0.4))),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(stage.lifeStageIcon,
                      color: TColors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(lang.s(stage.lifeStageLabel,
                      _amLabel(stage.lifeStage)),
                      style: const TextStyle(fontSize: 12,
                          color: TColors.white,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down_rounded,
                      color: TColors.white, size: 16),
                ]),
              ),
            ),
            const SizedBox(width: 8),
            // Language toggle
            GestureDetector(
              onTap: () => context.read<LanguageProvider>().toggle(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: TColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20)),
                child: Text(lang.isAmharic ? 'EN' : 'አማ',
                    style: const TextStyle(fontSize: 12,
                        color: TColors.white,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  String _amLabel(LifeStage s) {
    switch (s) {
      case LifeStage.adolescence: return 'ጉርምስና';
      case LifeStage.reproductive: return 'የማዋለድ';
      case LifeStage.pregnancy: return 'እርግዝና';
      case LifeStage.postpartum: return 'ድህረ-ወሊድ';
      case LifeStage.menopause: return 'ወር አበባ ማቆሚያ';
    }
  }
}
