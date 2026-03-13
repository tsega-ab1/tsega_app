import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/stage_provider.dart';
import '../../widgets/common/tsega_app_bar.dart';

class EducationScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const EducationScreen({super.key, required this.scaffoldKey});
  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  int _completed = 2;
  final int _total = 8;
  String _filter = 'All';

  final _modules = [
    _Mod('cycle_basics', 'Understanding Your Cycle', 'ዑደቱን መረዳት', 'Reproductive', 'የማዋለድ', '8 min', true, false, TGradients.gradPink),
    _Mod('danger_signs', 'Danger Signs in Pregnancy', 'በእርግዝና አደጋ ምልክቶች', 'Pregnancy', 'እርግዝና', '12 min', true, false, TGradients.gradTeal),
    _Mod('iron_nutrition', 'Iron & Nutrition Guide', 'ብረት እና አመጋገብ መመሪያ', 'Nutrition', 'አመጋገብ', '10 min', false, false, TGradients.gradGreen),
    _Mod('anc_visits', 'ANC Visits Explained', 'ANC ጉብኝቶች ማብራሪያ', 'Pregnancy', 'እርግዝና', '15 min', false, false, TGradients.gradBlue),
    _Mod('postpartum', 'Postpartum Recovery', 'ድህረ-ወሊድ ማገገም', 'Postpartum', 'ድህረ-ወሊድ', '10 min', false, true, TGradients.gradPink),
    _Mod('mental_health', 'Mental Health in Pregnancy', 'በእርግዝና የአዕምሮ ጤና', 'Wellness', 'ጤናማነት', '8 min', false, true, TGradients.gradGold),
    _Mod('lab_literacy', 'Reading Lab Results', 'የላብ ውጤቶችን ማንበብ', 'Clinical', 'ክሊኒካዊ', '12 min', false, true, TGradients.gradBlue),
    _Mod('breastfeeding', 'Breastfeeding Guide', 'የጡት ማጥባት መመሪያ', 'Postpartum', 'ድህረ-ወሊድ', '10 min', false, true, TGradients.gradGreen),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final cats = ['All', 'Pregnancy', 'Nutrition', 'Wellness', 'Clinical', 'Postpartum'];
    final filtered = _filter == 'All' ? _modules
        : _modules.where((m) => m.category == _filter).toList();
    final badges = [
      ('First Step', 'የመጀመሪያ እርምጃ', Icons.star_rounded, 1, TGradients.gradTeal),
      ('Health Aware', 'ጤና ንቁ', Icons.favorite_rounded, 3, TGradients.gradPink),
      ('Health Scholar', 'የጤና ምሁር', Icons.school_rounded, 5, TGradients.gradBlue),
      ('Champion', 'ሻምፒዮን', Icons.emoji_events_rounded, 8, TGradients.gradGold),
    ];

    return Scaffold(
      backgroundColor: TColors.cream,
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: TsegaAppBar(scaffoldKey: widget.scaffoldKey)),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(delegate: SliverChildListDelegate([
            Text(lang.learningHub, style: TTextStyles.headlineLarge),
            const SizedBox(height: 20),
            // Progress card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: TGradients.gradTeal,
                borderRadius: BorderRadius.circular(20)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(lang.s('$_completed of $_total modules', '$_completed / $_total ክፍሎች'),
                      style: const TextStyle(color: TColors.white, fontWeight: FontWeight.w700)),
                  Text('${((_completed / _total) * 100).toInt()}%',
                      style: const TextStyle(color: TColors.white,
                          fontSize: 20, fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _completed / _total,
                    backgroundColor: TColors.white.withOpacity(0.3),
                    color: TColors.white, minHeight: 8)),
                const SizedBox(height: 10),
                Text(lang.s('Next badge: Health Scholar (5 modules)',
                    'ቀጣይ ሽልማት: የጤና ምሁር (5 ክፍሎች)'),
                    style: TextStyle(color: TColors.white.withOpacity(0.85),
                        fontSize: 12)),
              ]),
            ),
            const SizedBox(height: 20),
            // Badges row
            Row(children: badges.map((b) {
              final unlocked = _completed >= b.$4;
              return Expanded(child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: unlocked ? b.$5 : null,
                  color: unlocked ? null : TColors.border,
                  borderRadius: BorderRadius.circular(14)),
                child: Column(children: [
                  Icon(b.$3, color: unlocked ? TColors.white : TColors.gray, size: 24),
                  const SizedBox(height: 4),
                  Text(lang.isAmharic ? b.$2 : b.$1,
                      style: TextStyle(fontSize: 9,
                          color: unlocked ? TColors.white : TColors.gray,
                          fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center),
                ]),
              ));
            }).toList()),
            const SizedBox(height: 20),
            // Category filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: cats.map((c) => GestureDetector(
                onTap: () => setState(() => _filter = c),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: _filter == c ? TGradients.gradTeal : null,
                    color: _filter == c ? null : TColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _filter == c ? Colors.transparent : TColors.border)),
                  child: Text(c, style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: _filter == c ? TColors.white : TColors.gray)),
                ),
              )).toList()),
            ),
            const SizedBox(height: 16),
            // Modules
            ...filtered.map((m) => _ModCard(
              mod: m,
              onComplete: () => setState(() {
                if (!m.completed) {
                  m.completed = true;
                  _completed++;
                }
              }),
            )),
            const SizedBox(height: 80),
          ])),
        ),
      ]),
    );
  }
}

class _Mod {
  final String id, titleEn, titleAm, category, categoryAm, duration;
  bool completed;
  final bool locked;
  final LinearGradient gradient;
  _Mod(this.id, this.titleEn, this.titleAm, this.category, this.categoryAm,
      this.duration, this.completed, this.locked, this.gradient);
}

class _ModCard extends StatelessWidget {
  final _Mod mod;
  final VoidCallback onComplete;
  const _ModCard({required this.mod, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: mod.locked ? TColors.border.withOpacity(0.5) : TColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: mod.locked ? null : [BoxShadow(
          color: TColors.teal700.withOpacity(0.06),
          blurRadius: 12, offset: const Offset(0, 3))]),
      child: Row(children: [
        Container(
          width: 72, height: 80,
          decoration: BoxDecoration(
            gradient: mod.locked ? null : mod.gradient,
            color: mod.locked ? TColors.gray.withOpacity(0.3) : null,
            borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16))),
          child: Center(child: Icon(
            mod.locked ? Icons.lock_rounded : Icons.play_circle_filled_rounded,
            color: TColors.white, size: 28)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: TColors.teal50,
                  borderRadius: BorderRadius.circular(8)),
                child: Text(
                  lang.isAmharic ? mod.categoryAm : mod.category,
                  style: const TextStyle(fontSize: 10, color: TColors.teal700))),
              if (mod.completed) ...[
                const SizedBox(width: 6),
                const Icon(Icons.check_circle_rounded,
                    color: TColors.green500, size: 14),
                Text(lang.s(' Done', ' ተጠናቅቋል'),
                    style: const TextStyle(fontSize: 10,
                        color: TColors.green700, fontWeight: FontWeight.w600)),
              ],
            ]),
            const SizedBox(height: 4),
            Text(lang.isAmharic ? mod.titleAm : mod.titleEn,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                    color: mod.locked ? TColors.gray : TColors.dark)),
            const SizedBox(height: 2),
            Row(children: [
              const Icon(Icons.headphones_rounded,
                  color: TColors.gray, size: 12),
              const SizedBox(width: 4),
              Text(mod.duration, style: const TextStyle(
                  fontSize: 12, color: TColors.gray)),
            ]),
          ],
        )),
        if (!mod.locked && !mod.completed)
          GestureDetector(
            onTap: onComplete,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: TGradients.gradTeal,
                borderRadius: BorderRadius.circular(10)),
              child: Text(lang.s('Start', 'ጀምር'),
                  style: const TextStyle(color: TColors.white,
                      fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
        if (!mod.locked && mod.completed)
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.replay_rounded, color: TColors.teal500, size: 22)),
        if (mod.locked)
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.lock_rounded, color: TColors.gray, size: 20)),
      ]),
    );
  }
}
