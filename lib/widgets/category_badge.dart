import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class CategoryBadge extends StatelessWidget {
  final String kategori;

  const CategoryBadge({super.key, required this.kategori});

  Color get _bgColor {
    switch (kategori) {
      case 'Dokumen':
        return AppColors.categoryDokumen;
      case 'Pakaian':
        return AppColors.categoryPakaian;
      case 'Peralatan Mandi':
        return AppColors.categoryMandi;
      case 'Elektronik':
        return AppColors.categoryElektronik;
      case 'Obat-obatan':
        return AppColors.categoryObat;
      default:
        return AppColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        kategori,
        style: AppTextStyles.captionBold.copyWith(color: _bgColor),
      ),
    );
  }
}
