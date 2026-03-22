import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/xp_provider.dart';
import '../../models/gamification_model.dart';

class WearablesScreen extends StatefulWidget {
  const WearablesScreen({super.key});
  @override
  State<WearablesScreen> createState() => _WearablesScreenState();
}

class _WearablesScreenState extends State<WearablesScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _fade;
  late Animation<double> _pulse;

  // Simulated connected state (replace with real platform_health calls)
  WearableSource? _connected;
  HealthSnapshot? _lastSnapshot;
  bool _syncing = false;

  // Manual entry controllers
  final _stepsCtrl   = TextEditingController();
  final _hrCtrl      = TextEditingController();
  final _spo2Ctrl    = TextEditingController();
  final _sleepCtrl   = TextEditingController();
  final _weightCtrl  = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _fade  = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _pulse = Tween<double>(begin: 0.9, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose(); _pulseCtrl.dispose();
    _stepsCtrl.dispose(); _hrCtrl.dispose();
    _spo2Ctrl.dispose(); _sleepCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _connectSource(WearableSource source) async {
    setState(() => _syncing = true);
    await Future.delayed(const Duration(seconds: 2));
    // In real app: use health_connect (Android) or health (iOS) package
    setState(() {
      _connected = source;
      _syncing = false;
      _lastSnapshot = HealthSnapshot(
        timestamp: DateTime.now(),
        source: source,
        steps: 4820,
        heartRate: 74,
        spo2: 96.5,
        sleepHours: 7.2,
        weight: 62.4,
        activeMinutes: 28,
      );
    });
    if (!mounted) return;
    context.read<XpProvider>().addXp(XpEvent.wearableSynced);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(context.read<LanguageProvider>().s(
          '${source.nameEn} connected! +${XpEvent.wearableSynced.xp} XP',
          '${source.nameAm} ተሳስሯል! +${XpEvent.wearableSynced.xp} XP')),
      backgroundColor: TColors.teal500,
    ));
  }

  void _saveManual() {
    final snapshot = HealthSnapshot(
      timestamp: DateTime.now(),
      source: WearableSource.manual,
      steps:   int.tryParse(_stepsCtrl.text),
      heartRate: int.tryParse(_hrCtrl.text),
      spo2:    double.tryParse(_spo2Ctrl.text),
      sleepHours: double.tryParse(_sleepCtrl.text),
      weight:  double.tryParse(_weightCtrl.text),
    );
    setState(() {
      _connected = WearableSource.manual;
      _lastSnapshot = snapshot;
    });
    context.read<XpProvider>().addXp(XpEvent.wearableSynced);
    Navigator.pop(context); // close manual sheet
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final isAndroid = true; // replace with Platform.isAndroid

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: FadeTransition(
        opacity: _fade,
        child: Stack(children: [
          // Background
          _BG(pulse: _pulse),

          SafeArea(child: CustomScrollView(slivers: [
            // App bar
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: _GBtn(icon: Icons.arrow_back_ios_rounded)),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lang.s('Health Connect', 'ጤና ግንኙነት'),
                        style: const TextStyle(fontSize: 20,
                            color: TColors.white, fontWeight: FontWeight.w700)),
                    Text(lang.s(
                        'Sync health data from your device',
                        'ከመሣሪያዎ የጤና ዳታ ያሳምሩ'),
                        style: TextStyle(fontSize: 12,
                            color: TColors.white.withOpacity(0.5))),
                  ],
                )),
              ]),
            )),

            // Live metrics card (if connected)
            if (_lastSnapshot != null)
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _LiveMetricsCard(
                  snapshot: _lastSnapshot!, lang: lang),
              )),

            // Connection cards
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lang.s('Connect a source', 'ምንጭ ያገናኙ'),
                      style: TextStyle(fontSize: 12,
                          color: TColors.white.withOpacity(0.5),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 12),

                  // Android sources
                  if (isAndroid) ...[
                    _SourceCard(
                      source: WearableSource.googleFit,
                      connected: _connected == WearableSource.googleFit,
                      syncing: _syncing &&
                          _connected == null,
                      lang: lang,
                      onConnect: () => _connectSource(WearableSource.googleFit),
                      onDisconnect: () =>
                          setState(() => _connected = null),
                      availabilityNote: lang.s(
                          'Reads steps, heart rate, sleep, weight from Google Fit or Health Connect',
                          'ከጉግል ፊት ወይም ጤና ግንኙነት እርምጃዎችን፣ ልብ ምቶችን፣ እንቅልፍን ያነባል'),
                    ),
                    const SizedBox(height: 10),
                    _SourceCard(
                      source: WearableSource.samsungHealth,
                      connected: _connected == WearableSource.samsungHealth,
                      syncing: false,
                      lang: lang,
                      onConnect: () =>
                          _connectSource(WearableSource.samsungHealth),
                      onDisconnect: () =>
                          setState(() => _connected = null),
                      availabilityNote: lang.s(
                          'Samsung Galaxy watch and phone sensors',
                          'ሳምሱንግ ጋላክሲ ሰዓት እና ስልክ ሴንሰሮች'),
                    ),
                  ] else ...[
                    // iOS source
                    _SourceCard(
                      source: WearableSource.appleHealth,
                      connected: _connected == WearableSource.appleHealth,
                      syncing: false,
                      lang: lang,
                      onConnect: () =>
                          _connectSource(WearableSource.appleHealth),
                      onDisconnect: () =>
                          setState(() => _connected = null),
                      availabilityNote: lang.s(
                          'Reads all health metrics from Apple Health app',
                          'ከአፕል ጤና መተግበሪያ ሁሉንም የጤና መለኪያዎች ያነባል'),
                    ),
                  ],
                  const SizedBox(height: 10),
                  _SourceCard(
                    source: WearableSource.fitbit,
                    connected: _connected == WearableSource.fitbit,
                    syncing: false, lang: lang,
                    onConnect: () => _connectSource(WearableSource.fitbit),
                    onDisconnect: () => setState(() => _connected = null),
                    availabilityNote: lang.s(
                        'Fitbit wristbands and smartwatches',
                        'ፊትቢት የእጅ አምባር እና ስማርት ሰዓቶች'),
                    comingSoon: true,
                  ),
                  const SizedBox(height: 10),
                  _SourceCard(
                    source: WearableSource.garmin,
                    connected: _connected == WearableSource.garmin,
                    syncing: false, lang: lang,
                    onConnect: () => _connectSource(WearableSource.garmin),
                    onDisconnect: () => setState(() => _connected = null),
                    availabilityNote: lang.s(
                        'Garmin GPS watches and fitness trackers',
                        'ጋርሚን GPS ሰዓቶች እና ፊትነስ ትራከሮች'),
                    comingSoon: true,
                  ),
                  const SizedBox(height: 10),

                  // Manual entry always available
                  _ManualEntryCard(lang: lang,
                      onTap: () => _showManualSheet(context, lang)),

                  const SizedBox(height: 20),

                  // What we track section
                  _WhatWeTrackCard(lang: lang),
                  const SizedBox(height: 80),
                ],
              ),
            )),
          ])),
        ]),
      ),
    );
  }

  void _showManualSheet(BuildContext context, LanguageProvider lang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ManualEntrySheet(
        lang: lang,
        stepsCtrl: _stepsCtrl, hrCtrl: _hrCtrl,
        spo2Ctrl: _spo2Ctrl, sleepCtrl: _sleepCtrl,
        weightCtrl: _weightCtrl,
        onSave: _saveManual,
      ),
    );
  }
}

// ─── LIVE METRICS CARD ───────────────────────────────────────────
class _LiveMetricsCard extends StatelessWidget {
  final HealthSnapshot snapshot;
  final LanguageProvider lang;
  const _LiveMetricsCard({required this.snapshot, required this.lang});

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _Metric(Icons.directions_walk_rounded,
          '${snapshot.steps ?? '--'}',
          lang.s('Steps', 'እርምጃዎች'),
          TColors.teal500,
          snapshot.stepsGoalMet),
      _Metric(Icons.favorite_rounded,
          '${snapshot.heartRate ?? '--'} bpm',
          lang.s('Heart Rate', 'ልብ ምት'),
          TColors.pink500, false),
      _Metric(Icons.air_rounded,
          '${snapshot.spo2?.toStringAsFixed(1) ?? '--'}%',
          lang.s('SpO₂', 'SpO₂'),
          snapshot.hasSpO2Alert ? TColors.red400 : TColors.blue500,
          !snapshot.hasSpO2Alert),
      _Metric(Icons.bedtime_rounded,
          '${snapshot.sleepHours?.toStringAsFixed(1) ?? '--'}h',
          lang.s('Sleep', 'እንቅልፍ'),
          const Color(0xFF7C4DFF), (snapshot.sleepHours ?? 0) >= 7),
      _Metric(Icons.monitor_weight_rounded,
          '${snapshot.weight?.toStringAsFixed(1) ?? '--'} kg',
          lang.s('Weight', 'ክብደት'),
          TColors.green500, false),
      _Metric(Icons.timer_rounded,
          '${snapshot.activeMinutes ?? '--'} min',
          lang.s('Active', 'ንቁ'), TColors.statusYellow, false),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              TColors.teal700.withOpacity(0.2),
              TColors.blue700.withOpacity(0.15),
            ]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: TColors.teal400.withOpacity(0.3))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: TColors.green500, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(lang.s('Live from ${snapshot.source.nameEn}',
                    'ከ${snapshot.source.nameAm} ቀጥታ'),
                    style: TextStyle(fontSize: 12,
                        color: TColors.teal300,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(_timeAgo(snapshot.timestamp, lang),
                    style: TextStyle(fontSize: 11,
                        color: TColors.white.withOpacity(0.4))),
              ]),
              const SizedBox(height: 14),
              // Alert for SpO2
              if (snapshot.hasSpO2Alert)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: TColors.red400.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: TColors.red400.withOpacity(0.3))),
                  child: Row(children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: TColors.red400, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(
                      lang.isAmharic
                          ? snapshot.spO2StatusAm
                          : snapshot.spO2Status,
                      style: const TextStyle(fontSize: 12,
                          color: TColors.red400))),
                  ]),
                ),
              // Metrics grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3, crossAxisSpacing: 8,
                mainAxisSpacing: 8, childAspectRatio: 1.1,
                children: metrics.map((m) => _MetricTile(m: m)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime t, LanguageProvider lang) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return lang.s('Just now', 'አሁን');
    if (diff.inMinutes < 60) return lang.s(
        '${diff.inMinutes}m ago', 'ከ${diff.inMinutes} ደቂቃ');
    return lang.s('${diff.inHours}h ago', 'ከ${diff.inHours} ሰዓት');
  }
}

class _Metric {
  final IconData icon;
  final String value, label;
  final Color color;
  final bool good;
  _Metric(this.icon, this.value, this.label, this.color, this.good);
}

class _MetricTile extends StatelessWidget {
  final _Metric m;
  const _MetricTile({required this.m});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: m.color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: m.color.withOpacity(0.2))),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(m.icon, color: m.color, size: 18),
        const SizedBox(height: 4),
        Text(m.value, style: TextStyle(fontSize: 13,
            color: m.color, fontWeight: FontWeight.w800)),
        Text(m.label, style: TextStyle(fontSize: 9,
            color: TColors.white.withOpacity(0.5))),
        if (m.good) const Icon(Icons.check_circle_rounded,
            color: TColors.green500, size: 12),
      ],
    ),
  );
}

// ─── SOURCE CARD ─────────────────────────────────────────────────
class _SourceCard extends StatelessWidget {
  final WearableSource source;
  final bool connected, syncing, comingSoon;
  final LanguageProvider lang;
  final VoidCallback onConnect, onDisconnect;
  final String availabilityNote;

  const _SourceCard({
    required this.source, required this.connected,
    required this.syncing, required this.lang,
    required this.onConnect, required this.onDisconnect,
    required this.availabilityNote, this.comingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    final col = source.brandColor;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: connected
                ? col.withOpacity(0.12)
                : TColors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: connected
                  ? col.withOpacity(0.4)
                  : TColors.white.withOpacity(0.08))),
          child: Row(children: [
            // Brand icon placeholder (colored circle with initial)
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: col.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(
                source.nameEn[0],
                style: TextStyle(fontSize: 22,
                    fontWeight: FontWeight.w800, color: col))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(lang.isAmharic
                      ? source.nameAm : source.nameEn,
                      style: TextStyle(fontSize: 15,
                          color: comingSoon
                              ? TColors.white.withOpacity(0.3)
                              : TColors.white,
                          fontWeight: FontWeight.w700)),
                  if (connected) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: TColors.green500.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6)),
                      child: Text(lang.s('Connected', 'ተሳስሯል'),
                          style: const TextStyle(fontSize: 10,
                              color: TColors.green500,
                              fontWeight: FontWeight.w700))),
                  ],
                  if (comingSoon) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: TColors.statusYellow.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6)),
                      child: Text(lang.s('Soon', 'ቶሎ'),
                          style: const TextStyle(fontSize: 10,
                              color: TColors.statusYellow,
                              fontWeight: FontWeight.w700))),
                  ],
                ]),
                const SizedBox(height: 3),
                Text(availabilityNote,
                    style: TextStyle(fontSize: 11, height: 1.4,
                        color: TColors.white.withOpacity(0.4))),
              ],
            )),
            const SizedBox(width: 8),
            // Connect / Disconnect button
            if (!comingSoon)
              GestureDetector(
                onTap: connected ? onDisconnect : onConnect,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: connected
                        ? TColors.red400.withOpacity(0.15)
                        : col.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: connected
                          ? TColors.red400.withOpacity(0.4)
                          : col.withOpacity(0.4))),
                  child: syncing
                      ? SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                              color: col, strokeWidth: 2))
                      : Text(
                          connected
                              ? lang.s('Disconnect', 'ለቀቅ')
                              : lang.s('Connect', 'ግናኛ'),
                          style: TextStyle(fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: connected ? TColors.red400 : col)),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

// ─── MANUAL ENTRY CARD ───────────────────────────────────────────
class _ManualEntryCard extends StatelessWidget {
  final LanguageProvider lang;
  final VoidCallback onTap;
  const _ManualEntryCard({required this.lang, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TColors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: TColors.teal500.withOpacity(0.3))),
          child: Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: TColors.teal500.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.edit_rounded,
                  color: TColors.teal400, size: 22)),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lang.s('Manual Entry', 'በእጅ ማስገቢያ'),
                    style: const TextStyle(fontSize: 15,
                        color: TColors.white, fontWeight: FontWeight.w700)),
                Text(lang.s(
                    'No wearable? Enter your vitals manually',
                    'ዌርአብል የለዎትም? ቫይታሎቹን በእጅ ያስገቡ'),
                    style: TextStyle(fontSize: 11,
                        color: TColors.white.withOpacity(0.4))),
              ],
            )),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: TColors.teal400, size: 16),
          ]),
        ),
      ),
    ),
  );
}

// ─── MANUAL ENTRY SHEET ──────────────────────────────────────────
class _ManualEntrySheet extends StatelessWidget {
  final LanguageProvider lang;
  final TextEditingController stepsCtrl, hrCtrl, spo2Ctrl, sleepCtrl, weightCtrl;
  final VoidCallback onSave;

  const _ManualEntrySheet({
    required this.lang,
    required this.stepsCtrl, required this.hrCtrl,
    required this.spo2Ctrl, required this.sleepCtrl,
    required this.weightCtrl, required this.onSave,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: MediaQuery.of(context).size.height * 0.85,
    decoration: const BoxDecoration(
      color: Color(0xFF0E1320),
      borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    child: Column(children: [
      // Handle
      Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Container(width: 40, height: 4,
            decoration: BoxDecoration(
                color: TColors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2)))),
      // Header
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(children: [
          const Icon(Icons.edit_rounded, color: TColors.teal400, size: 22),
          const SizedBox(width: 12),
          Text(lang.s('Enter your vitals', 'ቫይታሎቹን ያስገቡ'),
              style: const TextStyle(fontSize: 18,
                  color: TColors.white, fontWeight: FontWeight.w700)),
        ]),
      ),
      Expanded(child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 8, 20,
            MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(children: [
          _VitalField(ctrl: stepsCtrl, lang: lang,
              labelEn: 'Steps today', labelAm: 'ዛሬ እርምጃዎች',
              icon: Icons.directions_walk_rounded, color: TColors.teal500,
              hintEn: 'e.g. 5000', hintAm: 'ምሳሌ: 5000',
              keyboardType: TextInputType.number),
          _VitalField(ctrl: hrCtrl, lang: lang,
              labelEn: 'Heart rate (bpm)', labelAm: 'ልብ ምት (bpm)',
              icon: Icons.favorite_rounded, color: TColors.pink500,
              hintEn: 'e.g. 72', hintAm: 'ምሳሌ: 72',
              keyboardType: TextInputType.number),
          _VitalField(ctrl: spo2Ctrl, lang: lang,
              labelEn: 'SpO₂ (%)', labelAm: 'SpO₂ (%)',
              icon: Icons.air_rounded, color: TColors.blue500,
              hintEn: 'e.g. 96.5', hintAm: 'ምሳሌ: 96.5',
              keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          _VitalField(ctrl: sleepCtrl, lang: lang,
              labelEn: 'Sleep hours', labelAm: 'የእንቅልፍ ሰዓቶች',
              icon: Icons.bedtime_rounded, color: const Color(0xFF7C4DFF),
              hintEn: 'e.g. 7.5', hintAm: 'ምሳሌ: 7.5',
              keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          _VitalField(ctrl: weightCtrl, lang: lang,
              labelEn: 'Weight (kg)', labelAm: 'ክብደት (ኪ.ግ.)',
              icon: Icons.monitor_weight_rounded, color: TColors.green500,
              hintEn: 'e.g. 62.4', hintAm: 'ምሳሌ: 62.4',
              keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          const SizedBox(height: 8),
          // SpO2 context for Ethiopian altitude
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TColors.teal500.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: TColors.teal500.withOpacity(0.2))),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded,
                  color: TColors.teal400, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(
                lang.s(
                  'At Addis Ababa altitude (2,300m), normal SpO₂ is 92–96%. Below 92% — seek medical attention.',
                  'በአዲስ አበባ ከፍታ (2,300 ሜ.)፣ ተለምዶ SpO₂ 92-96% ነው። ከ92% በታች — ሐኪም ያማክሩ።'),
                style: TextStyle(fontSize: 11, height: 1.5,
                    color: TColors.teal300))),
            ]),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onSave,
            child: Container(
              width: double.infinity, height: 52,
              decoration: BoxDecoration(
                gradient: TGradients.gradTeal,
                borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(lang.s('Save Vitals', 'ቫይታሎቹን አስቀምጥ'),
                  style: const TextStyle(color: TColors.white,
                      fontWeight: FontWeight.w700, fontSize: 16)))),
          ),
        ]),
      )),
    ]),
  );
}

class _VitalField extends StatelessWidget {
  final TextEditingController ctrl;
  final LanguageProvider lang;
  final String labelEn, labelAm, hintEn, hintAm;
  final IconData icon;
  final Color color;
  final TextInputType keyboardType;

  const _VitalField({
    required this.ctrl, required this.lang,
    required this.labelEn, required this.labelAm,
    required this.hintEn, required this.hintAm,
    required this.icon, required this.color,
    required this.keyboardType,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(color: TColors.white),
      decoration: InputDecoration(
        labelText: lang.isAmharic ? labelAm : labelEn,
        hintText: lang.isAmharic ? hintAm : hintEn,
        labelStyle: TextStyle(color: color),
        hintStyle: TextStyle(color: TColors.white.withOpacity(0.25)),
        prefixIcon: Icon(icon, color: color, size: 20),
        filled: true,
        fillColor: TColors.white.withOpacity(0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: TColors.white.withOpacity(0.1))),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: 2)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: TColors.white.withOpacity(0.1))),
      ),
    ),
  );
}

// ─── WHAT WE TRACK CARD ──────────────────────────────────────────
class _WhatWeTrackCard extends StatelessWidget {
  final LanguageProvider lang;
  const _WhatWeTrackCard({required this.lang});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.directions_walk_rounded,
       lang.s('Steps', 'እርምጃዎች'),
       lang.s('Daily goal: 6,000 steps → +15 XP', 'ዕለታዊ ግብ: 6,000 እርምጃዎች → +15 XP')),
      (Icons.favorite_rounded,
       lang.s('Heart rate', 'ልብ ምት'),
       lang.s('Resting & exercise heart rate trends', 'ያረፈ እና ልምምድ የልብ ምት አዝማሚያ')),
      (Icons.air_rounded,
       lang.s('SpO₂', 'SpO₂'),
       lang.s('Altitude-aware oxygen saturation alert', 'ከፍታ-ንቁ የኦክሲጅን ሙሌት ማንቂያ')),
      (Icons.bedtime_rounded,
       lang.s('Sleep', 'እንቅልፍ'),
       lang.s('Sleep quality linked to cycle & mood', 'እንቅልፍ ጥራት ከዑደት እና ስሜት ጋር ይያያዛል')),
      (Icons.monitor_weight_rounded,
       lang.s('Weight', 'ክብደት'),
       lang.s('Pregnancy weight tracking vs WHO chart', 'ከWHO ቻርት ጋር የእርግዝና ክብደት ክትትል')),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TColors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: TColors.white.withOpacity(0.07))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lang.s('What Tsega tracks', 'ጸጋ ምን ይከታተላል'),
                  style: TextStyle(fontSize: 12,
                      color: TColors.white.withOpacity(0.5),
                      fontWeight: FontWeight.w700, letterSpacing: 0.5)),
              const SizedBox(height: 12),
              ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(item.$1,
                        color: TColors.teal400, size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.$2, style: const TextStyle(
                            fontSize: 13, color: TColors.white,
                            fontWeight: FontWeight.w600)),
                        Text(item.$3, style: TextStyle(
                            fontSize: 11, height: 1.4,
                            color: TColors.white.withOpacity(0.4))),
                      ],
                    )),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── SUPPORTING WIDGETS ──────────────────────────────────────────
class _BG extends StatelessWidget {
  final Animation<double> pulse;
  const _BG({required this.pulse});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: pulse,
    builder: (_, __) => Stack(children: [
      Container(color: const Color(0xFF0A1628)),
      Positioned(top: -60 + pulse.value * 10, right: -40,
          child: _Orb(250, TColors.teal500.withOpacity(0.10))),
      Positioned(top: 280 - pulse.value * 8, left: -60,
          child: _Orb(200, TColors.blue500.withOpacity(0.08))),
    ]),
  );
}

class _Orb extends StatelessWidget {
  final double size; final Color color;
  const _Orb(this.size, this.color);
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color,
            blurRadius: size, spreadRadius: size * 0.2)]));
}

class _GBtn extends StatelessWidget {
  final IconData icon;
  const _GBtn({required this.icon});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: TColors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: TColors.white.withOpacity(0.12))),
        child: Icon(icon, color: TColors.white, size: 18))));
}
