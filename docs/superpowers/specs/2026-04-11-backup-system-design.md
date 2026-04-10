# Backup System Design Document

**Project:** Simple POS  
**Feature:** Backup System (#26)  
**Date:** 2026-04-11  
**Status:** Design Approved

---

## Overview

The Backup System provides comprehensive data protection for the Simple POS application through hybrid storage (local + Google Drive), supporting both manual and scheduled backups with incremental backup support and flexible restore options.

### Key Features
- **Hybrid Storage**: Local files for quick recovery + Google Drive for off-site protection
- **Incremental Backups**: Full backups + smaller incremental changes
- **Flexible Scheduling**: Daily, weekly, or monthly automatic backups
- **Manual Control**: Users can trigger backups anytime
- **Smart Restore**: Users choose between full replacement or merge mode
- **Comprehensive Coverage**: Database, images, and all app data

### Protection Scenarios
The system protects against:
- Data loss from device failure (lost/broken/stolen device)
- Data corruption (database corruption)
- User errors (accidental deletion)
- Complete disaster recovery

---

## Architecture

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│                   Presentation Layer                     │
│  BackupScreen (UI)  →  BackupController (State)        │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│                    Domain Layer                         │
│  BackupService (core operations)                       │
│  BackupScheduler (alarm management)                    │
│  BackupValidator (integrity checks)                     │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│                     Data Layer                          │
│  LocalBackupRepository (file I/O)                       │
│  DriveBackupRepository (Google Drive API)               │
└─────────────────────────────────────────────────────────┘
```

### Component Responsibilities

**Domain Layer:**
- `BackupService`: Orchestrates backup/restore operations
- `BackupScheduler`: Manages AlarmManager for scheduled backups
- `BackupValidator`: Validates backup integrity and completeness
- Entities: `BackupMetadata`, `BackupConfig`, `BackupSchedule`, `BackupData`

**Data Layer:**
- `LocalBackupRepository`: File I/O, compression, local storage management
- `DriveBackupRepository`: Google Drive API integration, upload/download

**Presentation Layer:**
- `BackupController`: UI state management, user interactions, progress tracking
- `BackupScreen`: UI screens (backup list, dialogs, progress indicators)

---

## Core Components

### Domain Layer

#### BackupService
```dart
class BackupService {
  Future<BackupResult> createBackup(BackupConfig config);
  Future<RestoreResult> restoreBackup(BackupMetadata backup, RestoreMode mode);
  Future<List<BackupMetadata>> listBackups();
  Future<void> deleteBackup(BackupMetadata backup);
  Future<ValidationResult> validateBackup(BackupMetadata backup);
}
```

#### BackupScheduler
```dart
class BackupScheduler {
  Future<void> scheduleBackup(BackupSchedule schedule);
  Future<void> cancelBackup(int scheduleId);
  Future<List<BackupSchedule>> getScheduledBackups();
}
```

#### Entities
```dart
class BackupMetadata {
  final String id;
  final BackupType type; // FULL or INCREMENTAL
  final DateTime createdAt;
  final int size;
  final StorageLocation location; // LOCAL, DRIVE, or BOTH
  final bool isValid;
  final String? baseBackupId;
}

class BackupConfig {
  final BackupType type;
  final List<BackupDataType> dataTypes;
  final bool compress;
  final StorageLocation location;
}

class BackupSchedule {
  final int id;
  final String name;
  final BackupFrequency frequency;
  final TimeOfDay time;
  final BackupConfig config;
  final bool isActive;
}
```

### Data Layer

#### LocalBackupRepository
```dart
class LocalBackupRepository {
  Future<String> saveBackup(BackupData data, BackupMetadata metadata);
  Future<BackupData> loadBackup(String backupId);
  Future<List<BackupMetadata>> listBackups();
  Future<void> deleteBackup(String backupId);
}
```

#### DriveBackupRepository
```dart
class DriveBackupRepository {
  Future<String> uploadBackup(BackupData data, BackupMetadata metadata);
  Future<BackupData> downloadBackup(String fileId);
  Future<List<BackupMetadata>> listBackups();
  Future<void> deleteBackup(String fileId);
}
```

### Presentation Layer

#### BackupController
```dart
class BackupController extends ChangeNotifier {
  // State
  List<BackupMetadata> _backups;
  List<BackupSchedule> _schedules;
  bool _isCreatingBackup;
  bool _isRestoring;
  int _progress;
  String? _errorMessage;
  
  // Operations
  Future<void> createManualBackup(BackupConfig config);
  Future<void> restoreBackup(BackupMetadata backup, RestoreMode mode);
  Future<void> deleteBackup(BackupMetadata backup);
  Future<void> scheduleBackup(BackupSchedule schedule);
}
```

---

## Data Flow

### Backup Creation Flow

**Manual Backup:**
1. User triggers backup via UI
2. `BackupController.showCreateBackupDialog()`
3. User selects options (type, data, location, compression)
4. `BackupController.createManualBackup(config)`
5. `BackupService.createBackup(config)`:
   - IF full backup: Collect database + images + data
   - IF incremental: Calculate changes since last full backup
   - Compress if enabled
   - Save to local storage
   - Upload to Drive if selected
6. Return `BackupResult` with metadata
7. Controller updates UI

**Scheduled Backup:**
1. `AlarmManager` triggers at scheduled time
2. `BackupScheduler` receives broadcast
3. `BackupService.createBackup(schedule.config)`
4. Show notification: "Backup completed successfully"
5. Save backup record

### Restore Flow

1. User selects backup from list
2. User taps "Restore"
3. `BackupController.showRestoreDialog(backup)`
4. User selects mode: "Replace All" or "Merge"
5. `BackupService.restoreBackup(backup, mode)`:
   - Validate backup integrity
   - IF replace: Delete current data, extract backup
   - IF merge: Insert new records, update existing, skip conflicts
   - Show summary
6. Refresh all controllers

---

## Storage Strategy

### Local Storage

**Directory Structure:**
```
/data/data/com.example.simple_pos/files/
├── backups/
│   ├── full/
│   │   ├── backup_YYYYMMDD_HHMMSS_full.zip
│   │   └── metadata.json
│   └── incremental/
│       ├── backup_YYYYMMDD_HHMMSS_inc.zip
│       └── metadata.json
└── temp/backup_temp/
```

**Storage Management:**
- Keep last 10 full backups + 30 incrementals locally
- Auto-cleanup when limits exceeded
- Always keep at least one full backup + recent incrementals

### Google Drive Storage

**Folder Structure:**
```
Simple POS Backups/
├── Full/
│   └── backup_YYYYMMDD_HHMMSS_full.zip
└── Incremental/
    └── backup_YYYYMMDD_HHMMSS_inc.zip
```

**File Properties:**
```json
{
  "isBackup": true,
  "backupType": "FULL",
  "backupDate": "2026-04-11T14:30:00Z",
  "backupSize": 1048576,
  "appVersion": "1.0.0",
  "databaseVersion": 16
}
```

### Hybrid Synchronization

When creating backup with `location = BOTH`:
1. Save to local storage first (fast, immediate)
2. Return success to user
3. Background task: Upload to Drive
4. Show notification when upload completes
5. Update metadata with Drive file ID

---

## Backup Operations

### Data Collection

**Full Backup:**
- Copy entire database file
- Collect all product images
- Export preferences and settings
- Compress into single ZIP file

**Incremental Backup:**
- Load last full backup metadata
- Query database for changed records (WHERE updated_at > lastBackupTime)
- Collect new/modified images
- Store as incremental with reference to base backup

### Compression

- Use `archive` package for ZIP compression
- Compression level: 6 (balance speed vs size)
- Typical compression: 60-80% size reduction
- Required for all backups (user can disable but not recommended)

### Scheduling Implementation

**Android AlarmManager:**
- Exact alarms for precise timing
- Allow while idle for device doze mode
- Wake device if asleep for backup
- Reschedule next backup after execution

**Frequency Options:**
- Daily: User selects time (e.g., 2:00 PM)
- Weekly: User selects day + time (e.g., Sunday 10:00 AM)
- Monthly: User selects day of month + time (e.g., 1st at 2:00 AM)

---

## UI/UX Design

### Main Screen

**Two-tab layout:**
- **Full Backups tab**: Complete system snapshots
- **Incremental Backups tab**: Smaller change-based backups

**Each backup shows:**
- Backup type icon (📦 full, 📄 incremental)
- Date/time created
- File size
- Storage location (Local only, Local + Drive, Drive only)
- Actions: Restore, Delete, Upload to Drive (for local-only)

### Create Backup Dialog

**User selects:**
- Backup type: Full or Incremental
- What to backup: Database, Images, or All
- Save to: Local storage, Google Drive, or Both
- Compression: On (recommended) or Off

### Restore Dialog

**Two restore modes:**
- **Replace All**: Deletes all current data, replaces with backup
  - Warning: "This will DELETE all current data"
- **Merge**: Adds backup data to existing data
  - Preserves current data
  - May create duplicates
  - Shows merge summary after completion

### Progress Indicator

**Overlay during operations:**
- Progress bar with percentage
- Current stage (Collecting, Compressing, Uploading, etc.)
- Current item being processed
- Cancel button (for long operations)

### Notifications

**Backup completed:**
```
✅ Backup completed successfully
   Full backup (125 MB) saved to Local + Drive
```

**Scheduled backup:**
```
📦 Scheduled backup completed
   Daily End of Day: Full backup (130 MB)
```

**Backup failed:**
```
❌ Backup failed
   Insufficient storage on Google Drive
   [Retry]
```

---

## Error Handling

### Error Categories

**Storage Errors:**
- `INSUFFICIENT_SPACE`: Not enough storage
- `WRITE_FAILED`: Cannot write to storage
- `READ_FAILED`: Cannot read backup file
- `DRIVE_ERROR`: Google Drive API error

**Validation Errors:**
- `CORRUPTED`: Backup file is corrupted
- `INCOMPLETE`: Missing required data
- `VERSION_MISMATCH`: Different app version
- `INCOMPATIBLE`: Database schema version mismatch

**Operation Errors:**
- `COLLECTION`: Failed to collect data
- `COMPRESSION`: Failed to compress
- `UPLOAD`: Failed to upload to Drive
- `RESTORE`: Failed to restore data
- `MERGE_CONFLICT`: Unresolvable merge conflicts

### Error Recovery

**Insufficient Local Space:**
- Show error with "Free up space" option
- Offer to delete old backups
- Retry after cleanup

**Insufficient Drive Space:**
- Save to local only
- Show warning
- Provide link to manage Drive storage

**Corrupted Backup:**
- Show error: "Backup file is corrupted"
- Offer to delete corrupted backup
- Suggest restoring from different backup

**Version Mismatch:**
- Show warning with version info
- Offer to attempt restore anyway
- Log compatibility issues

**Drive Upload Failure:**
- Save to local only
- Show error with retry option
- Background task: Retry upload later

---

## Testing Strategy

### Unit Tests

**BackupService:**
- Create full/incremental backup
- Validate backup integrity
- Restore with replace/merge modes
- Handle merge conflicts
- Delete backups

**BackupScheduler:**
- Calculate next schedule time (daily/weekly/monthly)
- Handle time passed for today's schedule
- Reschedule recurring backups

**Repositories:**
- Save/load/delete local backups
- Upload/list/delete Drive backups
- Handle missing metadata.json
- Mock Drive API errors

### Integration Tests

**Complete backup flow:**
- Open backup screen → Create backup → Select options → Confirm → Verify backup created

**Scheduled backup flow:**
- Create schedule → Verify alarm set → Simulate trigger → Verify backup created

**Restore flow:**
- Create test data → Create backup → Modify data → Restore merge → Verify merged data

### Manual Testing Checklist

**Happy Path:**
- Create full backup (local only)
- Create full backup (local + Drive)
- Create incremental backup
- Restore backup (replace mode)
- Restore backup (merge mode)
- Delete backup
- Schedule daily/weekly/monthly backup
- Cancel scheduled backup

**Error Cases:**
- Create backup with no storage space
- Create backup with Drive disconnected
- Restore corrupted backup
- Restore from incompatible version
- Handle Drive API quota exceeded
- Handle file system errors

**Edge Cases:**
- Backup while database is being written
- Restore while app is in use
- Multiple concurrent backup requests
- Very large backup (>1GB)
- No existing backups (first run)
- Cancel backup during creation

### Performance Targets

**Backup Performance:**
- Full backup (1000 products, 100 images): <30 seconds
- Incremental backup (10 changes): <5 seconds
- Memory usage: <100MB
- Compression ratio: 60-80%

**Restore Performance:**
- Full restore: <45 seconds
- Merge restore (100 conflicts): <60 seconds
- Database validation: <5 seconds

---

## Implementation Notes

### Dependencies

**Required packages:**
- `googleapis`: Google Drive API integration
- `path_provider`: Local file system access
- `archive`: ZIP compression/decompression
- `android_alarm_manager_plus`: Scheduled alarms

**Google Drive Setup:**
- Enable Drive API in Google Cloud Console
- Configure OAuth 2.0 credentials
- Add Drive SDK to app dependencies

### File Format

**Backup ZIP Structure:**
```
backup_YYYYMMDD_HHMMSS_full.zip
├── database/
│   └── simple_pos.db
├── images/
│   ├── product_123.jpg
│   └── product_456.png
├── metadata.json
│   ├── backupType: "FULL"
│   ├── createdAt: "2026-04-11T14:30:00Z"
│   ├── appVersion: "1.0.0"
│   └── databaseVersion: 16
└── manifest.json (file inventory with checksums)
```

### Database Considerations

**Backup Safety:**
- Close database connections before backup
- Use WAL checkpoint to ensure data consistency
- Verify database integrity after backup

**Restore Safety:**
- Close all controllers before restore
- Verify database schema compatibility
- Handle foreign key constraints during merge

---

## Success Criteria

The backup system is complete when:

✅ Users can create manual full and incremental backups  
✅ Users can schedule automatic daily, weekly, or monthly backups  
✅ Backups can be saved to local storage, Google Drive, or both  
✅ Users can restore backups with replace or merge mode  
✅ Incremental backups only store changes since last full backup  
✅ System validates backup integrity before restore  
✅ Users receive notifications for scheduled backup completion  
✅ System handles storage errors gracefully with clear error messages  
✅ Users can view and manage all backups in organized UI  
✅ Local storage automatically cleans up old backups  
✅ Google Drive backups persist independently  
✅ All operations show progress to users  
✅ System can recover from device failure, data corruption, and user errors  

---

## Appendix

### Backup Metadata Schema

```dart
class BackupMetadata {
  String id;                    // Unique identifier
  BackupType type;              // FULL or INCREMENTAL
  DateTime createdAt;           // When backup was created
  int size;                     // Size in bytes
  StorageLocation location;     // LOCAL, DRIVE, or BOTH
  bool isValid;                 // Passed validation
  String? baseBackupId;         // For incrementals: reference to full backup
  String? driveFileId;          // Google Drive file ID (if uploaded)
  int databaseVersion;          // Database schema version
  String appVersion;            // App version that created backup
}
```

### Storage Enumerations

```dart
enum BackupType { FULL, INCREMENTAL }
enum BackupDataType { DATABASE, IMAGES, ALL }
enum StorageLocation { LOCAL, DRIVE, BOTH }
enum BackupFrequency { DAILY, WEEKLY, MONTHLY }
enum RestoreMode { REPLACE_ALL, MERGE }
```

### File Naming Conventions

**Full backup:** `backup_YYYYMMDD_HHMMSS_full.zip`  
**Incremental backup:** `backup_YYYYMMDD_HHMMSS_inc.zip`  
**Metadata file:** `metadata.json` (index of all backups)

---

**End of Design Document**
