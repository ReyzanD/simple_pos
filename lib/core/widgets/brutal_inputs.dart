import 'package:flutter/material.dart';
import '../theme/neo_brutal_theme.dart';
import 'package:simple_pos/l10n/app_localizations.dart';

/// Neo-Brutalist Search Field
///
/// Bold, chunky search with 4px border and no blur
class BrutalSearchField extends StatefulWidget {
  final String? hint;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextEditingController? controller;
  final Color? backgroundColor;
  final Color? textColor;
  final bool autoFocus;

  const BrutalSearchField({
    super.key,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.backgroundColor,
    this.textColor,
    this.autoFocus = false,
  });

  @override
  State<BrutalSearchField> createState() => _BrutalSearchFieldState();
}

class _BrutalSearchFieldState extends State<BrutalSearchField> {
  late TextEditingController _controller;
  bool _hasText = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
    widget.onChanged?.call(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        widget.backgroundColor ??
        NeoBrutalTheme.getSurfaceVariantColor(context);
    final txtColor = widget.textColor ?? NeoBrutalTheme.getTextColor(context);
    final borderColor = NeoBrutalTheme.getBorderColor(context);
    final hintColor = isDark ? Colors.white38 : Colors.black54;

    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          border: Border.all(
            color: _isFocused ? NeoBrutalTheme.primary : borderColor,
            width: _isFocused ? 6 : 4,
          ),
          boxShadow: _isFocused
              ? NeoBrutalTheme.chunkyShadow
              : NeoBrutalTheme.softShadow,
        ),
        child: TextField(
          controller: _controller,
          autofocus: widget.autoFocus,
          onSubmitted: widget.onSubmitted,
          style: NeoBrutalTheme.bodyMedium.copyWith(color: txtColor),
          decoration: InputDecoration(
            hintText:
                widget.hint ?? AppLocalizations.of(context)!.common_search,
            hintStyle: NeoBrutalTheme.bodyMedium.copyWith(color: hintColor),
            prefixIcon: Icon(
              Icons.search,
              color: _isFocused ? NeoBrutalTheme.primary : hintColor,
              size: 24,
            ),
            suffixIcon: _hasText
                ? GestureDetector(
                    onTap: () {
                      _controller.clear();
                      widget.onChanged?.call('');
                      setState(() {
                        _hasText = false;
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: NeoBrutalTheme.error,
                        borderRadius: BorderRadius.circular(
                          NeoBrutalTheme.radiusSmall,
                        ),
                        border: Border.all(color: borderColor, width: 2),
                      ),
                      child: Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: NeoBrutalTheme.spaceMD,
              vertical: NeoBrutalTheme.spaceSM,
            ),
          ),
        ),
      ),
    );
  }
}
