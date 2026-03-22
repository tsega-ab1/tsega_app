import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/xp_provider.dart';
import '../../models/gamification_model.dart';
import '../../overlays/level_up_overlay.dart';
import '../../overlays/redemption_qr_overlay.dart';
import '../../overlays/sponsor_scan_overlay.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});
  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ringCtrl;
  late Animation<double> _ringAnim;
  int _tab = 0; // 0=Earn 1=Redeem 2=History

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _ringAnim = CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut);
    _ringCtrl.forward();
  }

  @override
  void dispose() { _ringCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final lang  = context.watch<LanguageProvider>();
    final xp    = context.watch<XpProvider>();
    final level = xp.level;

    // Check level-up
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (xp.consumeLevelUp()) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => LevelUpOverlay(level: xp.level),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Stack(children: [
        // Dark animated background
        _Background(anim: _ringAnim),

        SafeArea(child: Column(children: [
          // ── HEADER ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: _GlassBtn(icon: Icons.arrow_back_ios_rounded)),
              const Spacer(),
              Text('TSEGA REWARDS',
                  style: TextStyle(fontSize: 13,
                      color: TColors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w700, letterSpacing: 2)),
              const Spacer(),
              const SizedBox(width: 40),
            ]),
          ),

          // ── XP RING HERO ────────────────────────────────────────
          const SizedBox(height: 24),
          _XpRing(
            xp: xp.xp,
            coins: xp.coins,
            level: level,
            progress: xp.levelProgress,
            anim: _ringAnim,
            lang: lang,
          ),
          const SizedBox(height: 20),

          // ── SCAN + REDEEM WIDGET ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              // Left: Scan sponsor QR
              Expanded(child: GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const SponsorScanOverlay(),
                ),
                child: _ActionTile(
                  icon: Icons.qr_code_scanner_rounded,
                  labelEn: 'Scan & Earn',
                  labelAm: 'ቃኝ እና አግኝ',
                  subEn: 'Scan sponsor QR\nto earn coins',
                  subAm: 'ስፖንሰር QR ቃኝ\nለሳንቲሞች',
                  gradient: TGradients.gradTeal,
                  lang: lang,
                ),
              )),
              const SizedBox(width: 12),
              // Right: Show my QR
              Expanded(child: GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => RedemptionQrOverlay(coins: xp.coins),
                ),
                child: _ActionTile(
                  icon: Icons.qr_code_rounded,
                  labelEn: 'Use My QR',
                  labelAm: 'QR ተጠቀም',
                  subEn: 'Show at partner\nlocations',
                  subAm: 'ለሸሪካ ቦታዎች\nአሳይ',
                  gradient: TGradients.gradPink,
                  lang: lang,
                ),
              )),
            ]),
          ),
          const SizedBox(height: 16),

          // ── TABS ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _TabRow(
              selected: _tab,
              labels: [
                lang.s('Earn', 'አግኝ'),
                lang.s('Redeem', 'ውጤምም'),
                lang.s('History', 'ታሪክ'),
              ],
              onTap: (i) => setState(() => _tab = i),
            ),
          ),
          const SizedBox(height: 12),

          // ── TAB CONTENT ─────────────────────────────────────────
          Expanded(child: IndexedStack(
            index: _tab,
            children: [
              _EarnTab(lang: lang),
              _RedeemTab(lang: lang, xp: xp),
              _HistoryTab(lang: lang, xp: xp),
            ],
          )),
        ])),
      ]),
    );
  }
}

// ─── XP RING ─────────────────────────────────────────────────────
class _XpRing extends StatelessWidget {
  final int xp, coins;
  final TsegaLevel level;
  final double progress;
  final Animation<double> anim;
  final LanguageProvider lang;

  const _XpRing({
    required this.xp, required this.coins, required this.level,
    required this.progress, required this.anim, required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return Center(child: SizedBox(
      width: 180, height: 180,
      child: Stack(alignment: Alignment.center, children: [
        // Outer glow ring
        AnimatedBuilder(
          animation: anim,
          builder: (_, __) => CustomPaint(
            size: const Size(180, 180),
            painter: _RingPainter(
              progress: anim.value * progress,
              gradient: level.gradient,
            ),
          ),
        ),
        // Center content
        Column(mainAxisSize: MainAxisSize.min, children: [
          // Big ጸጋ logo text
          ShaderMask(
            shaderCallback: (b) => level.gradient.createShader(b),
            child: const Text('ጸጋ',
                style: TextStyle(fontSize: 42,
                    color: TColors.white, fontWeight: FontWeight.w300)),
          ),
          const SizedBox(height: 2),
          Text(lang.isAmharic ? level.nameAm : level.nameEn,
              style: const TextStyle(fontSize: 11,
                  color: TColors.white, fontWeight: FontWeight.w700,
                  letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: TColors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10)),
            child: Text('$coins TC',
                style: const TextStyle(fontSize: 13,
                    color: TColors.white, fontWeight: FontWeight.w800)),
          ),
        ]),
      ]),
    ));
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final LinearGradient gradient;
  _RingPainter({required this.progress, required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const stroke = 14.0;
    const pi = 3.14159265;

    // Background ring
    canvas.drawCircle(center, radius,
        Paint()
          ..color = TColors.white.withOpacity(0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke);

    // Gradient progress arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -pi / 2, progress * 2 * pi, false, paint);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ─── ACTION TILE ─────────────────────────────────────────────────
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String labelEn, labelAm, subEn, subAm;
  final LinearGradient gradient;
  final LanguageProvider lang;

  const _ActionTile({
    required this.icon, required this.labelEn, required this.labelAm,
    required this.subEn, required this.subAm,
    required this.gradient, required this.lang,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              gradient.colors.first.withOpacity(0.25),
              gradient.colors.last.withOpacity(0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: gradient.colors.first.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: TColors.white, size: 22),
            ),
            const SizedBox(height: 10),
            Text(lang.isAmharic ? labelAm : labelEn,
                style: const TextStyle(fontSize: 14,
                    color: TColors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(lang.isAmharic ? subAm : subEn,
                style: TextStyle(fontSize: 11,
                    color: TColors.white.withOpacity(0.65), height: 1.4)),
          ],
        ),
      ),
    ),
  );
}

// ─── TAB ROW ─────────────────────────────────────────────────────
class _TabRow extends StatelessWidget {
  final int selected;
  final List<String> labels;
  final ValueChanged<int> onTap;
  const _TabRow({required this.selected, required this.labels, required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
    height: 40,
    decoration: BoxDecoration(
      color: TColors.white.withOpacity(0.06),
      borderRadius: BorderRadius.circular(12)),
    child: Row(
      children: List.generate(labels.length, (i) => Expanded(
        child: GestureDetector(
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: selected == i ? TGradients.gradTeal : null,
              borderRadius: BorderRadius.circular(9)),
            child: Center(child: Text(labels[i],
                style: TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected == i
                        ? TColors.white
                        : TColors.white.withOpacity(0.4)))),
          ),
        ),
      )),
    ),
  );
}

// ─── EARN TAB ────────────────────────────────────────────────────
class _EarnTab extends StatelessWidget {
  final LanguageProvider lang;
  const _EarnTab({required this.lang});

  @override
  Widget build(BuildContext context) {
    final events = [
      (XpEvent.dailyLog, Icons.edit_note_rounded, TColors.pink500),
      (XpEvent.moduleComplete, Icons.menu_book_rounded, TColors.teal500),
      (XpEvent.quizPassed, Icons.quiz_rounded, TColors.blue500),
      (XpEvent.labEntered, Icons.science_rounded, TColors.green500),
      (XpEvent.ancLogged, Icons.local_hospital_rounded, TColors.teal500),
      (XpEvent.weekStreak, Icons.local_fire_department_rounded, const Color(0xFFFF6B00)),
      (XpEvent.wearableSynced, Icons.watch_rounded, TColors.blue500),
      (XpEvent.stepsGoalMet, Icons.directions_walk_rounded, TColors.green500),
      (XpEvent.sponsorQrScanned, Icons.qr_code_scanner_rounded, TColors.teal500),
      (XpEvent.partnerJoined, Icons.favorite_rounded, TColors.pink500),
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Text(lang.s('Ways to earn coins', 'ሳንቲሞች ለማግኘት መንገዶች'),
            style: TextStyle(fontSize: 12,
                color: TColors.white.withOpacity(0.5),
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...events.map((e) => _EarnRow(
          event: e.$1, icon: e.$2, color: e.$3, lang: lang)),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _EarnRow extends StatelessWidget {
  final XpEvent event;
  final IconData icon;
  final Color color;
  final LanguageProvider lang;
  const _EarnRow({required this.event, required this.icon,
      required this.color, required this.lang});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: TColors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: TColors.white.withOpacity(0.08))),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Text(
            lang.isAmharic ? event.labelAm() : event.labelEn(),
            style: const TextStyle(fontSize: 14, color: TColors.white))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8)),
            child: Text('+${event.xp} XP',
                style: TextStyle(fontSize: 12,
                    color: color, fontWeight: FontWeight.w800))),
        ]),
      ),
    ),
  );
}

// ─── REDEEM TAB ──────────────────────────────────────────────────
class _RedeemTab extends StatelessWidget {
  final LanguageProvider lang;
  final XpProvider xp;
  const _RedeemTab({required this.lang, required this.xp});

  @override
  Widget build(BuildContext context) {
    final currentLevel = xp.level.level;
    final inApp = TsegaReward.rewards
        .where((r) => r.type == RewardType.inApp).toList();
    final digital = TsegaReward.rewards
        .where((r) => r.type == RewardType.digital).toList();
    final physical = TsegaReward.rewards
        .where((r) => r.type == RewardType.physical).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // Balance bar
        _BalanceBar(coins: xp.coins, lang: lang),
        const SizedBox(height: 16),
        _RewardSection(
          titleEn: 'In-App Rewards', titleAm: 'የመተግበሪያ ሽልማቶች',
          rewards: inApp, coins: xp.coins,
          currentLevel: currentLevel, lang: lang,
          onRedeem: (r) => _confirmRedeem(context, r, xp, lang),
        ),
        _RewardSection(
          titleEn: 'Digital Rewards', titleAm: 'ዲጂታል ሽልማቶች',
          rewards: digital, coins: xp.coins,
          currentLevel: currentLevel, lang: lang,
          onRedeem: (r) => _confirmRedeem(context, r, xp, lang),
          comingSoon: true,
        ),
        _RewardSection(
          titleEn: 'Partner Rewards', titleAm: 'የሸሪካ ሽልማቶች',
          rewards: physical, coins: xp.coins,
          currentLevel: currentLevel, lang: lang,
          onRedeem: (r) => _confirmRedeem(context, r, xp, lang),
          comingSoon: true,
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  void _confirmRedeem(BuildContext ctx, TsegaReward r,
      XpProvider xp, LanguageProvider lang) {
    if (!xp.canAfford(r)) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(lang.s(
            'Not enough coins. Need ${r.cost} TC.',
            'በቂ ሳንቲሞች የሉም። ${r.cost} TC ያስፈልጋል።')),
        backgroundColor: TColors.red400,
      ));
      return;
    }
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => _RedeemConfirmSheet(
        reward: r, xp: xp, lang: lang),
    );
  }
}

class _BalanceBar extends StatelessWidget {
  final int coins;
  final LanguageProvider lang;
  const _BalanceBar({required this.coins, required this.lang});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            TColors.teal700.withOpacity(0.3),
            TColors.blue700.withOpacity(0.2),
          ]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: TColors.teal400.withOpacity(0.3))),
        child: Row(children: [
          const Icon(Icons.token_rounded, color: TColors.teal300, size: 28),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(lang.s('Your Balance', 'ቀሪ ሂሳብዎ'),
                style: TextStyle(fontSize: 12,
                    color: TColors.white.withOpacity(0.6))),
            Text('$coins TC',
                style: const TextStyle(fontSize: 24,
                    color: TColors.white, fontWeight: FontWeight.w800)),
          ]),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(lang.s('= in XP', '= XP ውስጥ'),
                style: TextStyle(fontSize: 11,
                    color: TColors.white.withOpacity(0.5))),
            Text('${coins * 100} XP',
                style: TextStyle(fontSize: 14, color: TColors.teal300,
                    fontWeight: FontWeight.w700)),
          ]),
        ]),
      ),
    ),
  );
}

class _RewardSection extends StatelessWidget {
  final String titleEn, titleAm;
  final List<TsegaReward> rewards;
  final int coins, currentLevel;
  final LanguageProvider lang;
  final Function(TsegaReward) onRedeem;
  final bool comingSoon;

  const _RewardSection({
    required this.titleEn, required this.titleAm,
    required this.rewards, required this.coins,
    required this.currentLevel, required this.lang,
    required this.onRedeem, this.comingSoon = false,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(2, 16, 0, 10),
        child: Row(children: [
          Text(lang.isAmharic ? titleAm : titleEn,
              style: TextStyle(fontSize: 12,
                  color: TColors.white.withOpacity(0.5),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5)),
          if (comingSoon) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: TColors.statusYellow.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6)),
              child: Text(lang.s('Coming soon', 'ቶሎ ይመጣል'),
                  style: const TextStyle(fontSize: 9,
                      color: TColors.statusYellow,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ]),
      ),
      ...rewards.map((r) {
        final locked = currentLevel < r.minLevel;
        final affordable = coins >= r.cost;
        return _RewardCard(
          reward: r, locked: locked, affordable: affordable,
          lang: lang,
          onTap: locked || !r.available
              ? null
              : () => onRedeem(r),
        );
      }),
    ],
  );
}

class _RewardCard extends StatelessWidget {
  final TsegaReward reward;
  final bool locked, affordable;
  final LanguageProvider lang;
  final VoidCallback? onTap;

  const _RewardCard({required this.reward, required this.locked,
      required this.affordable, required this.lang, this.onTap});

  @override
  Widget build(BuildContext context) {
    final dimmed = locked || !reward.available;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: dimmed
                  ? TColors.white.withOpacity(0.03)
                  : TColors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: dimmed
                    ? TColors.white.withOpacity(0.06)
                    : reward.color.withOpacity(0.3))),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: dimmed
                      ? TColors.white.withOpacity(0.05)
                      : reward.color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12)),
                child: Icon(reward.icon,
                    color: dimmed
                        ? TColors.white.withOpacity(0.2)
                        : reward.color,
                    size: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lang.isAmharic ? reward.titleAm : reward.titleEn,
                      style: TextStyle(fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: dimmed
                              ? TColors.white.withOpacity(0.3)
                              : TColors.white)),
                  const SizedBox(height: 3),
                  Text(lang.isAmharic ? reward.descAm : reward.descEn,
                      style: TextStyle(fontSize: 11, height: 1.4,
                          color: dimmed
                              ? TColors.white.withOpacity(0.2)
                              : TColors.white.withOpacity(0.55))),
                ],
              )),
              const SizedBox(width: 8),
              // Cost badge + status
              Column(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: dimmed
                        ? TColors.white.withOpacity(0.06)
                        : affordable
                            ? reward.color.withOpacity(0.2)
                            : TColors.red400.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8)),
                  child: Text('${reward.cost} TC',
                      style: TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: dimmed
                              ? TColors.white.withOpacity(0.2)
                              : affordable
                                  ? reward.color
                                  : TColors.red400))),
                if (locked) ...[
                  const SizedBox(height: 4),
                  Icon(Icons.lock_rounded,
                      color: TColors.white.withOpacity(0.2), size: 14),
                ],
                if (!locked && !reward.available) ...[
                  const SizedBox(height: 4),
                  Text(lang.s('Soon', 'ቶሎ'),
                      style: TextStyle(fontSize: 9,
                          color: TColors.statusYellow.withOpacity(0.6))),
                ],
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

class _RedeemConfirmSheet extends StatelessWidget {
  final TsegaReward reward;
  final XpProvider xp;
  final LanguageProvider lang;
  const _RedeemConfirmSheet({
      required this.reward, required this.xp, required this.lang});

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Color(0xFF0E1320),
      borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    padding: const EdgeInsets.all(28),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 40, height: 4,
          decoration: BoxDecoration(
              color: TColors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2))),
      const SizedBox(height: 24),
      Container(
        width: 64, height: 64,
        decoration: BoxDecoration(
          color: reward.color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(18)),
        child: Icon(reward.icon, color: reward.color, size: 32)),
      const SizedBox(height: 16),
      Text(lang.isAmharic ? reward.titleAm : reward.titleEn,
          style: const TextStyle(fontSize: 20,
              color: TColors.white, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center),
      const SizedBox(height: 8),
      Text(lang.isAmharic ? reward.descAm : reward.descEn,
          style: TextStyle(fontSize: 13,
              color: TColors.white.withOpacity(0.6), height: 1.5),
          textAlign: TextAlign.center),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TColors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(lang.s('Cost: ', 'ዋጋ: '),
                style: TextStyle(color: TColors.white.withOpacity(0.5))),
            Text('${reward.cost} TC',
                style: const TextStyle(fontSize: 18,
                    color: TColors.white, fontWeight: FontWeight.w800)),
            Text(lang.s(' · Balance after: ', ' · ቀሪ: '),
                style: TextStyle(color: TColors.white.withOpacity(0.5))),
            Text('${xp.coins - reward.cost} TC',
                style: TextStyle(fontSize: 16,
                    color: xp.coins - reward.cost >= 0
                        ? TColors.teal300 : TColors.red400,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: TColors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(lang.s('Cancel', 'ሰርዝ'),
                style: const TextStyle(color: TColors.white)))),
        )),
        const SizedBox(width: 12),
        Expanded(child: GestureDetector(
          onTap: () {
            xp.redeem(reward);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(lang.s('Redeemed! ✓',
                  'ተጠቅሟል! ✓')),
              backgroundColor: TColors.teal500,
            ));
          },
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: reward.color,
              borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(lang.s('Redeem Now', 'አሁን ውጤምም'),
                style: const TextStyle(color: TColors.white,
                    fontWeight: FontWeight.w700)))),
        )),
      ]),
      const SizedBox(height: 8),
    ]),
  );
}

// ─── HISTORY TAB ─────────────────────────────────────────────────
class _HistoryTab extends StatelessWidget {
  final LanguageProvider lang;
  final XpProvider xp;
  const _HistoryTab({required this.lang, required this.xp});

  @override
  Widget build(BuildContext context) {
    if (xp.history.isEmpty) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded,
              color: TColors.white.withOpacity(0.2), size: 56),
          const SizedBox(height: 12),
          Text(lang.s('No activity yet', 'እስካሁን ምንም እንቅስቃሴ የለም'),
              style: TextStyle(color: TColors.white.withOpacity(0.3))),
        ],
      ));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: xp.history.length,
      itemBuilder: (_, i) {
        final e = xp.history[i];
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: TColors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: TColors.white.withOpacity(0.07))),
              child: Row(children: [
                Text(lang.isAmharic
                    ? e.event.labelAm()
                    : e.event.labelEn(),
                    style: const TextStyle(
                        fontSize: 13, color: TColors.white)),
                const Spacer(),
                Text('+${e.amount} XP',
                    style: const TextStyle(
                        fontSize: 13, color: TColors.teal300,
                        fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        );
      },
    );
  }
}

// ─── BACKGROUND ──────────────────────────────────────────────────
class _Background extends StatelessWidget {
  final Animation<double> anim;
  const _Background({required this.anim});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: anim,
    builder: (_, __) => Stack(children: [
      Container(color: const Color(0xFF0A1628)),
      Positioned(top: -80 + anim.value * 20, right: -60,
          child: _Orb(size: 250, color: TColors.teal500.withOpacity(0.12))),
      Positioned(top: 250 - anim.value * 15, left: -80,
          child: _Orb(size: 200, color: TColors.pink500.withOpacity(0.08))),
    ]),
  );
}

class _Orb extends StatelessWidget {
  final double size; final Color color;
  const _Orb({required this.size, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color,
            blurRadius: size, spreadRadius: size * 0.3)]));
}

// ─── GLASS BUTTON ────────────────────────────────────────────────
class _GlassBtn extends StatelessWidget {
  final IconData icon;
  const _GlassBtn({required this.icon});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: TColors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: TColors.white.withOpacity(0.15))),
        child: Icon(icon, color: TColors.white, size: 18))));
}
