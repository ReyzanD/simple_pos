import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';

enum UnitOfMeasurement {
  pcs,
  box,
  pack,
  karton,
  lusin,
  renteng,
  botol,
  custom,
}

extension UnitOfMeasurementX on UnitOfMeasurement {
  String get label {
    switch (this) {
      case UnitOfMeasurement.pcs:
        return 'Pcs (Pieces)';
      case UnitOfMeasurement.box:
        return 'Box (Kotak)';
      case UnitOfMeasurement.pack:
        return 'Pack (Bungkus)';
      case UnitOfMeasurement.karton:
        return 'Karton (Dus)';
      case UnitOfMeasurement.lusin:
        return 'Lusin (12 Pcs)';
      case UnitOfMeasurement.renteng:
        return 'Renteng';
      case UnitOfMeasurement.botol:
        return 'Botol';
      case UnitOfMeasurement.custom:
        return 'Custom';
    }
  }

  String get shortLabel {
    switch (this) {
      case UnitOfMeasurement.pcs:
        return 'Pcs';
      case UnitOfMeasurement.box:
        return 'Box';
      case UnitOfMeasurement.pack:
        return 'Pack';
      case UnitOfMeasurement.karton:
        return 'Karton';
      case UnitOfMeasurement.lusin:
        return 'Lsn';
      case UnitOfMeasurement.renteng:
        return 'Rtg';
      case UnitOfMeasurement.botol:
        return 'Btl';
      case UnitOfMeasurement.custom:
        return 'Custom';
    }
  }

  IconData get icon {
    switch (this) {
      case UnitOfMeasurement.pcs:
        return Icons.inventory_2;
      case UnitOfMeasurement.box:
        return Icons.inbox;
      case UnitOfMeasurement.pack:
        return Icons.shopping_bag;
      case UnitOfMeasurement.karton:
        return Icons.inventory;
      case UnitOfMeasurement.lusin:
        return Icons.grid_view;
      case UnitOfMeasurement.renteng:
        return Icons.link;
      case UnitOfMeasurement.botol:
        return Icons.liquor;
      case UnitOfMeasurement.custom:
        return Icons.edit;
    }
  }
}

class UnitOfMeasurementDropdown extends StatelessWidget {
  final UnitOfMeasurement? selectedUnit;
  final ValueChanged<UnitOfMeasurement?> onUnitChanged;

  const UnitOfMeasurementDropdown({
    super.key,
    required this.selectedUnit,
    required this.onUnitChanged,
  });

  static OutlineInputBorder _border(Color color, double width) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    const themeColor = AppTheme.infoColor;

    return DropdownButtonFormField<UnitOfMeasurement>(
      isExpanded: true,
      initialValue: selectedUnit,
      onChanged: onUnitChanged,
      style: NeoBrutalTheme.bodyLarge.copyWith(
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        labelText: 'SATUAN',
        labelStyle: NeoBrutalTheme.labelLarge.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          color: themeColor,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(NeoBrutalTheme.radiusSmall),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Icon(
              selectedUnit?.icon ?? Icons.straighten, 
              color: themeColor, 
              size: 22,
            ),
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: NeoBrutalTheme.spaceMD,
          vertical: NeoBrutalTheme.spaceMD,
        ),
        border: _border(Colors.black, 3),
        enabledBorder: _border(themeColor.withValues(alpha: 0.3), 3),
        focusedBorder: _border(themeColor, 4),
      ),
      items: UnitOfMeasurement.values.map((unit) {
        return DropdownMenuItem<UnitOfMeasurement>(
          value: unit,
          child: Row(
            children: [
              Icon(unit.icon, size: 18, color: themeColor),
              const SizedBox(width: 10),
              Text(
                unit.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
