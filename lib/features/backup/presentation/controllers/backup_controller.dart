import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart';
import 'package:simple_pos/core/utils/logger.dart';
import 'package:simple_pos/core/services/backup_service.dart';
import 'package:simple_pos/features/backup/domain/entities/backup_config.dart';
import 'package:simple_pos/features/backup/domain/entities/backup_metadata.dart';
import 'package:simple_pos/core/constants/backup_constants.dart';

/// Progress tracking for backup operations
class BackupProgress {
  final String operation;
  final double progress; // 0.0 to 1.0
  final String? currentStep;
  final int bytesProcessed;
  final int totalBytes;

  const BackupProgress({
    required this.operation,
    required this.progress,
    this.currentStep,
    this.bytesProcessed = 0,
    this.totalBytes = 0,
  });

  /// Get progress percentage
  int get percentage => (progress * 100).round();

  /// Copy with updated values
  BackupProgress copyWith({
    String? operation,
    double? progress,
    String? currentStep,
    int? bytesProcessed,
    int? totalBytes,
  }) {
    return BackupProgress(
      operation: operation ?? this.operation,
      progress: progress ?? this.progress,
      currentStep: currentStep ?? this.currentStep,
      bytesProcessed: bytesProcessed ?? this.bytesProcessed,
      totalBytes: totalBytes ?? this.totalBytes,
    );
  }

  @override
  String toString() =>
      'BackupProgress(operation: $operation, progress: $percentage%, step: $currentStep)';
}

/// Controller for managing backup UI state and operations
class BackupController extends ChangeNotifier {
  final BackupService backupService;

  BackupController({required this.backupService});

  // State
  List<BackupMetadata> _backups = [];
  bool _isLoading = false;
  AppException? _error;
  BackupProgress? _progress;
  Timer? _scheduleTimer;
  BackupMetadata? _selectedBackup;

  // Getters
  List<BackupMetadata> get backups => _backups;
  bool get isLoading => _isLoading;
  AppException? get error => _error;
  bool get hasError => _error != null;
  BackupProgress? get progress => _progress;
  bool get isProcessing => _progress != null;
  BackupMetadata? get selectedBackup => _selectedBackup;
  bool get hasSelection => _selectedBackup != null;

  /// Load all available backups
  Future<void> loadBackups() async {
    try {
      AppLogger.ui('Loading backups', details: 'BackupController');
      _setLoading(true);
      _clearError();

      _backups = await backupService.listBackups();

      AppLogger.info(
        'Backups loaded: ${_backups.length}',
        tag: 'BackupController',
      );
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to load backups', error: e, tag: 'BackupController');
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal memuat daftar backup',
        operation: 'loadBackups',
        originalError: e,
        stackTrace: stackTrace,
      ));
    } finally {
      _setLoading(false);
    }
  }

  /// Create a manual backup with given configuration
  Future<bool> createManualBackup(BackupConfig config) async {
    try {
      AppLogger.ui('Creating manual backup', details: 'BackupController');
      _clearError();

      // Set initial progress
      _progress = BackupProgress(
        operation: 'Membuat backup',
        progress: 0.0,
        currentStep: 'Menyiapkan data...',
      );
      notifyListeners();

      // Update progress
      _progress = _progress!.copyWith(
        progress: 0.3,
        currentStep: 'Mengumpulkan data...',
      );
      notifyListeners();

      // Create backup
      final result = await backupService.createBackup(config);

      if (!result.success) {
        throw ValidationException(result.error ?? 'Gagal membuat backup');
      }

      // Update progress
      _progress = _progress!.copyWith(
        progress: 0.8,
        currentStep: 'Menyimpan backup...',
      );
      notifyListeners();

      // Reload backups list
      await loadBackups();

      // Complete progress
      _progress = _progress!.copyWith(
        progress: 1.0,
        currentStep: 'Selesai',
      );
      notifyListeners();

      // Clear progress after a delay
      await Future.delayed(const Duration(seconds: 1));
      _progress = null;
      notifyListeners();

      AppLogger.info('Manual backup created', tag: 'BackupController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      _progress = null;
      notifyListeners();
      AppLogger.error('Failed to create manual backup', error: e, tag: 'BackupController');
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal membuat backup',
        operation: 'createManualBackup',
        originalError: e,
        stackTrace: stackTrace,
      ));
      _progress = null;
      notifyListeners();
      return false;
    }
  }

  /// Restore from selected backup
  Future<bool> restoreBackup(RestoreMode mode) async {
    if (_selectedBackup == null) {
      _setError(const ValidationException('Pilih backup terlebih dahulu'));
      return false;
    }

    try {
      AppLogger.ui(
        'Restoring backup: ${_selectedBackup!.id}',
        details: 'BackupController',
      );
      _clearError();

      // Set initial progress
      _progress = BackupProgress(
        operation: 'Memulihkan backup',
        progress: 0.0,
        currentStep: 'Memvalidasi backup...',
      );
      notifyListeners();

      // Validate backup first
      final validation = await backupService.validateBackup(_selectedBackup!.id);
      if (!validation.isValid) {
        throw ValidationException(
          validation.error ?? 'Backup tidak valid',
        );
      }

      // Update progress
      _progress = _progress!.copyWith(
        progress: 0.3,
        currentStep: 'Memulihkan data...',
      );
      notifyListeners();

      // Restore backup
      final result = await backupService.restoreBackup(
        _selectedBackup!.id,
        mode,
      );

      if (!result.success) {
        throw DatabaseException(result.error ?? 'Gagal memulihkan backup');
      }

      // Update progress
      _progress = _progress!.copyWith(
        progress: 1.0,
        currentStep: 'Selesai',
      );
      notifyListeners();

      // Clear progress after a delay
      await Future.delayed(const Duration(seconds: 1));
      _progress = null;
      notifyListeners();

      AppLogger.info('Backup restored successfully', tag: 'BackupController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      _progress = null;
      notifyListeners();
      AppLogger.error('Failed to restore backup', error: e, tag: 'BackupController');
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal memulihkan backup',
        operation: 'restoreBackup',
        originalError: e,
        stackTrace: stackTrace,
      ));
      _progress = null;
      notifyListeners();
      return false;
    }
  }

  /// Delete selected backup
  Future<bool> deleteBackup() async {
    if (_selectedBackup == null) {
      _setError(const ValidationException('Pilih backup terlebih dahulu'));
      return false;
    }

    try {
      AppLogger.ui(
        'Deleting backup: ${_selectedBackup!.id}',
        details: 'BackupController',
      );
      _clearError();
      _setLoading(true);

      final success = await backupService.deleteBackup(_selectedBackup!.id);

      if (!success) {
        throw NotFoundException(
          'Gagal menghapus backup',
          resourceType: 'Backup',
          resourceId: _selectedBackup!.id,
        );
      }

      // Clear selection and reload
      _selectedBackup = null;
      await loadBackups();

      AppLogger.info('Backup deleted successfully', tag: 'BackupController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to delete backup', error: e, tag: 'BackupController');
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal menghapus backup',
        operation: 'deleteBackup',
        originalError: e,
        stackTrace: stackTrace,
      ));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Schedule automatic backup
  /// TODO: Implement in future tasks
  Future<bool> scheduleBackup({
    required BackupFrequency frequency,
    required BackupType type,
    required StorageLocation location,
  }) async {
    try {
      AppLogger.ui(
        'Scheduling backup: ${frequency.name}',
        details: 'BackupController',
      );

      // TODO: Implement scheduling logic in future tasks
      // This will require:
      // - Background task scheduling (flutter_local_notifications)
      // - Work manager (workmanager package)
      // - Persistence of schedule configuration

      AppLogger.warning(
        'Backup scheduling not yet implemented',
        tag: 'BackupController',
      );
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal menjadwalkan backup',
        operation: 'scheduleBackup',
        originalError: e,
        stackTrace: stackTrace,
      ));
      return false;
    }
  }

  /// Cancel scheduled backup
  /// TODO: Implement in future tasks
  Future<bool> cancelSchedule() async {
    try {
      AppLogger.ui('Canceling backup schedule', details: 'BackupController');

      // TODO: Implement schedule cancellation in future tasks

      AppLogger.warning(
        'Schedule cancellation not yet implemented',
        tag: 'BackupController',
      );
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal membatalkan jadwal backup',
        operation: 'cancelSchedule',
        originalError: e,
        stackTrace: stackTrace,
      ));
      return false;
    }
  }

  /// Select a backup
  void selectBackup(BackupMetadata? backup) {
    _selectedBackup = backup;
    notifyListeners();
    AppLogger.ui(
      'Backup ${backup != null ? "selected" : "deselected"}: ${backup?.id ?? "none"}',
      details: 'BackupController',
    );
  }

  /// Validate selected backup
  Future<bool> validateSelectedBackup() async {
    if (_selectedBackup == null) {
      return false;
    }

    try {
      AppLogger.ui(
        'Validating backup: ${_selectedBackup!.id}',
        details: 'BackupController',
      );

      final validation = await backupService.validateBackup(_selectedBackup!.id);

      if (!validation.isValid) {
        _setError(ValidationException(
          validation.error ?? 'Backup tidak valid',
        ));
        return false;
      }

      if (validation.warnings.isNotEmpty) {
        AppLogger.warning(
          'Backup validation warnings: ${validation.warnings.join(", ")}',
          tag: 'BackupController',
        );
      }

      return true;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal memvalidasi backup',
        operation: 'validateSelectedBackup',
        originalError: e,
        stackTrace: stackTrace,
      ));
      return false;
    }
  }

  /// Clear any errors
  void clearError() {
    _clearError();
  }

  // Private state setters

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(AppException error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _scheduleTimer?.cancel();
    super.dispose();
  }
}
