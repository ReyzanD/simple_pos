import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';

/// Section divider for drawer content
class DrawerSectionDivider extends StatelessWidget {
  final String title;
  final IconData? icon;

  const DrawerSectionDivider({
    super.key,
    required this.title,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: NeoBrutalTheme.spaceMD,
        vertical: NeoBrutalTheme.spaceSM,
      ),
      padding: EdgeInsets.all(NeoBrutalTheme.spaceSM),
      decoration: BoxDecoration(
        color: NeoBrutalTheme.blockBlue, // ✅ Bold blue background
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        border: Border.all(
          color: Colors.black,
          width: 4, // ✅ Bold border
        ),
        boxShadow: NeoBrutalTheme.softShadow,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 18,
                color: Colors.black,
              ),
            ),
            SizedBox(width: NeoBrutalTheme.spaceSM),
          ],
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.black,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
