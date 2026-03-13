import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';
import '../../models/lab_row.dart';

class AiRiskOverlay extends StatelessWidget {
  final LabRow result;
  const AiRiskOverlay({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    final Color riskColor;
    final Color riskBg;
    final String riskLabelEn, riskLabelAm;
    if (result.risk == 'red') {
      riskColor = TColors.statusRed; riskBg = TColors.red100;
      riskLabelEn = 'High Risk — Seek Care Now';
      riskLabelAm = 'ከፍተኛ ስጋት — አሁን ሕክምና ይጠይቁ';
    } else if (result.risk == 'yellow') {
      riskColor = TColors.statusYellow; riskBg = const Color(0xFFFFF8E1);
      riskLabelEn = 'Moderate Risk — Monitor Closely';
      riskLabelAm = 'መካከለኛ ስጋት — በጥንቃቄ ይከታተሉ';
    } else {
      riskColor = TColors.statusGreen; riskBg = TColors.green100;
      riskLabelEn = 'Low Risk — All Looks Good';
      riskLabelAm = 'ዝቅተኛ ስጋት — ሁሉም ጥሩ ነው';
    }

    final flagsEn = <String>[];
    final flagsAm = <String>[];
    if (result.hb < 8) {
      flagsEn.add('Severe anemia (Hb < 8 g/dL) — may need transfusion');
      flagsAm.add('ከፍተኛ ደም ማነስ (Hb < 8) — ደም ሽግግር ሊያስፈልግ ይችላል');
    } else if (result.hb < 11) {
      flagsEn.add('Mild anemia — increase iron intake');
      flagsAm.add('ቀሃ ደም ማነስ — ብረት ያለው ምግብ ይጨምሩ');
    }
    if (result.sys > 140) {
      flagsEn.add('Hypertension — risk of preeclampsia');
      flagsAm.add('ደም ግፊት — ቅድመ-ወሊድ ከፍተኛ ደም ግፊት ስጋት');
    } else if (result.sys > 130) {
      flagsEn.add('Elevated BP — monitor daily');
      flagsAm.add('ከፍ ያለ ደም ግፊት — በየቀኑ ይከታተሉ');
    }
    if (result.sugar > 110) {
      flagsEn.add('Elevated blood sugar — watch carbohydrate intake');
      flagsAm.add('ከፍ ያለ የደም ስኳር — ካርቦሃይድሬት ይቀንሱ');
    }
    if (flagsEn.isEmpty) {
      flagsEn.add('All values within altitude-adjusted normal ranges');
      flagsAm.add('ሁሉም ዋጋዎች ለኢትዮጵያ ከፍታ በተስተካከሉ ወሰኖች ውስጥ ናቸው');
    }

    final recsEn = <String>[];
    final recsAm = <String>[];
    if (result.hb < 11) {
      recsEn.add('Eat misir, gomen, teff daily');
      recsAm.add('ምስር፣ ጎመን፣ ጤፍ በየቀኑ ይ食べ');
    }
    if (result.sys > 130) {
      recsEn.add('Reduce salt; rest; go to hospital if headache appears');
      recsAm.add('ጨው ይቀንሱ፤ ያርፉ፤ ራስ ምታት ቢያያዝ ሆስፒታል ይሂዱ');
    }
    recsEn.add('Attend your next ANC visit as scheduled');
    recsAm.add('ቀጣዩን ANC ጉብኝት ወቅቱን ጠብቀው ይሂዱ');

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: TColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
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
              Expanded(child: Text(lang.s('AI Risk Assessment', 'AI የስጋት ምዘና'),
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
            // Risk summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: riskBg, borderRadius: BorderRadius.circular(16),
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
            // Metrics
            _SH(lang.s('Lab Values', 'የላብ ዋጋዎች')),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(color: TColors.white,
                  borderRadius: BorderRadius.circular(14)),
              child: Column(children: [
                _MR(lang.s('Hemoglobin (Hb)', 'ሄሞግሎቢን'),
                    '${result.hb} g/dL',
                    result.hb < 11 ? 'yellow' : 'green', lang),
                _MR(lang.s('Blood Pressure', 'ደም ግፊት'),
                    '${result.sys}/${result.dia} mmHg',
                    result.sys > 140 ? 'red' : result.sys > 130 ? 'yellow' : 'green', lang),
                _MR(lang.s('Blood Sugar', 'የደም ስኳር'),
                    '${result.sugar.toInt()} mg/dL',
                    result.sugar > 110 ? 'yellow' : 'green', lang),
                _MR(lang.s('Weight', 'ክብደት'),
                    '${result.weight} kg', 'green', lang, last: true),
              ]),
            ),
            const SizedBox(height: 20),
            // Findings
            _SH(lang.s('Findings', 'ግኝቶች')),
            const SizedBox(height: 10),
            ...List.generate(flagsEn.length, (i) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: TColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TColors.border)),
              child: Row(children: [
                Icon(result.risk == 'green'
                    ? Icons.check_rounded : Icons.info_rounded,
                    color: result.risk == 'green'
                        ? TColors.green500 : TColors.statusYellow, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  lang.isAmharic ? flagsAm[i] : flagsEn[i],
                  style: const TextStyle(fontSize: 13,
                      color: TColors.dark, height: 1.4))),
              ]),
            )),
            const SizedBox(height: 20),
            // Recommendations
            _SH(lang.s('Recommendations', 'ምክሮች')),
            const SizedBox(height: 10),
            ...List.generate(recsEn.length, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(gradient: TGradients.gradTeal,
                      borderRadius: BorderRadius.circular(6)),
                  child: Center(child: Text('${i + 1}',
                      style: const TextStyle(color: TColors.white,
                          fontSize: 12, fontWeight: FontWeight.w700)))),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  lang.isAmharic ? recsAm[i] : recsEn[i],
                  style: const TextStyle(fontSize: 13,
                      color: TColors.dark, height: 1.5))),
              ]),
            )),
            const SizedBox(height: 20),
            // Share CTA
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity, padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(gradient: TGradients.gradTeal,
                    borderRadius: BorderRadius.circular(14)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.share_rounded, color: TColors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(lang.s('Share with Doctor', 'ከዶክተር ጋር ያጋሩ'),
                      style: const TextStyle(color: TColors.white,
                          fontWeight: FontWeight.w700, fontSize: 15)),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            Center(child: Text(
              lang.s('AI assessment is for guidance only. Always consult your doctor.',
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

class _SH extends StatelessWidget {
  final String text;
  const _SH(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 15,
          fontWeight: FontWeight.w700, color: TColors.dark));
}

class _MR extends StatelessWidget {
  final String label, value, risk;
  final LanguageProvider lang;
  final bool last;
  const _MR(this.label, this.value, this.risk, this.lang, {this.last = false});
  @override
  Widget build(BuildContext context) {
    final col = risk == 'red' ? TColors.statusRed
        : risk == 'yellow' ? TColors.statusYellow : TColors.statusGreen;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Expanded(child: Text(label,
              style: const TextStyle(fontSize: 13, color: TColors.mid))),
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
