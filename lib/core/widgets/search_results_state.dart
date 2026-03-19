import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Header widget for search results that displays:
/// - Result count and query summary
/// - Active filter chips
/// - Clear filters action
/// - Wraps the results content below
class SearchResultsState extends StatelessWidget {
  final int resultCount;
  final String query;
  final List<String> activeFilters;
  final VoidCallback? onClearFilters;
  final bool isLoading;
  final Widget child;

  const SearchResultsState({
    required this.resultCount,
    required this.query,
    this.activeFilters = const [],
    this.onClearFilters,
    this.isLoading = false,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: isLoading
                    ? const Text(
                        'Mencari...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : Text(
                        '$resultCount hasil untuk "$query"',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
              if (activeFilters.isNotEmpty && onClearFilters != null)
                TextButton(
                  onPressed: onClearFilters,
                  child: const Text('Clear Filters'),
                ),
            ],
          ),
        ),
        // Active filters chips
        if (activeFilters.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: activeFilters
                  .map((filter) => Chip(
                        label: Text(filter),
                        backgroundColor:
                            AppTheme.primaryColor.withValues(alpha: 0.1),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: onClearFilters,
                      ))
                  .toList(),
            ),
          ),
        // Content
        Expanded(child: child),
      ],
    );
  }
}
