import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/stage_provider.dart';
import '../../widgets/common/tsega_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const ProfileScreen({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final lang  = context.watch<LanguageProvider>();
    final user  = context.watch<UserProvider>();
    final stage = context.watch<StageProvider>();

    return Scaffold(
      backgroundColor: TColors.cream,
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
            child: TsegaAppBar(scaffoldKey: scaffoldKey)),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(delegate: SliverChildListDelegate([
            // Avatar header
            Center(child: Column(children: [
              Stack(children: [
                Container(
                  width: 96, height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: TGradients.gradTeal,
                    boxShadow: [BoxShadow(
                      color: TColors.teal700.withOpacity(0.3),
                      blurRadius: 20, offset: const Offset(0, 6))]),
                  child: Center(child: Text(
                    user.displayName.isNotEmpty
                        ? user.displayName[0].toUpperCase() : 'T',
                    style: const TextStyle(fontSize: 40,
                        color: TColors.white, fontWeight: FontWeight.w700))),
                ),
                Positioned(bottom: 0, right: 0,
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: TColors.white, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                          color: TColors.teal700.withOpacity(0.2),
                          blurRadius: 6)]),
                    child: const Icon(Icons.edit_rounded,
                        color: TColors.teal500, size: 16)),
                ),
              ]),
              const SizedBox(height: 12),
              Text(user.displayName,
                  style: TTextStyles.headlineLarge),
              const SizedBox(height: 4),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(stage.lifeStageIcon,
                    color: TColors.teal500, size: 16),
                const SizedBox(width: 6),
                Text(lang.s(stage.lifeStageLabel,
                    _amLabel(stage.lifeStage)),
                    style: TTextStyles.bodyMedium),
              ]),
            ])),
            const SizedBox(height: 24),

            // Streak card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: TGradients.gradGold,
                borderRadius: BorderRadius.circular(20)),
              child: Row(children: [
                const Icon(Icons.local_fire_department_rounded,
                    color: TColors.white, size: 40),
                const SizedBox(width: 16),
                Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('${user.streak}',
                      style: const TextStyle(fontSize: 36,
                          color: TColors.white, fontWeight: FontWeight.w800)),
                  Text(lang.s('day streak 🔥', 'ቀን ተከታታይ 🔥'),
                      style: TextStyle(fontSize: 14,
                          color: TColors.white.withOpacity(0.9))),
                ]),
                const Spacer(),
                Column(children: [
                  Text(lang.s('Best', 'ምርጥ'),
                      style: TextStyle(fontSize: 12,
                          color: TColors.white.withOpacity(0.7))),
                  const Text('14',
                      style: TextStyle(fontSize: 22,
                          color: TColors.white, fontWeight: FontWeight.w700)),
                  Text(lang.s('days', 'ቀናት'),
                      style: TextStyle(fontSize: 12,
                          color: TColors.white.withOpacity(0.7))),
                ]),
              ]),
            ),
            const SizedBox(height: 16),

            // Language toggle card
            _SettingCard(
              icon: Icons.language_rounded,
              titleEn: 'Language / ቋንቋ',
              titleAm: 'ቋንቋ / Language',
              trailing: GestureDetector(
                onTap: () => context.read<LanguageProvider>().toggle(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: TColors.teal50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: TColors.teal300)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    _LTab('EN', !lang.isAmharic),
                    _LTab('አማ', lang.isAmharic),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Personal info
            _SectionLabel(lang.s('Personal Info', 'የግል መረጃ')),
            _InfoCard(children: [
              _InfoRow(Icons.person_rounded,
                  lang.s('Name', 'ስም'), user.displayName),
              _InfoRow(Icons.cake_rounded,
                  lang.s('Age', 'ዕድሜ'),
                  user.user?.age != null
                      ? '${user.user!.age} ${lang.s("years", "ዓመት")}'
                      : lang.s('Not set', 'አልተቀናጀም')),
              _InfoRow(Icons.location_on_rounded,
                  lang.s('Region', 'ክልል'),
                  user.user?.region ?? lang.s('Not set', 'አልተቀናጀም')),
              _InfoRow(Icons.phone_rounded,
                  lang.s('Phone', 'ስልክ'),
                  user.user?.phone ?? '--'),
            ]),
            const SizedBox(height: 8),

            // Emergency contacts
            _SectionLabel(lang.s('Emergency Contacts', 'የአደጋ ዕውቂያዎች')),
            _InfoCard(children: [
              _InfoRow(Icons.favorite_rounded,
                  lang.s('Partner', 'ሸሪካ'),
                  user.user?.partnerPhone ?? lang.s('Not set', 'አልተቀናጀም'),
                  iconColor: TColors.pink500),
              _InfoRow(Icons.emergency_rounded,
                  lang.s('Emergency', 'አደጋ'),
                  user.user?.emergencyContact ?? lang.s('Not set', 'አልተቀናጀም'),
                  iconColor: TColors.red400),
            ]),
            const SizedBox(height: 8),

            // Settings
            _SectionLabel(lang.s('Settings', 'ቅንብሮች')),
            _InfoCard(children: [
              _ActionRow(Icons.notifications_rounded,
                  lang.s('Notifications', 'ማሳወቂያዎች'),
                  lang.s('Reminders on', 'ማስታወሻ በርቷል'), () {}),
              _ActionRow(Icons.sync_alt_rounded,
                  lang.s('Switch Life Stage', 'ደረጃ ቀይር'),
                  lang.s(stage.lifeStageLabel,
                      _amLabel(stage.lifeStage)), () {}),
              _ActionRow(Icons.privacy_tip_rounded,
                  lang.s('Privacy & Data', 'ግላዊነት'),
                  lang.s('Stored locally', 'በስልክ ይጠበቃል'), () {}),
              _ActionRow(Icons.info_outline_rounded,
                  lang.s('About Tsega', 'ስለ ጸጋ'),
                  lang.s('Version 1.0.0', 'ስሪት 1.0.0'), () {}),
            ]),
            const SizedBox(height: 24),

            // Sign out
            GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TColors.red100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: TColors.red400.withOpacity(0.3))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout_rounded,
                        color: TColors.red400, size: 20),
                    const SizedBox(width: 10),
                    Text(lang.s('Sign Out', 'ውጣ'),
                        style: const TextStyle(color: TColors.red400,
                            fontWeight: FontWeight.w700, fontSize: 15)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100),
          ])),
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

class _LTab extends StatelessWidget {
  final String label; final bool active;
  const _LTab(this.label, this.active);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: active ? TColors.teal500 : Colors.transparent,
      borderRadius: BorderRadius.circular(16)),
    child: Text(label, style: TextStyle(fontSize: 12,
        fontWeight: FontWeight.w700,
        color: active ? TColors.white : TColors.teal500)));
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 8, 0, 8),
    child: Text(text, style: TTextStyles.labelMedium));
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: TColors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(
        color: TColors.teal700.withOpacity(0.05),
        blurRadius: 10, offset: const Offset(0, 3))]),
    child: Column(children: List.generate(children.length, (i) =>
      Column(children: [
        children[i],
        if (i < children.length - 1)
          const Divider(height: 1, indent: 56, endIndent: 16),
      ]))));
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color iconColor;
  const _InfoRow(this.icon, this.label, this.value,
      {this.iconColor = TColors.teal500});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(children: [
      Icon(icon, color: iconColor, size: 20),
      const SizedBox(width: 14),
      Expanded(child: Text(label, style: TTextStyles.bodyMedium)),
      Text(value, style: const TextStyle(fontSize: 13,
          fontWeight: FontWeight.w600, color: TColors.dark)),
    ]));
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final VoidCallback onTap;
  const _ActionRow(this.icon, this.label, this.subtitle, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Icon(icon, color: TColors.teal500, size: 20),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 14,
                color: TColors.dark, fontWeight: FontWeight.w500)),
            Text(subtitle, style: TTextStyles.bodySmall),
          ],
        )),
        const Icon(Icons.arrow_forward_ios_rounded,
            color: TColors.gray, size: 14),
      ])));
}

class _SettingCard extends StatelessWidget {
  final IconData icon;
  final String titleEn, titleAm;
  final Widget trailing;
  const _SettingCard({required this.icon, required this.titleEn,
      required this.titleAm, required this.trailing});
  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
          color: TColors.teal700.withOpacity(0.05),
          blurRadius: 10, offset: const Offset(0, 3))]),
      child: Row(children: [
        Icon(icon, color: TColors.teal500, size: 20),
        const SizedBox(width: 14),
        Expanded(child: Text(lang.isAmharic ? titleAm : titleEn,
            style: const TextStyle(fontSize: 14,
                color: TColors.dark, fontWeight: FontWeight.w500))),
        trailing,
      ]),
    );
  }
}
