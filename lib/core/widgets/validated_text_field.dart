import 'dart:async';
import 'package:flutter/material.dart';
import 'package:simple_pos/l10n/app_localizations.dart';

/// Text field with real-time validation and visual feedback
/// Shows error state, success checkmark, and helper text
class ValidatedTextField extends StatefulWidget {
  final String label;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLength;
  final String? helperText;
  final bool enabled;
  final void Function(String)? onChanged;
  final IconData? prefixIcon;
  final int debounceMs;
  final int maxLines;

  const ValidatedTextField({
    required this.label,
    this.validator,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.maxLength,
    this.helperText,
    this.enabled = true,
    this.onChanged,
    this.prefixIcon,
    this.debounceMs = 300,
    this.maxLines = 1,
    super.key,
  });

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  Timer? _debounce;
  String? _errorText;
  late TextEditingController _controller;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    }
    _controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    setState(() {
      _errorText = null;
      _isValid = false;
    });

    _debounce = Timer(Duration(milliseconds: widget.debounceMs), () {
      if (mounted) {
        setState(() {
          _errorText = widget.validator?.call(_controller.text);
          _isValid = _errorText == null && _controller.text.isNotEmpty;
        });
      }
    });

    widget.onChanged?.call(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      value: _errorText ?? _controller.text,
      child: TextField(
        controller: _controller,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        enabled: widget.enabled,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.helperText,
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon)
              : null,
          suffixIcon: _isValid
              ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
              : null,
          errorText: _errorText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
      ),
    );
  }
}

/// Built-in validators for common input types
class FieldValidators {
  FieldValidators._();

  /// Validates that the field is not empty
  static String? required(String? value, BuildContext context) =>
      value?.isEmpty ?? true
      ? AppLocalizations.of(context)!.validator_required
      : null;

  /// Validates email format
  static String? email(String? value, BuildContext context) =>
      value?.contains('@') ?? false
      ? null
      : AppLocalizations.of(context)!.validator_email;

  /// Validates that the value is a positive number
  static String? positiveNumber(String? value, BuildContext context) {
    final num = double.tryParse(value ?? '');
    return (num == null || num <= 0)
        ? AppLocalizations.of(context)!.validator_positive_number
        : null;
  }

  /// Validates non-negative number (zero allowed)
  static String? nonNegativeNumber(String? value, BuildContext context) {
    final num = double.tryParse(value ?? '');
    return (num == null || num < 0)
        ? AppLocalizations.of(context)!.validator_non_negative
        : null;
  }

  /// Validates phone number (at least 10 digits)
  static String? phone(String? value, BuildContext context) {
    final digitsOnly = value?.replaceAll(RegExp(r'[^\d]'), '') ?? '';
    return digitsOnly.length >= 10
        ? null
        : AppLocalizations.of(context)!.validator_phone;
  }

  /// Validates minimum length
  static String? Function(String?) minLen(int min, BuildContext context) {
    return (String? value) {
      return (value?.length ?? 0) < min
          ? AppLocalizations.of(context)!.validator_min_length(min)
          : null;
    };
  }

  /// Validates maximum length
  static String? Function(String?) maxLen(int max, BuildContext context) {
    return (String? value) {
      return (value?.length ?? 0) > max
          ? AppLocalizations.of(context)!.validator_max_length(max)
          : null;
    };
  }

  /// Combines multiple validators
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
