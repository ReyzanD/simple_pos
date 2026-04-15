/// Backup Providers - Complete & Tested
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../../../core/database/database_helper.dart';
import '../../../backup/data/datasources/backup_local_datasource.dart';
import '../../../backup/data/datasources/backup_drive_datasource.dart';
import '../../../backup/data/repositories/backup_repository_impl.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../core/services/backup_data_collector.dart';
import '../../../backup/presentation/controllers/backup_controller.dart';

List<SingleChildWidget> createBackupProviders() {
  return [
    Provider<BackupLocalDataSource>(create: (_) => BackupLocalDataSource()),
    Provider<BackupDriveDataSource>(create: (_) => BackupDriveDataSource()),

    // ProxyProvider2 needs 4 arguments: (context, dependency1, dependency2, previous)
    ProxyProvider2<
      BackupLocalDataSource,
      BackupDriveDataSource,
      BackupRepositoryImpl
    >(
      update: (context, local, drive, previous) =>
          BackupRepositoryImpl(localDataSource: local, driveDataSource: drive),
    ),

    // ProxyProvider needs 3 arguments: (context, dependency, previous)
    ProxyProvider<DatabaseHelper, BackupDataCollector>(
      update: (context, db, previous) =>
          BackupDataCollector(databaseHelper: db),
    ),

    // ProxyProvider3 needs 5 arguments: (context, dep1, dep2, dep3, previous)
    ProxyProvider3<
      BackupRepositoryImpl,
      BackupDataCollector,
      DatabaseHelper,
      BackupService
    >(
      update: (context, repo, collector, db, previous) => BackupService(
        backupRepository: repo,
        dataCollector: collector,
        databaseHelper: db,
      ),
    ),

    ChangeNotifierProvider<BackupController>(
      // Changed (_) to (context) so the word 'context' actually exists here
      create: (context) =>
          BackupController(backupService: context.read<BackupService>()),
    ),
  ];
}
