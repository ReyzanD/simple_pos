// Mock file for database testing
// This file is used to generate mocks with build_runner

import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart';

@GenerateNiceMocks([
  MockSpec<Database>(),
])
void main() {
  // Mocks will be generated in mocks.mocks.dart
}
