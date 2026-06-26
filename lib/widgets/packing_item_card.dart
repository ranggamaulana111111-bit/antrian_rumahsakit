import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/packing_item.dart';
import 'category_badge.dart';
import 'priority_badge.dart';

class PackingItemCard extends StatelessWidget {
  final PackingItem item;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const PackingItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.statusPacking == 1
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.border.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  item.statusPacking == 1
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 22,
                  color: item.statusPacking == 1
                      ? AppColors.success
                      : AppColors.textHint,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.namaBarang,
                      style: AppTextStyles.bodyTextMedium.copyWith(
                        color: AppColors.textPrimary,
                        decoration: item.statusPacking == 1
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        CategoryBadge(kategori: item.kategori),
                        const SizedBox(width: 8),
                        PriorityBadge(prioritas: item.prioritas),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 40,
                width: 40,
                child: Checkbox(
                  value: item.statusPacking == 1,
                  onChanged: (_) => onToggle(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
