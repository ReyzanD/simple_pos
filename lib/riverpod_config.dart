import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/material.dart';
import 'core/database/database_helper.dart';
import 'core/controllers/theme_controller.dart';

part 'riverpod_config.g.dart';

/// Database provider for dependency injection
@riverpod
DatabaseHelper database() {
  return DatabaseHelper.instance;
}

/// Theme mode provider for app-wide theme management
@riverpod
ThemeMode themeMode() {
  return ThemeMode.system;
}

/// Theme controller provider (transition from old Provider)
@riverpod
ThemeController themeController() {
  return ThemeController()..init();
}