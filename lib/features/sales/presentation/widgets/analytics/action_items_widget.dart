import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';

/// Action Items Widget
class ActionItemsWidget extends StatelessWidget {
  final List<String> actions;

  const ActionItemsWidget({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.warningColor,
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        border: Border.all(
          color: Colors.black,
          width: 4,
        ),
        boxShadow: NeoBrutalTheme.chunkyShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                  border: Border.all(
                    color: Colors.black,
                    width: 3,
                  ),
                ),
                child: Icon(
                  Icons.task_alt,
                  size: 24,
                  color: AppTheme.warningColor,
                ),
              ),
              SizedBox(width: NeoBrutalTheme.spaceSM),
              Text(
                'Rekomendasi Tindakan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: NeoBrutalTheme.spaceMD),
          ...actions.map(
            (action) => Padding(
              padding: EdgeInsets.only(bottom: NeoBrutalTheme.spaceSM),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      Icons.arrow_right,
                      size: 18,
                      color: AppTheme.warningColor,
                    ),
                  ),
                  SizedBox(width: NeoBrutalTheme.spaceSM),
                  Expanded(
                    child: Text(
                      action,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}