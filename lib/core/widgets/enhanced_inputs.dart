import 'package:flutter/material.dart';
import '../theme/enhanced_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';

/// Enhanced input system for professional yet friendly forms
///
/// Features:
/// - Clear focus states with subtle shadows
/// - Helpful validation messages
/// - Generous touch targets
/// - Accessible labels
/// - Smooth animations

/// Modern text field with professional styling
class EnhancedTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final void Function()? onTap;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final int? maxLines;
  final int? maxLength;
  final bool isRequired;
  final String? helperText;
  final String? initialValue;

  const EnhancedTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.maxLines = 1,
    this.maxLength,
    this.isRequired = false,
    this.helperText,
    this.initialValue,
  });

  @override
  State<EnhancedTextField> createState() => _EnhancedTextFieldState();
}

class _EnhancedTextFieldState extends State<EnhancedTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: EnhancedTheme.labelMedium.copyWith(
                  color: EnhancedTheme.getTextColor(context),
                ),
              ),
              if (widget.isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: EnhancedTheme.labelMedium.copyWith(
                    color: EnhancedTheme.error,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: EnhancedTheme.spacingXXS),
        ],
        Container(
          decoration: BoxDecoration(
            color: widget.enabled
                ? EnhancedTheme.getCardColor(context)
                : EnhancedTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(EnhancedTheme.radiusMedium),
            border: Border.all(
              color: _isFocused
                  ? EnhancedTheme.primary.withValues(alpha: 0.5)
                  : EnhancedTheme.border.withValues(alpha: 0.5),
              width: _isFocused ? 2 : 1,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: EnhancedTheme.primary.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            enabled: widget.enabled,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onSaved: widget.onSaved,
            onTap: widget.onTap,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            focusNode: _focusNode,
            initialValue: widget.initialValue,
            style: EnhancedTheme.bodyMedium.copyWith(
              color: EnhancedTheme.getTextColor(context),
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: EnhancedTheme.bodyMedium.copyWith(
                color: EnhancedTheme.getSecondaryTextColor(context),
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? EnhancedTheme.primary
                          : EnhancedTheme.getSecondaryTextColor(context),
                      size: 20,
                    )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? GestureDetector(
                      onTap: widget.onSuffixIconTap,
                      child: Icon(
                        widget.suffixIcon,
                        color: EnhancedTheme.getSecondaryTextColor(context),
                        size: 20,
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: EnhancedTheme.spacingSM,
                vertical: EnhancedTheme.spacingSM,
              ),
              counterText: '',
            ),
          ),
        ).animate().fadeIn(duration: 200.ms),
        if (widget.helperText != null) ...[
          const SizedBox(height: EnhancedTheme.spacingXXS),
          Text(
            widget.helperText!,
            style: EnhancedTheme.bodySmall.copyWith(
              color: EnhancedTheme.getSecondaryTextColor(context),
            ),
          ),
        ],
      ],
    );
  }
}

/// Modern search field with clear button
class EnhancedSearchField extends StatefulWidget {
  final String? hint;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextEditingController? controller;
  final bool autoFocus;
  final Color? backgroundColor;

  const EnhancedSearchField({
    super.key,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.autoFocus = false,
    this.backgroundColor,
  });

  @override
  State<EnhancedSearchField> createState() => _EnhancedSearchFieldState();
}

class _EnhancedSearchFieldState extends State<EnhancedSearchField> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? EnhancedTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(EnhancedTheme.radiusMedium),
        border: Border.all(
          color: EnhancedTheme.border.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _controller,
        autofocus: widget.autoFocus,
        onChanged: (value) {
          widget.onChanged?.call(value);
          setState(() {
            _hasText = value.isNotEmpty;
          });
        },
        onSubmitted: widget.onSubmitted,
        style: EnhancedTheme.bodyMedium.copyWith(
          color: EnhancedTheme.getTextColor(context),
        ),
        decoration: InputDecoration(
          hintText: widget.hint ?? 'Cari...',
          hintStyle: EnhancedTheme.bodyMedium.copyWith(
            color: EnhancedTheme.getSecondaryTextColor(context),
          ),
          prefixIcon: Icon(
            Icons.search_outlined,
            color: EnhancedTheme.getSecondaryTextColor(context),
            size: 20,
          ),
          suffixIcon: _hasText
              ? GestureDetector(
                  onTap: () {
                    _controller.clear();
                    widget.onChanged?.call('');
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: EnhancedTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(EnhancedTheme.radiusSmall),
                    ),
                    child: Icon(
                      Icons.close,
                      color: EnhancedTheme.getSecondaryTextColor(context),
                      size: 16,
                    ),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: EnhancedTheme.spacingSM,
            vertical: EnhancedTheme.spacingSM,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

/// Modern dropdown with enhanced styling
class EnhancedDropdown<T> extends StatelessWidget {
  final String? label;
  final T? value;
  final List<DropdownMenuItem<T>>? items;
  final void Function(T?)? onChanged;
  final String? hint;
  final IconData? prefixIcon;
  final bool isRequired;

  const EnhancedDropdown({
    super.key,
    this.label,
    required this.value,
    required this.items,
    this.onChanged,
    this.hint,
    this.prefixIcon,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: EnhancedTheme.labelMedium.copyWith(
                  color: EnhancedTheme.getTextColor(context),
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: EnhancedTheme.labelMedium.copyWith(
                    color: EnhancedTheme.error,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: EnhancedTheme.spacingXXS),
        ],
        Container(
          decoration: BoxDecoration(
            color: EnhancedTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(EnhancedTheme.radiusMedium),
            border: Border.all(
              color: EnhancedTheme.border.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: EnhancedTheme.spacingSM),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              hint: Text(
                hint ?? 'Pilih...',
                style: EnhancedTheme.bodyMedium.copyWith(
                  color: EnhancedTheme.getSecondaryTextColor(context),
                ),
              ),
              style: EnhancedTheme.bodyMedium.copyWith(
                color: EnhancedTheme.getTextColor(context),
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: EnhancedTheme.getSecondaryTextColor(context),
              ),
              isExpanded: true,
              dropdownColor: EnhancedTheme.getCardColor(context),
              borderRadius: BorderRadius.circular(EnhancedTheme.radiusMedium),
            ),
          ),
        ),
      ],
    );
  }
}

/// Modern switch with enhanced styling
class EnhancedSwitch extends StatelessWidget {
  final String? label;
  final bool value;
  final void Function(bool)? onChanged;
  final String? subtitle;
  final IconData? icon;

  const EnhancedSwitch({
    super.key,
    this.label,
    required this.value,
    this.onChanged,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: value
                  ? EnhancedTheme.success.withValues(alpha: 0.1)
                  : EnhancedTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(EnhancedTheme.radiusSmall),
            ),
            child: Icon(
              icon,
              color: value ? EnhancedTheme.success : EnhancedTheme.getSecondaryTextColor(context),
              size: 20,
            ),
          ),
          const SizedBox(width: EnhancedTheme.spacingSM),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label != null)
                Text(
                  label!,
                  style: EnhancedTheme.titleMedium.copyWith(
                    color: EnhancedTheme.getTextColor(context),
                  ),
                ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: EnhancedTheme.bodySmall.copyWith(
                    color: EnhancedTheme.getSecondaryTextColor(context),
                  ),
                ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: EnhancedTheme.success.withValues(alpha: 0.5),
          activeThumbColor: EnhancedTheme.success,
        ),
      ],
    );
  }
}
