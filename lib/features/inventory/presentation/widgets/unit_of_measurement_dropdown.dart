import 'package:flutter/material.dart';

enum UnitOfMeasurement {
  pcs,
  kg,
  g,
  L,
  ml,
  custom,
}

class UnitOfMeasurementDropdown extends StatelessWidget {
  final UnitOfMeasurement selectedUnit;
  final ValueChanged<UnitOfMeasurement> onUnitChanged;

  const UnitOfMeasurementDropdown({
    super.key,
    required this.selectedUnit,
    required this.onUnitChanged,
  });

  String _getUnitLabel(UnitOfMeasurement unit) {
    switch (unit) {
      case UnitOfMeasurement.pcs:
        return 'pcs';
      case UnitOfMeasurement.kg:
        return 'kg';
      case UnitOfMeasurement.g:
        return 'g';
      case UnitOfMeasurement.L:
        return 'L';
      case UnitOfMeasurement.ml:
        return 'ml';
      case UnitOfMeasurement.custom:
        return 'Custom';
    }
  }

  IconData _getUnitIcon(UnitOfMeasurement unit) {
    switch (unit) {
      case UnitOfMeasurement.pcs:
        return Icons.inventory_2;
      case UnitOfMeasurement.kg:
        return Icons.scale;
      case UnitOfMeasurement.g:
        return Icons.line_weight;
      case UnitOfMeasurement.L:
        return Icons.opacity;
      case UnitOfMeasurement.ml:
        return Icons.science;
      case UnitOfMeasurement.custom:
        return Icons.edit;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = UnitOfMeasurement.values;

    return DropdownButton<UnitOfMeasurement>(
      value: selectedUnit,
      onChanged: onUnitChanged,
      icon: const Icon(Icons.expand_more, size: 16),
      dropdownColor: const Color(0xFF9CA3AF),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 2,
        side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      items: items.map((unit) {
        return DropdownMenuItem(
          value: unit,
          child: Row(
            children: [
              Icon(
                _getUnitIcon(unit),
                size: 16,
                color: const Color(0xFF4F46E5),
              ),
              const SizedBox(width: 12),
              Text(
                _getUnitLabel(unit),
                style: const TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF111827),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
