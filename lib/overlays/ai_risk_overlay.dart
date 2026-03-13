import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';
import '../../screens/health/health_screen.dart' show _LabRow;

class AiRiskOverlay extends StatelessWidget {
  final _LabRow result;
  const AiRiskOverlay({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final (riskColor, riskBg, riskLabelEn, riskLabelAm) = switch (result.risk) {
      'red'    => (TColors.statusRed,    TColors.red100,
                   'High Risk — Seek Care Now',
                   'ከፍተኛ ስጋት — አሁን ሕክምና ይጠይቁ'),
      'yellow' => (TColors.statusYellow, const Color(0xFFFFF8E1),
                   'Moderate Risk — Monitor Closely',
                   'መካከለኛ ስጋት — በጥንቃቄ ይከታተሉ'),
      _        => (TColors.statusGreen,  TColors.green100,
                   'Low Risk — All Looks Good',
                   'ዝቅተኛ ስጋት — ሁሉም ጥሩ ነው'),
    };

    // Build flags from values
    final flagsEn = <String>[];
    final flagsAm = <String>[];
    if (result.hb < 8)        { flagsEn.add('Severe anemia (Hb < 8 g/dL) — needs transfusion'); flagsAm.add('ከፍተኛ ደም ማነስ (Hb < 8) — ደም ሽግግር ያስፈልጋል'); }
    else if (result.hb < 11)  { flagsEn.add('Mild anemia — increase iron intake'); flagsAm.add('ቀሃ ደም ማነስ — ብረት ያለው ምግብ ይጨምሩ'); }
    if (result.sys > 140)     { flagsEn.add('Hypertension — risk of preeclampsia'); flagsAm.add('ደም ግፊት — ቅድመ-ወሊድ ከፍተኛ ደም ግፊት ስጋት'); }
    else if (result.sys > 130){ flagsEn.add('Elevated BP — monitor daily'); flagsAm.add('ከፍ ያለ ደም ግፊት — በየቀኑ ይከታተሉ'); }
    if (result.sugar > 110)   { flagsEn.add('Elevated blood sugar — watch carbohydrate intake'); flagsAm.add('ከፍ ያለ የደም ስኳር — ካርቦሃይድሬት ይቀንሱ'); }
    if (flagsEn.isEmpty)      { flagsEn.add('All values within Ethiopian altitude-adjusted normal ranges'); flagsAm.add('ሁሉም ዋጋዎች ለኢትዮጵያ ከፍታ በተስተካከሉ ወሰኖች ውስጥ ናቸው'); }

    // Recommendations
    final recsEn = <String>[];
    final recsAm = <String>[];
    if (result.hb < 11) { recsEn.add('Eat misir, gomen, teff daily'); recsAm.add('ምስር፣ ጎመን፣ ጤፍ በየቀኑ ይ召し食べ'); }
    if (result.sys > 130){ recsEn.add('Reduce salt; rest; go to hospital if headache appears'); recsAm.add('ጨው ይቀንሱ፤ ያርፉ፤ ራስ ምታት ቢያያዝ ሆስፒታል ይሂዱ'); }
    recsEn.add('Attend your next ANC visit as scheduled');
    recsAm.add('ቀጣዩን ANC ጉብኝት ወቅቱን ጠብቀው ይሂዱ');

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: TColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          decoration: const BoxDecoration(
            gradient: TGradients.gradTeal,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(children: [
            Row(children: [
              const Icon(Icons.psychology_rounded,
                  color: TColors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(child: Text(lang.aiRiskAssessment,
                  style: const TextStyle(fontSize: 18,
                      color: TColors.white, fontWeight: FontWeight.w700))),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close_rounded, color: TColors.white)),
            ]),
            const SizedBox(height: 4),
            Align(alignment: Alignment.centerLeft,
              child: Text(lang.isAmharic ? result.dateAm : result.dateEn,
                  style: TextStyle(color: TColors.white.withOpacity(0.75),
                      fontSize: 12))),
          ]),
        ),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Overall risk
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: riskBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: riskColor.withOpacity(0.4))),
              child: Row(children: [
                Icon(result.risk == 'green'
                    ? Icons.check_circle_rounded : Icons.warning_rounded,
                    color: riskColor, size: 36),
                const SizedBox(width: 14),
                Expanded(child: Text(
                  lang.isAmharic ? riskLabelAm : riskLabelEn,
                  style: TextStyle(fontSize: 16,
                      fontWeight: FontWeight.w700, color: riskColor))),
              ]),
            ),
            const SizedBox(height: 20),

            // Metrics table
            _SubHead(lang.s('Lab Values', 'የላብ ዋጋዎች')),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: TColors.white,
                borderRadius: BorderRadius.circular(14)),
              child: Column(children: [
                _MetricRow(lang.hemoglobin,
                    '${result.hb} g/dL',
                    result.hb < 11 ? 'yellow' : 'green', lang),
                _MetricRow(lang.bloodPressure,
                    '${result.sys}/${result.dia} mmHg',
                    result.sys > 140 ? 'red' : result.sys > 130 ? 'yellow' : 'green', lang),
                _MetricRow(lang.bloodSugar,
                    '${result.sugar.toInt()} mg/dL',
                    result.sugar > 110 ? 'yellow' : 'green', lang),
                _MetricRow(lang.weight,
                    '${result.weight} kg', 'green', lang, last: true),
              ]),
            ),
            const SizedBox(height: 20),

            // Flags
            _SubHead(lang.s('Findings', 'ግኝቶች')),
            const SizedBox(height: 10),
            ...List.generate(flagsEn.length, (i) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: TColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: result.risk == 'red' && i == 0
                      ? TColors.red400.withOpacity(0.4) : TColors.border)),
              child: Row(children: [
                Icon(result.risk == 'green'
                    ? Icons.check_rounded : Icons.info_rounded,
                    color: result.risk == 'green'
                        ? TColors.green500 : TColors.statusYellow,
                    size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  lang.isAmharic ? flagsAm[i] : flagsEn[i],
                  style: const TextStyle(fontSize: 13,
                      color: TColors.dark, height: 1.4))),
              ]),
            )),
            const SizedBox(height: 20),

            // Recommendations
            _SubHead(lang.s('Recommendations', 'ምክሮች')),
            const SizedBox(height: 10),
            ...List.generate(recsEn.length, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    gradient: TGradients.gradTeal,
                    borderRadius: BorderRadius.circular(6)),
                  child: Center(child: Text('${i + 1}',
                      style: const TextStyle(color: TColors.white,
                          fontSize: 12, fontWeight: FontWeight.w700))),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  lang.isAmharic ? recsAm[i] : recsEn[i],
                  style: const TextStyle(fontSize: 13,
                      color: TColors.dark, height: 1.5))),
              ]),
            )),
            const SizedBox(height: 20),

            // Share with doctor
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: TGradients.gradTeal,
                  borderRadius: BorderRadius.circular(14)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  const Icon(Icons.share_rounded,
                      color: TColors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(lang.shareWithDoctor,
                      style: const TextStyle(color: TColors.white,
                          fontWeight: FontWeight.w700, fontSize: 15)),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            Center(child: Text(
              lang.s(
                'AI assessment is for guidance only. Always consult your doctor.',
                'AI ምዘና ለመመሪያ ብቻ ነው። ሁልጊዜ ዶክተርዎን ያማክሩ።'),
              style: const TextStyle(fontSize: 11, color: TColors.gray),
              textAlign: TextAlign.center)),
            const SizedBox(height: 20),
          ]),
        )),
      ]),
    );
  }
}

class _SubHead extends StatelessWidget {
  final String text;
  const _SubHead(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 15,
          fontWeight: FontWeight.w700, color: TColors.dark));
}

class _MetricRow extends StatelessWidget {
  final String label, value, risk;
  final LanguageProvider lang;
  final bool last;
  const _MetricRow(this.label, this.value, this.risk, this.lang,
      {this.last = false});
  @override
  Widget build(BuildContext context) {
    final col = risk == 'red' ? TColors.statusRed
        : risk == 'yellow' ? TColors.statusYellow : TColors.statusGreen;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Expanded(child: Text(label, style: const TextStyle(
              fontSize: 13, color: TColors.mid))),
          Text(value, style: TextStyle(fontSize: 14,
              fontWeight: FontWeight.w700, color: col)),
          const SizedBox(width: 8),
          Icon(risk == 'green' ? Icons.check_circle_rounded
              : Icons.warning_rounded, color: col, size: 16),
        ]),
      ),
      if (!last) const Divider(height: 1, indent: 16, endIndent: 16),
    ]);
  }
}
