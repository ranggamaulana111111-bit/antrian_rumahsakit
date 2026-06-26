import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class PriorityBadge extends StatelessWidget {
  final String prioritas;

  const PriorityBadge({super.key, required this.prioritas});

  Color get _color {
    switch (prioritas) {
      case 'Tinggi':
        return AppColors.priorityHigh;
      case 'Sedang':
        return AppColors.priorityMedium;
      case 'Rendah':
        return AppColors.priorityLow;
      default:
        return AppColors.textHint;
    }
  }

  IconData get _icon {
    switch (prioritas) {
      case 'Tinggi':
        return Icons.arrow_upward_rounded;
      case 'Sedang':
        return Icons.remove_rounded;
      case 'Rendah':
        return Icons.arrow_downward_rounded;
      default:
        return Icons.remove_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12, color: _color),
          const SizedBox(width: 4),
          Text(
            prioritas,
            style: AppTextStyles.captionBold.copyWith(color: _color),
          ),
        ],
      ),
    );
  }
}
