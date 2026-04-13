import 'package:flutter/material.dart';
import '../theme/neo_brutal_theme.dart';

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
    final bgColor = widget.backgroundColor ?? NeoBrutalTheme.surface;
    final txtColor = widget.textColor ?? Colors.black;

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
            color: _isFocused ? NeoBrutalTheme.primary : Colors.black,
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
          style: NeoBrutalTheme.bodyMedium.copyWith(
            color: txtColor,
          ),
          decoration: InputDecoration(
            hintText: widget.hint ?? 'Search...',
            hintStyle: NeoBrutalTheme.bodyMedium.copyWith(
              color: Colors.black54,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: _isFocused ? NeoBrutalTheme.primary : Colors.black54,
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
                        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
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
