import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'modern_button.dart';

/// Stage of backup/restore operation
enum BackupStage {
  preparing,
  collecting,
  compressing,
  uploading,
  downloading,
  extracting,
  restoring,
  finalizing,
  complete,
}

/// Extension to get display text for stages
extension BackupStageExtension on BackupStage {
  String get label {
    switch (this) {
      case BackupStage.preparing:
        return 'Preparing';
      case BackupStage.collecting:
        return 'Collecting Data';
      case BackupStage.compressing:
        return 'Compressing';
      case BackupStage.uploading:
        return 'Uploading';
      case BackupStage.downloading:
        return 'Downloading';
      case BackupStage.extracting:
        return 'Extracting';
      case BackupStage.restoring:
        return 'Restoring';
      case BackupStage.finalizing:
        return 'Finalizing';
      case BackupStage.complete:
        return 'Complete';
    }
  }

  IconData get icon {
    switch (this) {
      case BackupStage.preparing:
        return Icons.settings;
      case BackupStage.collecting:
        return Icons.folder_open;
      case BackupStage.compressing:
        return Icons.compress;
      case BackupStage.uploading:
        return Icons.cloud_upload;
      case BackupStage.downloading:
        return Icons.cloud_download;
      case BackupStage.extracting:
        return Icons.unarchive;
      case BackupStage.restoring:
        return Icons.restore;
      case BackupStage.finalizing:
        return Icons.check_circle;
      case BackupStage.complete:
        return Icons.done_all;
    }
  }
}

/// Full-screen modal dialog for backup/restore progress
class BackupProgressDialog extends StatefulWidget {
  final String title;
  final String? currentFile;
  final double progress; // 0.0 to 1.0
  final BackupStage currentStage;
  final List<BackupStage> completedStages;
  final VoidCallback? onCancel;
  final bool showEstimatedTime;
  final Duration? estimatedTimeRemaining;

  const BackupProgressDialog({
    super.key,
    required this.title,
    this.currentFile,
    required this.progress,
    required this.currentStage,
    this.completedStages = const [],
    this.onCancel,
    this.showEstimatedTime = true,
    this.estimatedTimeRemaining,
  });

  @override
  State<BackupProgressDialog> createState() => BackupProgressDialogState();

  /// Show the dialog
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? currentFile,
    required double progress,
    required BackupStage currentStage,
    List<BackupStage> completedStages = const [],
    VoidCallback? onCancel,
    bool showEstimatedTime = true,
    Duration? estimatedTimeRemaining,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackupProgressDialog(
        title: title,
        currentFile: currentFile,
        progress: progress,
        currentStage: currentStage,
        completedStages: completedStages,
        onCancel: onCancel,
        showEstimatedTime: showEstimatedTime,
        estimatedTimeRemaining: estimatedTimeRemaining,
      ),
    );
  }
}

class BackupProgressDialogState extends State<BackupProgressDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    ));
    _progressController.forward();
  }

  @override
  void didUpdateWidget(BackupProgressDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress != oldWidget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOut,
      ));
      _progressController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allStages = [
      BackupStage.preparing,
      BackupStage.collecting,
      BackupStage.compressing,
      BackupStage.uploading,
      BackupStage.complete,
    ];

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.currentStage.icon,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getTextPrimaryColor(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.currentStage.label,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Progress Circle
            Center(
              child: SizedBox(
                width: 120,
                height: 120,
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        // Background circle
                        CircularProgressIndicator(
                          value: 1.0,
                          backgroundColor: AppTheme.getBorderColor(context),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.getBorderColor(context),
                          ),
                          strokeWidth: 8,
                        ),
                        // Progress circle
                        CircularProgressIndicator(
                          value: _progressAnimation.value,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryColor,
                          ),
                          strokeWidth: 8,
                        ),
                        // Percentage text
                        Center(
                          child: Text(
                            '${(widget.progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getTextPrimaryColor(context),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Current file info
            if (widget.currentFile != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.insert_drive_file,
                      size: 16,
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.currentFile!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Stage checklist
            _buildStageChecklist(allStages),
            const SizedBox(height: 16),

            // Estimated time
            if (widget.showEstimatedTime &&
                widget.estimatedTimeRemaining != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Estimated time: ${_formatDuration(widget.estimatedTimeRemaining!)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Cancel button
            if (widget.onCancel != null && widget.progress < 1.0)
              ModernSecondaryButton(
                text: 'Cancel',
                onPressed: widget.onCancel,
                isFullWidth: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageChecklist(List<BackupStage> stages) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
          const SizedBox(height: 12),
          ...stages.map((stage) {
            final isCompleted = widget.completedStages.contains(stage);
            final isCurrent = widget.currentStage == stage;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  // Status icon
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: isCompleted
                        ? Icon(
                            Icons.check_circle,
                            size: 20,
                            color: AppTheme.successColor,
                          )
                        : isCurrent
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.primaryColor,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.radio_button_unchecked,
                                size: 20,
                                color: AppTheme.textTertiary,
                              ),
                  ),
                  const SizedBox(width: 12),
                  // Stage label
                  Expanded(
                    child: Text(
                      stage.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                        color: isCompleted
                            ? AppTheme.successColor
                            : isCurrent
                                ? AppTheme.getTextPrimaryColor(context)
                                : AppTheme.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}
