import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/stage_provider.dart';
import '../../overlays/stage_switch_overlay.dart';

class HamburgerDrawer extends StatelessWidget {
  const HamburgerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final user = context.watch<UserProvider>();
    final stage = context.watch<StageProvider>();

    return Drawer(
      child: Column(children: [
        // Header
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(gradient: TGradients.gradTeal),
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: TColors.white.withOpacity(0.2),
                border: Border.all(color: TColors.white.withOpacity(0.5), width: 2)),
              child: Center(child: Text(
                user.displayName.isNotEmpty
                    ? user.displayName[0].toUpperCase() : 'T',
                style: const TextStyle(fontSize: 28,
                    color: TColors.white, fontWeight: FontWeight.w700))),
            ),
            const SizedBox(height: 12),
            Text(user.displayName,
                style: const TextStyle(fontSize: 18,
                    color: TColors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: TColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(stage.lifeStageIcon, color: TColors.white, size: 14),
                const SizedBox(width: 6),
                Text(lang.s(stage.lifeStageLabel,
                    _amLabel(stage.lifeStage)),
                    style: const TextStyle(fontSize: 12,
                        color: TColors.white, fontWeight: FontWeight.w600)),
              ]),
            ),
          ]),
        ),

        Expanded(child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            _DrawerItem(
              icon: Icons.sync_alt_rounded,
              labelEn: 'Switch Life Stage',
              labelAm: 'የህይወት ደረጃ ቀይር',
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const StageSwitchOverlay());
              },
            ),
            _DrawerItem(
              icon: Icons.history_rounded,
              labelEn: 'History',
              labelAm: 'ታሪክ',
              onTap: () => Navigator.pop(context),
            ),
            _DrawerItem(
              icon: Icons.science_rounded,
              labelEn: 'Lab Results',
              labelAm: 'የላብ ውጤቶች',
              onTap: () => Navigator.pop(context),
            ),
            _DrawerItem(
              icon: Icons.notifications_rounded,
              labelEn: 'Reminders',
              labelAm: 'ማስታወሻዎች',
              onTap: () => Navigator.pop(context),
            ),
            if (stage.showPartnerModule)
              _DrawerItem(
                icon: Icons.favorite_rounded,
                labelEn: 'Partner',
                labelAm: 'ሸሪካ',
                onTap: () => Navigator.pop(context),
              ),
            const Divider(indent: 16, endIndent: 16),
            // Language toggle
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Row(children: [
                const Icon(Icons.language_rounded,
                    color: TColors.teal500, size: 22),
                const SizedBox(width: 16),
                Text(lang.s('Language', 'ቋንቋ'),
                    style: const TextStyle(fontSize: 14,
                        color: TColors.dark, fontWeight: FontWeight.w500)),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.read<LanguageProvider>().toggle(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: TColors.teal50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: TColors.teal300)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      _LangTab('EN', !lang.isAmharic),
                      _LangTab('አማ', lang.isAmharic),
                    ]),
                  ),
                ),
              ]),
            ),
            const Divider(indent: 16, endIndent: 16),
            _DrawerItem(
              icon: Icons.settings_rounded,
              labelEn: 'Settings',
              labelAm: 'ቅንብሮች',
              onTap: () => Navigator.pop(context),
            ),
            _DrawerItem(
              icon: Icons.info_outline_rounded,
              labelEn: 'About Tsega',
              labelAm: 'ስለ ጸጋ',
              onTap: () => Navigator.pop(context),
            ),
            _DrawerItem(
              icon: Icons.support_agent_rounded,
              labelEn: 'Contact Support',
              labelAm: 'ድጋፍ ያግኙ',
              onTap: () => Navigator.pop(context),
            ),
          ],
        )),

        // Emergency button at bottom
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: TGradients.gradEmergency,
              borderRadius: BorderRadius.circular(14)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emergency_rounded,
                    color: TColors.white, size: 20),
                const SizedBox(width: 10),
                Text(lang.s('Emergency SOS — 907',
                    'አደጋ SOS — 907'),
                    style: const TextStyle(color: TColors.white,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ]),
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

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String labelEn, labelAm;
  final VoidCallback onTap;
  const _DrawerItem({required this.icon, required this.labelEn,
      required this.labelAm, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return ListTile(
      leading: Icon(icon, color: TColors.teal500, size: 22),
      title: Text(lang.isAmharic ? labelAm : labelEn,
          style: const TextStyle(fontSize: 14,
              color: TColors.dark, fontWeight: FontWeight.w500)),
      onTap: onTap,
      horizontalTitleGap: 8,
    );
  }
}

class _LangTab extends StatelessWidget {
  final String label;
  final bool active;
  const _LangTab(this.label, this.active);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: active ? TColors.teal500 : Colors.transparent,
      borderRadius: BorderRadius.circular(16)),
    child: Text(label, style: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w700,
        color: active ? TColors.white : TColors.teal500)),
  );
}
