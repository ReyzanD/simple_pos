# Database Helper Refactoring Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Break down the 1,643-line `database_helper.dart` into smaller, focused, testable modules for improved maintainability

**Architecture:** Extract database operations into separate modules by responsibility: connection management, schema operations, CRUD operations, migrations, DAOs for each entity type.

**Tech Stack:** Flutter, SQLite (sqflite package), existing error handling system

---

## File Structure

**Current State:**
- `lib/services/database/database_helper.dart`: 1,643 lines (monolithic)
- Handles: database initialization, schema creation, migrations, CRUD for all entities, indexing, error handling, logging

**Proposed New Structure:**
```
lib/services/database/
├── database_connection.dart (database initialization, connection pooling)
├── database_schema.dart (schema creation, migrations)
├── dao/
│   ├── product_dao.dart (product CRUD operations)
│   ├── category_dao.dart (category CRUD operations)
│   ├── supplier_dao.dart (supplier CRUD operations)
│   ├── transaction_dao.dart (transaction CRUD operations)
│   └── payment_dao.dart (payment operations)
├── migrations/
│   └── database_migration.dart (migration orchestration)
└── database_helper.dart (facade, simplified to ~400 lines)
```

---

## Tasks

### Task 1: Extract database connection logic
**Files:**
- Create: `lib/services/database/database_connection.dart`

**Steps:**
- [ ] **Step 1:** Create `DatabaseConnection` class with singleton database instance management
- [ ] **Step 2:** Extract connection logic from `DatabaseHelper._initDB()` and `get database()`
- [ ] **Step 3:** Add connection pooling for multiple concurrent database operations
- [ ] **Step 4:** Implement retry logic for failed connections
- [ ] **Step 5:** Write unit tests for connection management
- [ ] **Step 6:** Commit changes

### Task 2: Create database schema module
**Files:**
- Create: `lib/services/database/database_schema.dart`

**Steps:**
- [ ] **Step 1:** Create `DatabaseSchema` class with table definitions
- [ ] **Step 2:** Extract CREATE TABLE statements from `DatabaseHelper._createDB()`
- [ ] **Step 3:** Extract migration logic from `DatabaseHelper._onUpgrade()`
- [ ] **Step 4:** Move index creation to schema module
- [ ] **Step 5:** Add schema validation methods
- [ ] **Step 6:** Write unit tests for schema operations
- [ ] **Step 7:** Commit changes

### Task 3: Extract product DAO
**Files:**
- Create: `lib/services/database/dao/product_dao.dart`

**Steps:**
- [ ] **Step 1:** Create `ProductDAO` class
- [ ] **Step 2:** Extract product CRUD methods from `DatabaseHelper` (create, update, delete, getById, getAll, search)
- [ ] **Step 3:** Implement stock validation in operations
- [ ] **Step 4:** Add barcode search support
- [ ] **Step 5:** Add transaction support for stock updates
- [ ] **Step 6:** Write unit tests for all operations
- [ ] **Step 7:** Update `DatabaseHelper` to use `ProductDAO`
- [ ] **Step 8:** Commit changes

### Task 4: Extract transaction DAO  
**Files:**
- Create: `lib/services/database/dao/transaction_dao.dart`

**Steps:**
- [ ] **Step 1:** Create `TransactionDAO` class
- [ ] **Step 2:** Extract transaction CRUD methods
- [ ] **Step 3:** Extract payment operations
- [ ] **Step 4:** Add transaction items management
- [ ] **Step 5:** Implement transaction rollback support
- [ ] **Step 6:** Write unit tests for transaction operations
- [ ] **Step 7:** Update `DatabaseHelper` to use `TransactionDAO`
- [ ] **Step 8:** Commit changes

### Task 5: Create migration orchestrator
**Files:**
- Create: `lib/services/database/migrations/database_migration.dart`

**Steps:**
- [ ] **Step 1:** Create `DatabaseMigration` class
- [ ] **Step 2:** Extract upgrade logic from `_onUpgrade()` method
- [ ] **Step 3:** Add version tracking and rollback support
- [ ] **Step 4:** Implement data backup before migrations
- [ ] **Step 5:** Add migration step execution with error handling
- [ ] **Step 6:** Write unit tests for migrations
- [ ] **Step 7:** Update `DatabaseHelper` to use migration orchestrator
- [ ] **Step 8:** Commit changes

### Task 6: Update DatabaseHelper facade
**Files:**
- Modify: `lib/services/database/database_helper.dart`

**Steps:**
- [ ] **Step 1:** Replace direct database operations with DAO method calls
- [ ] **Step 2:** Remove schema creation logic (delegated to schema module)
- [ ] **Step 3:** Remove migration logic (delegated to migration module)
- [ ] **Step 4:** Keep database initialization and connection management
- [ ] **Step 5:** Add error handling wrapper that uses existing exception system
- [ ] **Step 6:** Update all dependent code to use new DAO structure
- [ ] **Step 7:** Write unit tests for facade
- [ ] **Step 8:** Commit changes

### Task 7: Update dependent code
**Files to Update:**
- `lib/features/inventory/data/repositories/product_repository_impl.dart` (update to use ProductDAO)
- `lib/features/pos/data/repositories/cart_repository_impl.dart` (update for transaction support)
- `lib/features/sales/data/repositories/transaction_repository_impl.dart` (update to use TransactionDAO)
- All use cases that directly use `DatabaseHelper` (update to use facade)

**Steps:**
- [ ] **Step 1:** Update repository implementations to use new DAO pattern
- [ ] **Step 2:** Update use cases to use DAO pattern
- [ ] **Step 3:** Run tests to verify no regressions
- [ ] **Step 4:** Commit changes

### Task 8: Final verification
**Steps:**
- [ ] **Step 1:** Run `flutter test` to verify all tests pass
- [ ] **Step 2:** Run `flutter analyze` to ensure no new errors
- [ ] **Step 3:** Run `flutter run` to verify app launches successfully
- [ ] **Step 4:** Test database operations in integration
- [ ] **Step 5:** Commit final changes

---

## Implementation Notes

**Testing Strategy:**
- Write unit tests for each DAO before implementation
- Use existing test patterns from codebase
- Test database operations with in-memory SQLite for isolation
- Verify migration rollback functionality

**Error Handling:**
- Reuse existing `app_exceptions.DatabaseException` class
- Maintain error logging with `AppLogger.database()`
- Ensure all database operations have try-catch with proper exception conversion

**Migration Safety:**
- All migrations run within database transaction
- Backup created before migration starts
- Rollback available if migration fails
- Version tracking in separate table

**Estimated Impact:**
- Main file: 1,643 → ~400 lines (75% reduction)
- Better test coverage through focused DAO modules
- Easier to maintain and extend database operations
- Clear separation of concerns: each DAO handles one entity type

---

**Ready for implementation?** Review this plan and let me know if you'd like me to proceed with the subagent-driven-development workflow to execute these tasks.