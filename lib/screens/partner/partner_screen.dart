import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';
import '../../overlays/partner_invite_overlay.dart';

class PartnerScreen extends StatelessWidget {
  const PartnerScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: TColors.cream,
      appBar: AppBar(
        backgroundColor: TColors.teal700, foregroundColor: TColors.white,
        title: Text(lang.partner), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Container(
            width: double.infinity, padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(gradient: TGradients.gradPink,
              borderRadius: BorderRadius.circular(20)),
            child: Column(children: [
              const Icon(Icons.favorite_rounded, color: TColors.white, size: 48),
              const SizedBox(height: 12),
              Text(lang.s('Keep Your Partner Informed',
                  'ሸሪካዎ ያሳወቁ ይቀጥሉ'),
                  style: const TextStyle(fontSize: 20, color: TColors.white,
                      fontWeight: FontWeight.w700), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(lang.s(
                  'Share health updates, danger signs, and appointments with the people who support you.',
                  'ጤና ዝማኔዎችን፣ አደጋ ምልክቶችን፣ እና ቀጠሮዎችን ከሚደግፉዎ ሰዎች ጋር ያጋሩ።'),
                  style: TextStyle(color: TColors.white.withOpacity(0.9),
                      fontSize: 14, height: 1.5), textAlign: TextAlign.center),
            ]),
          ),
          const SizedBox(height: 24),
          _InfoTile(Icons.notifications_rounded, TColors.teal500,
              lang.s('Danger Sign Alerts', 'አደጋ ምልክት ማንቂያዎች'),
              lang.s('Partner receives SMS when you log a danger sign',
                  'አደጋ ምልክት ሲመዘግቡ ሸሪካ SMS ይቀበላሉ')),
          const SizedBox(height: 10),
          _InfoTile(Icons.calendar_today_rounded, TColors.blue500,
              lang.s('Appointment Sharing', 'ቀጠሮ ማጋራት'),
              lang.s('Keep them updated on your ANC schedule',
                  'ANC ቀጠሮዎን ያሳወቋቸው')),
          const SizedBox(height: 10),
          _InfoTile(Icons.menu_book_rounded, TColors.green500,
              lang.s('Partner Education', 'ሸሪካ ትምህርት'),
              lang.s('They get access to danger sign guides and support tips',
                  'አደጋ ምልክት መመሪያዎች እና ድጋፍ ምክሮች ያገኛሉ')),
          const Spacer(),
          GestureDetector(
            onTap: () => showModalBottomSheet(context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const PartnerInviteOverlay()),
            child: Container(
              width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(gradient: TGradients.gradPink,
                borderRadius: BorderRadius.circular(14)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.person_add_rounded, color: TColors.white),
                const SizedBox(width: 10),
                Text(lang.s('Invite Partner', 'ሸሪካ ይጋብዙ'),
                    style: const TextStyle(color: TColors.white,
                        fontWeight: FontWeight.w700, fontSize: 16)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon; final Color color;
  final String title, subtitle;
  const _InfoTile(this.icon, this.color, this.title, this.subtitle);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: TColors.white,
      borderRadius: BorderRadius.circular(14)),
    child: Row(children: [
      Container(width: 40, height: 40,
        decoration: BoxDecoration(color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 14,
            fontWeight: FontWeight.w700, color: TColors.dark)),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: TColors.gray)),
      ])),
    ]),
  );
}
