import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';

class BrutalTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color themeColor;
  final String? hintText;
  final String? prefixText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const BrutalTextFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.themeColor,
    this.hintText,
    this.prefixText,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: NeoBrutalTheme.labelLarge.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          color: themeColor,
        ),
        prefixText: prefixText,
        hintText: hintText,
        prefixIcon: _BrutalIconContainer(icon: icon, color: themeColor),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
        border: _border(Colors.black, 3),
        enabledBorder: _border(themeColor.withValues(alpha: 0.3), 3),
        focusedBorder: _border(themeColor, 4),
        errorBorder: _border(AppTheme.errorColor, 4),
      ),
      validator: validator,
    );
  }

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
    borderSide: BorderSide(color: color, width: width),
  );
}

class BrutalDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final IconData prefixIcon;
  final Color color;
  final VoidCallback onAddPressed;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const BrutalDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.prefixIcon,
    required this.color,
    required this.onAddPressed,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      isExpanded: true,
      initialValue: value,
      style: NeoBrutalTheme.bodyLarge.copyWith(
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: NeoBrutalTheme.labelLarge.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          color: color,
        ),
        prefixIcon: _BrutalIconContainer(icon: prefixIcon, color: color),
        suffixIcon: _BrutalSuffixAction(onTap: onAddPressed, color: color),
        filled: true,
        fillColor: Colors.white,
        border: _border(Colors.black, 3),
        enabledBorder: _border(color.withValues(alpha: 0.3), 3),
        focusedBorder: _border(color, 4),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
    borderSide: BorderSide(color: color, width: width),
  );
}

class _BrutalIconContainer extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _BrutalIconContainer({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

class _BrutalSuffixAction extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;
  const _BrutalSuffixAction({required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: NeoBrutalTheme.spaceSM),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Icon(Icons.add_circle_outline, color: color, size: 18),
        ),
      ),
    );
  }
}
