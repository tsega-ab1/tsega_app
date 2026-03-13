import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';

class KickCounterOverlay extends StatefulWidget {
  const KickCounterOverlay({super.key});
  @override
  State<KickCounterOverlay> createState() => _KickCounterOverlayState();
}

class _KickCounterOverlayState extends State<KickCounterOverlay>
    with SingleTickerProviderStateMixin {
  int _count = 0;
  final int _target = 10;
  final List<DateTime> _times = [];
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1.0, end: 0.9)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _tap() async {
    if (_done) return;
    await _ctrl.forward();
    await _ctrl.reverse();
    setState(() {
      _count++;
      _times.add(DateTime.now());
      if (_count >= _target) _done = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final elapsed = _times.length >= 2
        ? _times.last.difference(_times.first).inMinutes : 0;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
          child: Row(children: [
            const Icon(Icons.touch_app_rounded, color: TColors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(child: Text(lang.kickCounter,
                style: const TextStyle(fontSize: 18,
                    color: TColors.white, fontWeight: FontWeight.w700))),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close_rounded, color: TColors.white)),
          ]),
        ),
        Expanded(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Count display
            Text('$_count / $_target',
                style: const TextStyle(fontSize: 48,
                    fontWeight: FontWeight.w800, color: TColors.dark)),
            Text(lang.s('kicks recorded', 'ምቶች ተመዝግቧል'),
                style: const TextStyle(color: TColors.gray, fontSize: 14)),
            const SizedBox(height: 8),
            if (_times.length >= 2)
              Text(lang.s('Duration: $elapsed min', 'ጊዜ: $elapsed ደቂቃ'),
                  style: const TextStyle(color: TColors.teal500,
                      fontWeight: FontWeight.w600)),
            const SizedBox(height: 40),
            // Big tap button
            ScaleTransition(
              scale: _scale,
              child: GestureDetector(
                onTap: _tap,
                child: Container(
                  width: 180, height: 180,
                  decoration: BoxDecoration(
                    gradient: _done ? TGradients.gradGreen : TGradients.gradTeal,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(
                      color: (_done ? TColors.green500 : TColors.teal500)
                          .withOpacity(0.4),
                      blurRadius: 30, spreadRadius: 4)]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_done ? Icons.check_rounded : Icons.touch_app_rounded,
                          color: TColors.white, size: 56),
                      const SizedBox(height: 8),
                      Text(_done
                          ? lang.s('Done! 🎉', 'ተጠናቅቋል! 🎉')
                          : lang.s('Tap to Count', 'ለመቁጠር ይጫኑ'),
                          style: const TextStyle(color: TColors.white,
                              fontWeight: FontWeight.w700, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_done)
              Text(
                lang.s('Great! 10 kicks in $elapsed minutes. Baby is active!',
                    'ጥሩ! $elapsed ደቂቃ ውስጥ 10 ምቶች። ልጅ ንቁ ነው!'),
                style: const TextStyle(
                    color: TColors.green700, fontSize: 14, height: 1.5),
                textAlign: TextAlign.center),
            if (!_done)
              Text(lang.s(
                  '10 kicks in 2 hours is normal. Call doctor if baby is quiet.',
                  'በ2 ሰዓት 10 ምቶች ተለምዶ ነው። ልጅ ዝም ካለ ዶክተርዎን ይደውሉ።'),
                  style: const TextStyle(fontSize: 12, color: TColors.gray),
                  textAlign: TextAlign.center),
          ],
        )),
        if (!_done)
          Padding(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () => setState(() { _count = 0; _times.clear(); _done = false; }),
              child: Text(lang.s('Reset', 'ዳግም ጀምር'),
                  style: const TextStyle(
                      color: TColors.gray, fontWeight: FontWeight.w600)),
            ),
          ),
        const SizedBox(height: 16),
      ]),
    );
  }
}
