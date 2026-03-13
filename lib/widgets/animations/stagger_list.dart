import 'package:flutter/material.dart';
import 'slide_up.dart';

class StaggerList extends StatelessWidget {
  final List<Widget> children;
  final int delayMs;
  const StaggerList({super.key, required this.children, this.delayMs = 80});

  @override
  Widget build(BuildContext context) => Column(
    children: List.generate(children.length, (i) => SlideUpWidget(
      delay: Duration(milliseconds: i * delayMs),
      child: children[i],
    )),
  );
}
