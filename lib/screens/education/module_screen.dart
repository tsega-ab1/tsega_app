import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/providers/language_provider.dart';
import '../../models/models.dart';
import '../../services/storage_service.dart';
import '../../widgets/common/gradient_button.dart';
import '../../overlays/badge_overlay.dart';
import 'quiz_screen.dart';

class ModuleScreen extends StatefulWidget {
  final EducationModule module;
  const ModuleScreen({super.key, required this.module});
  @override
  State<ModuleScreen> createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  final _scrollCtrl = ScrollController();
  double _readProgress = 0;
  bool _readComplete = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    final pos = _scrollCtrl.position;
    final progress = pos.pixels / pos.maxScrollExtent;
    setState(() {
      _readProgress = progress.clamp(0, 1);
      if (_readProgress > 0.9) _readComplete = true;
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: TColors.cream,
      body: Stack(children: [
        CustomScrollView(
          controller: _scrollCtrl,
          slivers: [
            // Module hero app bar
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded,
                    color: TColors.white)),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                      gradient: widget.module.gradient),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),
                      Icon(widget.module.icon,
                          color: TColors.white, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        lang.isAmharic
                            ? widget.module.titleAm
                            : widget.module.titleEn,
                        style: const TextStyle(
                            color: TColors.white, fontSize: 20,
                            fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lang.isAmharic
                            ? widget.module.categoryAm
                            : widget.module.categoryEn,
                        style: TextStyle(
                            color: TColors.white.withOpacity(0.8),
                            fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),

            // Read progress
            SliverToBoxAdapter(
              child: LinearProgressIndicator(
                value: _readProgress,
                backgroundColor: TColors.border,
                color: TColors.teal500,
                minHeight: 3,
              ),
            ),

            // Module content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Duration badge
                    Row(children: [
                      const Icon(Icons.timer_outlined,
                          color: TColors.gray, size: 16),
                      const SizedBox(width: 6),
                      Text(widget.module.duration,
                          style: TTextStyles.bodySmall),
                      const Spacer(),
                      if (widget.module.completed)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: TColors.green50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: TColors.green300),
                          ),
                          child: Row(children: [
                            const Icon(Icons.check_circle_rounded,
                                color: TColors.green500, size: 14),
                            const SizedBox(width: 4),
                            Text(lang.completed,
                                style: const TextStyle(
                                    color: TColors.green700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ]),
                        ),
                    ]),
                    const SizedBox(height: 24),

                    // Content
                    Text(
                      lang.isAmharic
                          ? widget.module.contentAm
                          : widget.module.contentEn,
                      style: TTextStyles.bodyLarge.copyWith(height: 1.8),
                    ),
                    const SizedBox(height: 100), // space for button
                  ],
                ),
              ),
            ),
          ],
        ),

        // Take quiz button
        if (_readComplete)
          Positioned(
            bottom: 24, left: 24, right: 24,
            child: GradientButton(
              label: lang.quiz,
              gradient: widget.module.gradient,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) =>
                      QuizScreen(module: widget.module))),
            ),
          ),
      ]),
    );
  }
}
