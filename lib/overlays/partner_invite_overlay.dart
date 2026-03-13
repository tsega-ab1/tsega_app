import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';

class PartnerInviteOverlay extends StatefulWidget {
  const PartnerInviteOverlay({super.key});
  @override
  State<PartnerInviteOverlay> createState() => _PartnerInviteOverlayState();
}

class _PartnerInviteOverlayState extends State<PartnerInviteOverlay> {
  final _ctrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Container(
      decoration: const BoxDecoration(
        color: TColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(24, 24, 24,
          MediaQuery.of(context).viewInsets.bottom + 24),
      child: _sent ? Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.check_circle_rounded,
            color: TColors.green500, size: 64),
        const SizedBox(height: 16),
        Text(lang.s('Invitation Sent! 💌', 'ጥሪ ተልኳል! 💌'),
            style: const TextStyle(fontSize: 22,
                fontWeight: FontWeight.w700, color: TColors.dark)),
        const SizedBox(height: 8),
        Text(lang.s(
            'Your partner will receive an SMS with instructions to join Tsega and stay informed.',
            'ሸሪካዎ ጸጋን ለመቀላቀል እና ያሳወቀ ሆኖ ለመቆየት መመሪያ ያለው SMS ይቀበላሉ።'),
            style: const TextStyle(color: TColors.gray, fontSize: 14, height: 1.5),
            textAlign: TextAlign.center),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(lang.done, style: const TextStyle(
              color: TColors.teal500, fontWeight: FontWeight.w700, fontSize: 16)),
        ),
      ]) : Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4,
            decoration: BoxDecoration(color: TColors.border,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            gradient: TGradients.gradPink,
            borderRadius: BorderRadius.circular(18)),
          child: const Icon(Icons.favorite_rounded,
              color: TColors.white, size: 32)),
        const SizedBox(height: 16),
        Text(lang.s('Invite Your Partner', 'ሸሪካዎን ይጋብዙ'),
            style: const TextStyle(fontSize: 20,
                fontWeight: FontWeight.w700, color: TColors.dark)),
        const SizedBox(height: 8),
        Text(lang.s(
            'They will receive updates, danger sign alerts, and guidance to support you.',
            'ዝማኔዎችን፣ አደጋ ምልክት ማንቂያዎችን፣ እና ለመደገፍ መመሪያ ይቀበላሉ።'),
            style: const TextStyle(color: TColors.gray, fontSize: 13, height: 1.5),
            textAlign: TextAlign.center),
        const SizedBox(height: 24),
        TextField(
          controller: _ctrl,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: lang.s('Partner\'s phone number', 'የሸሪካ ስልክ ቁጥር'),
            prefixText: '+251 ',
            hintText: '9XX XXX XXX',
            prefixIcon: const Icon(Icons.phone_rounded,
                color: TColors.pink500, size: 20),
            filled: true, fillColor: TColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: TColors.border)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: TColors.pink500, width: 2)),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () async {
            await Future.delayed(const Duration(milliseconds: 800));
            if (mounted) setState(() => _sent = true);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: TGradients.gradPink,
              borderRadius: BorderRadius.circular(14)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.send_rounded, color: TColors.white, size: 20),
              const SizedBox(width: 10),
              Text(lang.s('Send Invitation', 'ጥሪ ላክ'),
                  style: const TextStyle(color: TColors.white,
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ]),
          ),
        ),
      ]),
    );
  }
}
