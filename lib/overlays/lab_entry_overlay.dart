import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';
import '../../screens/health/health_screen.dart' show _LabRow;

class LabEntryOverlay extends StatefulWidget {
  final Function(_LabRow) onSave;
  const LabEntryOverlay({super.key, required this.onSave});
  @override
  State<LabEntryOverlay> createState() => _LabEntryOverlayState();
}

class _LabEntryOverlayState extends State<LabEntryOverlay> {
  final _hb  = TextEditingController();
  final _sys = TextEditingController();
  final _dia = TextEditingController();
  final _sugar = TextEditingController();
  final _weight = TextEditingController();
  bool _useQr = false;

  @override
  void dispose() {
    _hb.dispose(); _sys.dispose(); _dia.dispose();
    _sugar.dispose(); _weight.dispose();
    super.dispose();
  }

  void _save() {
    final hb     = double.tryParse(_hb.text) ?? 12.0;
    final sys    = int.tryParse(_sys.text) ?? 120;
    final dia    = int.tryParse(_dia.text) ?? 80;
    final sugar  = double.tryParse(_sugar.text) ?? 95.0;
    final weight = double.tryParse(_weight.text) ?? 60.0;

    String risk = 'green';
    if (hb < 8 || sys > 140) risk = 'red';
    else if (hb < 11 || sys > 130) risk = 'yellow';

    final now = DateTime.now();
    widget.onSave(_LabRow(
      '${now.day} ${_monthEn(now.month)} ${now.year}',
      '${now.day} ${_monthAm(now.month)} ${now.year}',
      hb, sys, dia, sugar, weight, risk,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: TColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          decoration: const BoxDecoration(
            gradient: TGradients.gradTeal,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Row(children: [
            const Icon(Icons.science_rounded, color: TColors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(child: Text(lang.addResult,
                style: const TextStyle(fontSize: 18,
                    color: TColors.white, fontWeight: FontWeight.w700))),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close_rounded, color: TColors.white)),
          ]),
        ),
        // Entry mode tabs
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => setState(() => _useQr = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: !_useQr ? TGradients.gradTeal : null,
                  color: !_useQr ? null : TColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: _useQr ? Border.all(color: TColors.border) : null),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.edit_rounded,
                      color: !_useQr ? TColors.white : TColors.gray, size: 18),
                  const SizedBox(width: 8),
                  Text(lang.manualEntry,
                      style: TextStyle(
                          color: !_useQr ? TColors.white : TColors.gray,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
            )),
            const SizedBox(width: 12),
            Expanded(child: GestureDetector(
              onTap: () => setState(() => _useQr = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: _useQr ? TGradients.gradBlue : null,
                  color: _useQr ? null : TColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: !_useQr ? Border.all(color: TColors.border) : null),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.qr_code_scanner_rounded,
                      color: _useQr ? TColors.white : TColors.gray, size: 18),
                  const SizedBox(width: 8),
                  Text(lang.scanQr,
                      style: TextStyle(
                          color: _useQr ? TColors.white : TColors.gray,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
            )),
          ]),
        ),
        // Form or QR
        Expanded(child: _useQr ? _QrPlaceholder() : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: [
            _LabField(_hb,    lang.hemoglobin,    'e.g. 12.5', Icons.bloodtype_rounded,  TColors.red400),
            _LabField(_sys,   lang.s('Systolic BP', 'ሲስቶሊክ ደም ግፊት'), 'e.g. 118', Icons.monitor_heart_rounded, TColors.blue500),
            _LabField(_dia,   lang.s('Diastolic BP', 'ዳያስቶሊክ'), 'e.g. 76', Icons.monitor_heart_outlined, TColors.blue300),
            _LabField(_sugar, lang.bloodSugar,    'e.g. 95',   Icons.water_drop_rounded, TColors.statusYellow),
            _LabField(_weight,lang.weight,        'e.g. 62',   Icons.monitor_weight_rounded, TColors.teal500),
            const SizedBox(height: 8),
            // AI risk notice
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: TColors.teal50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TColors.teal100)),
              child: Row(children: [
                const Icon(Icons.psychology_rounded,
                    color: TColors.teal500, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  lang.s(
                    'AI will assess your results for anemia, hypertension, and other risks after saving.',
                    'AI ከማስቀመጥ በኋላ ለደም ማነስ፣ ደም ግፊት፣ እና ሌሎች ስጋቶች ውጤቶቹን ይመዝናል።'),
                  style: const TextStyle(fontSize: 12,
                      color: TColors.teal700, height: 1.4))),
              ]),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _save,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: TGradients.gradTeal,
                  borderRadius: BorderRadius.circular(14)),
                child: Center(child: Text(lang.save,
                    style: const TextStyle(color: TColors.white,
                        fontWeight: FontWeight.w700, fontSize: 16))),
              ),
            ),
            const SizedBox(height: 24),
          ]),
        )),
      ]),
    );
  }

  String _monthEn(int m) => ['Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'][m-1];
  String _monthAm(int m) => ['ጥር','የካቲት','መጋቢት','ሚያዚያ','ግንቦት','ሰኔ',
    'ሐምሌ','ነሐሴ','ጳጉሜ','መስከረም','ጥቅምት','ህዳር'][m-1];
}

class _LabField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final IconData icon;
  final Color iconColor;
  const _LabField(this.ctrl, this.label, this.hint, this.icon, this.iconColor);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: iconColor, size: 20),
        filled: true, fillColor: TColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: TColors.border)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: TColors.teal500, width: 2)),
      ),
    ),
  );
}

class _QrPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 200, height: 200,
          decoration: BoxDecoration(
            color: TColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: TColors.teal300, width: 2)),
          child: const Icon(Icons.qr_code_scanner_rounded,
              color: TColors.teal300, size: 80),
        ),
        const SizedBox(height: 20),
        Text(lang.s('Point your camera at the clinic QR code',
            'ካሜራዎን ወደ ክሊኒኩ QR ኮድ ያቅናሉ'),
            style: const TextStyle(color: TColors.gray, fontSize: 14),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(lang.s('Your lab results will be imported automatically',
            'የላብ ውጤቶቹ በራስ-ሰር ይጫናሉ'),
            style: const TextStyle(color: TColors.gray, fontSize: 12),
            textAlign: TextAlign.center),
      ],
    ));
  }
}
