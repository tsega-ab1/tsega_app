import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/stage_provider.dart';
import '../../models/lab_row.dart';
import '../../widgets/common/tsega_app_bar.dart';
import '../../overlays/lab_entry_overlay.dart';
import '../../overlays/ai_risk_overlay.dart';
import '../wearables/wearables_screen.dart';

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
    LabRow('Mar 10, 2026', 'ማርች 10, 2026', 11.8, 118, 76, 95.0, 62.0, 'green'),
    LabRow('Feb 20, 2026', 'የካቲት 20, 2026', 10.4, 132, 84, 102.0, 63.5, 'yellow'),
    LabRow('Jan 15, 2026', 'ጥር 15, 2026', 9.1, 145, 92, 115.0, 61.0, 'red'),
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
                _RiskSummaryCard(latest: _results.first),
                const SizedBox(height: 16),
                    
                // ─── WEARABLES CARD ──────────────────────────────────
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const WearablesScreen())),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(
                        color: TColors.teal700.withOpacity(0.06),
                        blurRadius: 12, offset: const Offset(0, 3))],
                    ),
                    child: Row(children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: TColors.blue50,
                          borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.watch_rounded,
                            color: TColors.blue500, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lang.s('Wearables', 'ተለባሽ መሳሪያዎች'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14, color: TColors.dark)),
                          const SizedBox(height: 4),
                          Text(lang.s('Connect your health devices',
                              'የጤና መሳሪያዎን ያገናኙ'),
                              style: const TextStyle(
                                  fontSize: 12, color: TColors.gray)),
                        ],
                      )),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          color: TColors.gray, size: 14),
                    ]),
                  ),
                ),

                const SizedBox(height: 16),
                if (stage.isPregnancyMode) ...[
                  _AncCard(),
                  const SizedBox(height: 16),
                ],
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
            _LabTab(results: _results, onAdd: () => _showAdd(context)),
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

class _RiskSummaryCard extends StatelessWidget {
  final LabRow latest;
  const _RiskSummaryCard({required this.latest});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final Color color;
    final Color bgColor;
    final String labelEn, labelAm;
    final IconData icon;
    if (latest.risk == 'red') {
      color = TColors.statusRed; bgColor = TColors.red100;
      labelEn = 'High Risk — Act Now'; labelAm = 'ከፍተኛ ስጋት — አሁን ይሂዱ';
      icon = Icons.warning_rounded;
    } else if (latest.risk == 'yellow') {
      color = TColors.statusYellow; bgColor = const Color(0xFFFFF8E1);
      labelEn = 'Moderate Risk'; labelAm = 'መካከለኛ ስጋት';
      icon = Icons.info_rounded;
    } else {
      color = TColors.statusGreen; bgColor = TColors.green100;
      labelEn = 'Low Risk'; labelAm = 'ዝቅተኛ ስጋት';
      icon = Icons.check_circle_rounded;
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4))),
      child: Row(children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(lang.s('Latest Assessment', 'የቅርቡ ምዘና'),
              style: const TextStyle(fontSize: 12, color: TColors.gray)),
          Text(lang.isAmharic ? labelAm : labelEn,
              style: TextStyle(fontSize: 16,
                  fontWeight: FontWeight.w700, color: color)),
          Text(lang.s('Based on ${latest.dateEn}', 'ከ${latest.dateAm} ላይ'),
              style: const TextStyle(fontSize: 12, color: TColors.gray)),
        ])),
        GestureDetector(
          onTap: () => showModalBottomSheet(
              context: context, isScrollControlled: true,
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
        const Icon(Icons.calendar_today_rounded, color: TColors.white, size: 28),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(lang.s('Next ANC Visit', 'ቀጣይ ANC ጉብኝት'),
              style: const TextStyle(fontSize: 13,
                  color: TColors.white, fontWeight: FontWeight.w600)),
          Text(lang.s('March 25, 2026 • Week 28', 'ማርች 25, 2026 • ሳምንት 28'),
              style: TextStyle(fontSize: 12,
                  color: TColors.white.withOpacity(0.85))),
        ])),
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

class _LabTab extends StatelessWidget {
  final List<LabRow> results;
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
              border: Border.all(color: TColors.teal300, width: 1.5)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.add_circle_outline_rounded,
                  color: TColors.teal500, size: 22),
              const SizedBox(width: 8),
              Text(lang.addResult,
                  style: const TextStyle(color: TColors.teal500,
                      fontWeight: FontWeight.w700, fontSize: 14)),
            ]),
          ),
        ),
      ],
    );
  }
}

class _LabCard extends StatelessWidget {
  final LabRow r;
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
        color: TColors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: TColors.teal700.withOpacity(0.06),
          blurRadius: 10, offset: const Offset(0, 3))]),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: riskBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(lang.isAmharic ? r.dateAm : r.dateEn,
                style: const TextStyle(fontWeight: FontWeight.w600,
                    color: TColors.dark, fontSize: 14)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: riskColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(r.risk == 'red' ? Icons.warning_rounded
                    : r.risk == 'yellow' ? Icons.info_rounded
                    : Icons.check_circle_rounded,
                    color: riskColor, size: 14),
                const SizedBox(width: 4),
                Text(r.risk == 'red' ? lang.s('High Risk', 'ከፍተኛ ስጋት')
                    : r.risk == 'yellow' ? lang.s('Moderate', 'መካከለኛ')
                    : lang.s('Normal', 'ተለምዶ'),
                    style: TextStyle(color: riskColor, fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ]),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            _Met(lang.s('Hb', 'Hb'), '${r.hb} g/dL',
                r.hb < 11 ? TColors.red400 : TColors.green500),
            _Met(lang.s('BP', 'ደም ግ.'), '${r.sys}/${r.dia}',
                r.sys > 140 ? TColors.red400 : TColors.green500),
            _Met(lang.s('Sugar', 'ስኳር'), '${r.sugar.toInt()} mg',
                r.sugar > 110 ? TColors.statusYellow : TColors.green500),
            _Met(lang.s('Weight', 'ክ.ብ.'), '${r.weight} kg', TColors.teal500),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: GestureDetector(
            onTap: () => showModalBottomSheet(
                context: context, isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AiRiskOverlay(result: r)),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: TGradients.gradTeal,
                borderRadius: BorderRadius.circular(10)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.psychology_rounded,
                    color: TColors.white, size: 16),
                const SizedBox(width: 8),
                Text(lang.s('View AI Assessment', 'AI ምዘና ይመልከቱ'),
                    style: const TextStyle(color: TColors.white,
                        fontWeight: FontWeight.w700, fontSize: 13)),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Met extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Met(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(label, style: const TextStyle(fontSize: 10, color: TColors.gray)),
    const SizedBox(height: 3),
    Text(value, style: TextStyle(fontSize: 13,
        fontWeight: FontWeight.w700, color: color)),
  ]));
}

class _AppointmentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final appts = [
      ('Mar 25, 2026', 'ማርች 25, 2026',
       'ANC Visit — Week 28', 'ANC ጉብኝት — ሳምንት 28',
       'St. Paul\'s Hospital', 'ቅዱስ ጳውሎስ ሆስፒታል', true, TColors.teal500),
      ('Apr 10, 2026', 'ኤፕሪል 10, 2026',
       'Blood Test & Ultrasound', 'የደም ምርምር እና አልትራሳውንድ',
       'Tikur Anbessa Hospital', 'ጥቁር አንበሳ ሆስፒታል', false, TColors.blue500),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: appts.map((a) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TColors.white, borderRadius: BorderRadius.circular(16),
          border: a.$7 ? Border.all(color: TColors.teal300, width: 1.5) : null,
          boxShadow: [BoxShadow(color: TColors.teal700.withOpacity(0.06),
            blurRadius: 10, offset: const Offset(0, 3))]),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: a.$8.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.event_rounded, color: a.$8, size: 24)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(lang.isAmharic ? a.$4 : a.$3,
                style: const TextStyle(fontWeight: FontWeight.w700,
                    color: TColors.dark, fontSize: 14)),
            Text(lang.isAmharic ? a.$6 : a.$5,
                style: const TextStyle(fontSize: 12, color: TColors.gray)),
            const SizedBox(height: 3),
            Text(lang.isAmharic ? a.$2 : a.$1,
                style: const TextStyle(fontSize: 12, color: TColors.gray)),
          ])),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: TColors.gray, size: 14),
        ]),
      )).toList(),
    );
  }
}
