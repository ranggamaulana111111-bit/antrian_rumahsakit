import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class ProgressBar extends StatelessWidget {
  final double percentage;
  final bool showLabel;

  const ProgressBar({
    super.key,
    required this.percentage,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final value = (percentage / 100).clamp(0.0, 1.0);
    final labelColor = percentage >= 100
        ? AppColors.success
        : AppColors.accent;

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage >= 100 ? AppColors.success : AppColors.accent,
              ),
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 12),
          SizedBox(
            width: 52,
            child: Text(
              '${percentage.round()}%',
              style: AppTextStyles.sectionTitle.copyWith(
                color: labelColor,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ],
    );
  }
}
