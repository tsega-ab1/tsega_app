import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class CountUpWidget extends StatefulWidget {
  final int end;
  final Color color;
  final double fontSize;
  const CountUpWidget({super.key, required this.end, required this.color, this.fontSize = 28});
  @override
  State<CountUpWidget> createState() => _CountUpWidgetState();
}

class _CountUpWidgetState extends State<CountUpWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _anim = Tween<double>(begin: 0, end: widget.end.toDouble())
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Text(
      _anim.value.toInt().toString(),
      style: TextStyle(fontSize: widget.fontSize,
          fontWeight: FontWeight.w800, color: widget.color),
    ),
  );
}
