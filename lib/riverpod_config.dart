import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/material.dart';
import 'core/database/database_helper.dart';
import 'core/controllers/theme_controller.dart';

part 'riverpod_config.g.dart';

/// Database provider for dependency injection
@riverpod
DatabaseHelper database(Ref ref) {
  return DatabaseHelper.instance;
}

/// Theme mode provider for app-wide theme management
@riverpod
ThemeMode themeMode(Ref ref) {
  return ThemeMode.system;
}

/// Theme controller provider (transition from old Provider)
@riverpod
ThemeController themeController(Ref ref) {
  return ThemeController()..init();
}