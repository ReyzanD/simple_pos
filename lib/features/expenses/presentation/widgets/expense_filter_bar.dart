import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/modern_card.dart';
import '../../../expenses/domain/constants/expense_categories.dart';

class ExpenseFilterBar extends StatelessWidget {
  final String? selectedCategory;
  final DateTimeRange? dateRange;
  final VoidCallback? onClearFilters;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;

  const ExpenseFilterBar({
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onDateRangeChanged,
    this.dateRange,
    this.onClearFilters,
    super.key,
  });

  String _formatDateRange(DateTimeRange range) {
    final start = '${range.start.day}/${range.start.month}/${range.start.year}';
    final end = '${range.end.day}/${range.end.month}/${range.end.year}';
    return '$start - $end';
  }

  @override
  Widget build(BuildContext context) {
    final hasFilters = selectedCategory != null || dateRange != null;

    return Column(
      children: [
        // Category chips
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              FilterChip(
                label: const Text('Semua'),
                selected: selectedCategory == null,
                onSelected: (_) => onCategoryChanged(null),
                backgroundColor: Colors.grey.withValues(alpha: 0.1),
                selectedColor: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              ...ExpenseCategories.predefined.map((cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat),
                      selected: selectedCategory == cat,
                      onSelected: (_) => onCategoryChanged(
                        selectedCategory == cat ? null : cat,
                      ),
                      backgroundColor: Colors.grey.withValues(alpha: 0.1),
                      selectedColor: AppTheme.primaryColor,
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Date range and clear
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Date range selector
              ModernCard(
                onTap: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                    initialDateRange: dateRange,
                  );
                  if (picked != null) {
                    onDateRangeChanged(picked);
                  }
                },
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      dateRange != null
                          ? _formatDateRange(dateRange!)
                          : 'Pilih Rentang Tanggal',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (hasFilters)
                TextButton.icon(
                  onPressed: () {
                    onCategoryChanged(null);
                    onDateRangeChanged(null);
                    onClearFilters?.call();
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
