import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';

/// Executive Summary Widget
class ExecutiveSummaryWidget extends StatelessWidget {
  final List<String> summary;

  const ExecutiveSummaryWidget({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.infoColor,
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
                  Icons.summarize,
                  size: 24,
                  color: AppTheme.infoColor,
                ),
              ),
              SizedBox(width: NeoBrutalTheme.spaceSM),
              Text(
                'Ringkasan Eksekutif',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: NeoBrutalTheme.spaceMD),
          ...summary.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: NeoBrutalTheme.spaceSM),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                  SizedBox(width: NeoBrutalTheme.spaceSM),
                  Expanded(
                    child: Text(
                      item,
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