import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/stage_provider.dart';
import '../../widgets/common/tsega_app_bar.dart';
import '../../overlays/lab_entry_overlay.dart';
import '../../overlays/ai_risk_overlay.dart';

class HealthScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const HealthScreen({super.key, required this.scaffoldKey});
  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  final _results = [
    _LabRow('Mar 10, 2026', 'ማርች 10, 2026', 11.8, 118, 76, 95.0, 62.0, 'green'),
    _LabRow('Feb 20, 2026', 'የካቲት 20, 2026', 10.4, 132, 84, 102.0, 63.5, 'yellow'),
    _LabRow('Jan 15, 2026', 'ጥር 15, 2026', 9.1, 145, 92, 115.0, 61.0, 'red'),
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final stage = context.watch<StageProvider>();

    return Scaffold(
      backgroundColor: TColors.cream,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverToBoxAdapter(
              child: TsegaAppBar(scaffoldKey: widget.scaffoldKey)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(lang.medicalRecords, style: TTextStyles.headlineLarge),
                const SizedBox(height: 16),
                // Risk summary card
                _RiskSummaryCard(latest: _results.first),
                const SizedBox(height: 16),
                // ANC appointment card (pregnancy only)
                if (stage.isPregnancyMode) ...[
                  _AncCard(),
                  const SizedBox(height: 16),
                ],
                // Tab bar
                Container(
                  decoration: BoxDecoration(
                    color: TColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TColors.border)),
                  child: TabBar(
                    controller: _tab,
                    indicator: BoxDecoration(
                      gradient: TGradients.gradTeal,
                      borderRadius: BorderRadius.circular(10)),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: TColors.white,
                    unselectedLabelColor: TColors.gray,
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13),
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(text: lang.s('Lab Results', 'የላብ ውጤቶች')),
                      Tab(text: lang.s('Appointments', 'ቀጠሮዎች')),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ]),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tab,
          children: [
            _LabTab(results: _results,
                onAdd: () => _showAdd(context)),
            _AppointmentsTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAdd(context),
        backgroundColor: TColors.teal500,
        icon: const Icon(Icons.add_rounded, color: TColors.white),
        label: Text(lang.addResult,
            style: const TextStyle(color: TColors.white,
                fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _showAdd(BuildContext ctx) => showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LabEntryOverlay(
        onSave: (r) => setState(() => _results.insert(0, r)),
      ));
}

// ─── RISK SUMMARY CARD ───────────────────────────────────────────
class _RiskSummaryCard extends StatelessWidget {
  final _LabRow latest;
  const _RiskSummaryCard({required this.latest});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final (color, bgColor, label, labelAm, icon) = switch (latest.risk) {
      'red'    => (TColors.statusRed,    TColors.red100,   'High Risk — Act Now',   'ከፍተኛ ስጋት — አሁን ይሂዱ', Icons.warning_rounded),
      'yellow' => (TColors.statusYellow, const Color(0xFFFFF8E1), 'Moderate Risk',  'መካከለኛ ስጋት', Icons.info_rounded),
      _        => (TColors.statusGreen,  TColors.green100, 'Low Risk',              'ዝቅተኛ ስጋት', Icons.check_circle_rounded),
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4))),
      child: Row(children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.s('Latest Assessment', 'የቅርቡ ምዘና'),
                style: const TextStyle(fontSize: 12, color: TColors.gray)),
            Text(lang.isAmharic ? labelAm : label,
                style: TextStyle(fontSize: 16,
                    fontWeight: FontWeight.w700, color: color)),
            Text(lang.s('Based on ${latest.dateEn}',
                'ከ${latest.dateAm} ላይ'),
                style: const TextStyle(fontSize: 12, color: TColors.gray)),
          ],
        )),
        GestureDetector(
          onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => AiRiskOverlay(result: latest)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10)),
            child: Text(lang.s('Details', 'ዝርዝሮች'),
                style: TextStyle(color: color,
                    fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ),
      ]),
    );
  }
}

// ─── ANC CARD ────────────────────────────────────────────────────
class _AncCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: TGradients.gradBlue,
        borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        const Icon(Icons.calendar_today_rounded,
            color: TColors.white, size: 28),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.s('Next ANC Visit', 'ቀጣይ ANC ጉብኝት'),
                style: const TextStyle(fontSize: 13,
                    color: TColors.white, fontWeight: FontWeight.w600)),
            Text(lang.s('March 25, 2026 • Week 28',
                'ማርች 25, 2026 • ሳምንት 28'),
                style: TextStyle(fontSize: 12,
                    color: TColors.white.withOpacity(0.85))),
          ],
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: TColors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10)),
          child: Text(lang.s('Remind Me', 'አስታውሰኝ'),
              style: const TextStyle(color: TColors.white,
                  fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

// ─── LAB TAB ─────────────────────────────────────────────────────
class _LabTab extends StatelessWidget {
  final List<_LabRow> results;
  final VoidCallback onAdd;
  const _LabTab({required this.results, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        ...results.map((r) => _LabCard(r: r)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: TColors.teal300, width: 1.5),
              boxShadow: [BoxShadow(
                color: TColors.teal700.withOpacity(0.04),
                blurRadius: 8, offset: const Offset(0, 2))]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_circle_outline_rounded,
                    color: TColors.teal500, size: 22),
                const SizedBox(width: 8),
                Text(lang.addResult, style: const TextStyle(
                    color: TColors.teal500,
                    fontWeight: FontWeight.w700, fontSize: 14)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LabCard extends StatelessWidget {
  final _LabRow r;
  const _LabCard({required this.r});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final riskColor = r.risk == 'red' ? TColors.statusRed
        : r.risk == 'yellow' ? TColors.statusYellow : TColors.statusGreen;
    final riskBg = r.risk == 'red' ? TColors.red100
        : r.risk == 'yellow' ? const Color(0xFFFFF8E1) : TColors.green100;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
          color: TColors.teal700.withOpacity(0.06),
          blurRadius: 10, offset: const Offset(0, 3))]),
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: riskBg,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(lang.isAmharic ? r.dateAm : r.dateEn,
                  style: const TextStyle(fontWeight: FontWeight.w600,
                      color: TColors.dark, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(r.risk == 'red' ? Icons.warning_rounded
                      : r.risk == 'yellow' ? Icons.info_rounded
                      : Icons.check_circle_rounded,
                      color: riskColor, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    r.risk == 'red'
                        ? lang.s('High Risk', 'ከፍተኛ ስጋት')
                        : r.risk == 'yellow'
                        ? lang.s('Moderate', 'መካከለኛ')
                        : lang.s('Normal', 'ተለምዶ'),
                    style: TextStyle(color: riskColor, fontSize: 12,
                        fontWeight: FontWeight.w700)),
                ]),
              ),
            ],
          ),
        ),
        // Metrics grid
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            _Metric(lang.s('Hb', 'Hb'),
                '${r.hb} g/dL', r.hb < 11 ? TColors.red400 : TColors.green500),
            _Metric(lang.s('BP', 'ደም ግ.'),
                '${r.sys}/${r.dia}', r.sys > 140 ? TColors.red400 : TColors.green500),
            _Metric(lang.s('Sugar', 'ስኳር'),
                '${r.sugar.toInt()} mg', r.sugar > 110 ? TColors.statusYellow : TColors.green500),
            _Metric(lang.s('Weight', 'ክ.ብ.'),
                '${r.weight} kg', TColors.teal500),
          ]),
        ),
        // Share button
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: GestureDetector(
            onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AiRiskOverlay(result: r)),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: TGradients.gradTeal,
                borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.psychology_rounded,
                      color: TColors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(lang.s('View AI Assessment', 'AI ምዘና ይመልከቱ'),
                      style: const TextStyle(color: TColors.white,
                          fontWeight: FontWeight.w700, fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Metric(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Text(label, style: const TextStyle(
          fontSize: 10, color: TColors.gray)),
      const SizedBox(height: 3),
      Text(value, style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w700, color: color)),
    ]),
  );
}

// ─── APPOINTMENTS TAB ────────────────────────────────────────────
class _AppointmentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final appts = [
      ('Mar 25, 2026', 'ማርች 25, 2026',
       'ANC Visit — Week 28', 'ANC ጉብኝት — ሳምንት 28',
       'St. Paul\'s Hospital', 'ቅዱስ ጳውሎስ ሆስፒታል',
       true, TColors.teal500),
      ('Apr 10, 2026', 'ኤፕሪል 10, 2026',
       'Blood Test & Ultrasound', 'የደም ምርምር እና አልትራሳውንድ',
       'Tikur Anbessa Hospital', 'ጥቁር አንበሳ ሆስፒታል',
       false, TColors.blue500),
      ('Apr 30, 2026', 'ኤፕሪል 30, 2026',
       'ANC Visit — Week 36', 'ANC ጉብኝት — ሳምንት 36',
       'Health Center', 'ጤና ጣቢያ',
       false, TColors.teal500),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: appts.map((a) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(16),
          border: a.$7 ? Border.all(color: TColors.teal300, width: 1.5) : null,
          boxShadow: [BoxShadow(
            color: TColors.teal700.withOpacity(0.06),
            blurRadius: 10, offset: const Offset(0, 3))]),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: a.$8.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.event_rounded, color: a.$8, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (a.$7)
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: TColors.teal100,
                    borderRadius: BorderRadius.circular(6)),
                  child: Text(lang.s('Upcoming', 'ቀጣይ'),
                      style: const TextStyle(fontSize: 10,
                          color: TColors.teal700,
                          fontWeight: FontWeight.w600)),
                ),
              Text(lang.isAmharic ? a.$4 : a.$3,
                  style: const TextStyle(fontWeight: FontWeight.w700,
                      color: TColors.dark, fontSize: 14)),
              Text(lang.isAmharic ? a.$6 : a.$5,
                  style: const TextStyle(fontSize: 12, color: TColors.gray)),
              const SizedBox(height: 3),
              Row(children: [
                const Icon(Icons.schedule_rounded,
                    color: TColors.gray, size: 12),
                const SizedBox(width: 4),
                Text(lang.isAmharic ? a.$2 : a.$1,
                    style: const TextStyle(
                        fontSize: 12, color: TColors.gray)),
              ]),
            ],
          )),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: TColors.gray, size: 14),
        ]),
      )).toList(),
    );
  }
}

// ─── DATA MODEL ──────────────────────────────────────────────────
class _LabRow {
  final String dateEn, dateAm, risk;
  final double hb, sugar, weight;
  final int sys, dia;
  _LabRow(this.dateEn, this.dateAm, this.hb, this.sys, this.dia,
      this.sugar, this.weight, this.risk);
}
