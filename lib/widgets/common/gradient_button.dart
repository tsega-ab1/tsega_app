import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;
  final bool loading;
  final Color textColor;
  final double height;

  const GradientButton({
    super.key,
    required this.label,
    required this.gradient,
    required this.onTap,
    this.loading = false,
    this.textColor = TColors.white,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: loading ? null : gradient,
          color: loading ? TColors.border : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: loading ? null : [
            BoxShadow(
              color: TColors.teal700.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(
                    color: TColors.teal500, strokeWidth: 2.5))
              : Text(label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  )),
        ),
      ),
    );
  }
}
