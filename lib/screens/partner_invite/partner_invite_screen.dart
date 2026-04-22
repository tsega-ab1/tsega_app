import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/partner_provider.dart';
import '../../models/partner_model.dart';

// ── WOMAN'S INVITE SCREEN ────────────────────────────────────────
class PartnerInviteScreen extends StatefulWidget {
  const PartnerInviteScreen({super.key});
  @override
  State<PartnerInviteScreen> createState() => _PartnerInviteScreenState();
}

class _PartnerInviteScreenState extends State<PartnerInviteScreen> {
  PartnerInvite? _invite;

  @override
  Widget build(BuildContext context) {
    final lang    = context.watch<LanguageProvider>();
    final partner = context.read<PartnerProvider>();
    final isLinked = partner.isLinked;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Stack(children: [
        Positioned(top: -60, right: -40,
            child: _Orb(280, TColors.pink500.withOpacity(0.10))),
        SafeArea(child: Column(children: [
          // App bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: _GBtn(icon: Icons.arrow_back_ios_rounded)),
              const SizedBox(width: 12),
              Text(lang.s('Partner & Family', 'ሸሪካ እና ቤተሰብ'),
                  style: const TextStyle(fontSize: 18,
                      color: TColors.white, fontWeight: FontWeight.w700)),
            ]),
          ),

          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            child: isLinked
                ? _LinkedView(lang: lang, partner: partner)
                : _InviteView(
                    lang: lang,
                    invite: _invite,
                    onGenerate: () => setState(() =>
                        _invite = partner.generateInvite()),
                  ),
          )),
        ])),
      ]),
    );
  }
}

// ── INVITE VIEW (not yet linked) ─────────────────────────────────
class _InviteView extends StatelessWidget {
  final LanguageProvider lang;
  final PartnerInvite? invite;
  final VoidCallback onGenerate;
  const _InviteView({required this.lang, this.invite, required this.onGenerate});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Icon
      Container(
        width: 64, height: 64,
        decoration: BoxDecoration(
          gradient: TGradients.gradPink,
          borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.favorite_rounded,
            color: TColors.white, size: 32)),
      const SizedBox(height: 20),

      Text(lang.s('Invite your partner', 'ሸሪካዎን ይጋብዙ'),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800,
              color: TColors.white, letterSpacing: -0.5)),
      const SizedBox(height: 8),
      Text(lang.s(
          'Share a code with your husband or partner. '
          'He downloads Tsega, enters the code, and can support you every step.',
          'ለባልዎ ወይም ሸሪካዎ ኮድ ያጋሩ። '
          'ጸጋን ያወርዳል፣ ኮዱን ያስገባል፣ እናም ሁሉ ደረጃ ሊደግፍዎ ይችላል።'),
          style: TextStyle(fontSize: 15, height: 1.6,
              color: TColors.white.withOpacity(0.55))),
      const SizedBox(height: 32),

      // What partner can see
      _PermissionPreview(lang: lang),
      const SizedBox(height: 28),

      // Generate / show code
      if (invite == null)
        GestureDetector(
          onTap: onGenerate,
          child: Container(
            width: double.infinity, height: 56,
            decoration: BoxDecoration(
              gradient: TGradients.gradPink,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                color: TColors.pink500.withOpacity(0.3),
                blurRadius: 20, offset: const Offset(0, 8))]),
            child: Center(child: Text(
              lang.s('Generate Invitation Code', 'የጋብዣ ኮድ ፍጠሩ'),
              style: const TextStyle(color: TColors.white,
                  fontSize: 16, fontWeight: FontWeight.w700)))),
        )
      else
        _CodeDisplay(invite: invite!, lang: lang),
    ],
  );
}

class _PermissionPreview extends StatelessWidget {
  final LanguageProvider lang;
  const _PermissionPreview({required this.lang});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TColors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TColors.white.withOpacity(0.08))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(lang.s('Your partner will see:', 'ሸሪካዎ ምን ያያሉ:'),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                  color: TColors.white.withOpacity(0.4),
                  letterSpacing: 0.5)),
          const SizedBox(height: 12),
          ...[
            (true,  lang.s('Your current week or life stage', 'ወቅታዊ ሳምንት ወይም ደረጃ')),
            (true,  lang.s('Danger signs — always on', 'የአደጋ ምልክቶች — ሁልጊዜ')),
            (true,  lang.s('ANC appointment dates', 'ANC ቀጠሮ ቀናት')),
            (true,  lang.s('Your mood today (you can turn off)', 'ዛሬ ስሜት (ማጥፋት ይቻላሉ)')),
            (false, lang.s('Specific symptoms — OFF by default', 'ዝርዝር ምልክቶች — ነሱ ሆነው ተከልክሏል')),
            (false, lang.s('Lab results — OFF by default', 'የላብ ውጤቶች — ነሱ ሆነው ተከልክሏል')),
            (false, lang.s('Weight — OFF by default', 'ክብደት — ነሱ ሆነው ተከልክሏል')),
          ].map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Icon(item.$1
                  ? Icons.check_circle_rounded
                  : Icons.remove_circle_outline_rounded,
                  color: item.$1 ? TColors.green500 : TColors.gray,
                  size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(item.$2,
                  style: TextStyle(fontSize: 13,
                      color: item.$1
                          ? TColors.white
                          : TColors.white.withOpacity(0.35)))),
            ]),
          )),
          const SizedBox(height: 8),
          Text(lang.s(
              'You control everything. Change permissions anytime.',
              'ሁሉንም ነገር ይቆጣጠራሉ። ፈቃዶቹን በማንኛውም ጊዜ ይቀይሩ።'),
              style: TextStyle(fontSize: 11,
                  color: TColors.teal300.withOpacity(0.7))),
        ]),
      ),
    ),
  );
}

class _CodeDisplay extends StatelessWidget {
  final PartnerInvite invite;
  final LanguageProvider lang;
  const _CodeDisplay({required this.invite, required this.lang});

  @override
  Widget build(BuildContext context) => Column(children: [
    // Code card
    ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              TColors.pink500.withOpacity(0.15),
              TColors.teal500.withOpacity(0.10),
            ]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: TColors.pink500.withOpacity(0.3))),
          child: Column(children: [
            Text(lang.s('Your invitation code', 'የጋብዣ ኮድዎ'),
                style: TextStyle(fontSize: 12,
                    color: TColors.white.withOpacity(0.4),
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text(invite.code,
                style: const TextStyle(
                    fontSize: 42, fontWeight: FontWeight.w800,
                    color: TColors.white, letterSpacing: 8)),
            const SizedBox(height: 8),
            Text(lang.s(
                'Valid for 48 hours',
                'ለ48 ሰዓታት ሊ valid ነው'),
                style: TextStyle(fontSize: 11,
                    color: TColors.white.withOpacity(0.35),
                    fontFamily: 'monospace')),
          ]),
        ),
      ),
    ),
    const SizedBox(height: 16),

    // Share options
    Row(children: [
      Expanded(child: _ShareBtn(
        icon: Icons.copy_rounded,
        label: lang.s('Copy Code', 'ኮድ ቅዳ'),
        color: TColors.teal500,
        onTap: () {
          Clipboard.setData(ClipboardData(text: invite.code));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(lang.s('Code copied!', 'ኮድ ተቀድቷል!')),
            backgroundColor: TColors.teal500));
        },
      )),
      const SizedBox(width: 12),
      Expanded(child: _ShareBtn(
        icon: Icons.share_rounded,
        label: lang.s('Share Link', 'ሊንክ አጋሩ'),
        color: TColors.pink500,
        onTap: () {
          Clipboard.setData(ClipboardData(text: invite.qrData));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(lang.s('Link copied!', 'ሊንክ ተቀድቷል!')),
            backgroundColor: TColors.pink500));
        },
      )),
    ]),
    const SizedBox(height: 12),

    // QR code (placeholder)
    Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        const Icon(Icons.qr_code_2_rounded, size: 120, color: TColors.dark),
        const SizedBox(height: 8),
        Text(invite.code,
            style: const TextStyle(fontSize: 14, color: TColors.dark,
                fontWeight: FontWeight.w800, letterSpacing: 4)),
        Text(lang.s('Scan to join as partner', 'ሸሪካ ለመሆን ቃኙ'),
            style: TextStyle(fontSize: 11, color: TColors.dark.withOpacity(0.5))),
      ]),
    ),
  ]);
}

class _ShareBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ShareBtn({required this.icon, required this.label,
      required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3))),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color,
            fontWeight: FontWeight.w700, fontSize: 13)),
      ]),
    ),
  );
}

// ── LINKED VIEW (partner already joined) ─────────────────────────
class _LinkedView extends StatelessWidget {
  final LanguageProvider lang;
  final PartnerProvider partner;
  const _LinkedView({required this.lang, required this.partner});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Connected status
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            TColors.green500.withOpacity(0.12),
            TColors.teal500.withOpacity(0.08),
          ]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: TColors.green500.withOpacity(0.3))),
        child: Row(children: [
          const Icon(Icons.favorite_rounded,
              color: TColors.green500, size: 32),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(lang.s('Partner connected ✓', 'ሸሪካ ተሳስሯል ✓'),
                style: const TextStyle(fontSize: 16,
                    color: TColors.green500, fontWeight: FontWeight.w700)),
            Text(lang.s('He can see your health journey',
                'ጤና ጉዞዎን ማየት ይችላል'),
                style: TextStyle(fontSize: 13,
                    color: TColors.white.withOpacity(0.5))),
          ]),
        ]),
      ),
      const SizedBox(height: 28),

      // Privacy controls
      Text(lang.s('Privacy Controls', 'የግልነት ቁጥጥሮች'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
              color: TColors.white)),
      Text(lang.s('Choose what your partner can see',
          'ሸሪካዎ ምን ማየት እንደሚችሉ ይምረጡ'),
          style: TextStyle(fontSize: 13,
              color: TColors.white.withOpacity(0.4))),
      const SizedBox(height: 20),

      ...[
        (PartnerPermission.mood,       Icons.mood_rounded,
         lang.s('Mood score', 'የስሜት ነጥብ'), TColors.pink500),
        (PartnerPermission.symptoms,   Icons.sick_rounded,
         lang.s('Specific symptoms', 'ዝርዝር ምልክቶች'), TColors.statusYellow),
        (PartnerPermission.labResults, Icons.science_rounded,
         lang.s('Lab results', 'የላብ ውጤቶች'), TColors.blue500),
        (PartnerPermission.weight,     Icons.monitor_weight_rounded,
         lang.s('Weight', 'ክብደት'), TColors.teal500),
        (PartnerPermission.cycleDetails, Icons.water_drop_rounded,
         lang.s('Cycle details', 'ዑደት ዝርዝሮች'), TColors.pink500),
      ].map((item) => _PermissionToggle(
        permission: item.$1,
        icon: item.$2,
        label: item.$3,
        color: item.$4,
        value: partner.link?.can(item.$1) ?? false,
        lang: lang,
        onChange: (v) => partner.updatePermission(item.$1, v),
      )),
    ],
  );
}

class _PermissionToggle extends StatelessWidget {
  final PartnerPermission permission;
  final IconData icon;
  final String label;
  final Color color;
  final bool value;
  final LanguageProvider lang;
  final ValueChanged<bool> onChange;
  const _PermissionToggle({
    required this.permission, required this.icon,
    required this.label, required this.color,
    required this.value, required this.lang, required this.onChange,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: value
              ? color.withOpacity(0.08)
              : TColors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: value
                ? color.withOpacity(0.25)
                : TColors.white.withOpacity(0.07))),
        child: Row(children: [
          Icon(icon, color: value ? color : TColors.white.withOpacity(0.3),
              size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label,
              style: TextStyle(fontSize: 14,
                  color: value ? TColors.white : TColors.white.withOpacity(0.4),
                  fontWeight: FontWeight.w600))),
          Switch(
            value: value,
            onChanged: onChange,
            activeColor: color,
            activeTrackColor: color.withOpacity(0.25),
            inactiveThumbColor: TColors.white.withOpacity(0.3),
            inactiveTrackColor: TColors.white.withOpacity(0.08),
          ),
        ]),
      ),
    ),
  );
}

// ── SHARED ───────────────────────────────────────────────────────
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
