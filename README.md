# Simple POS - Point of Sale System

A production-ready Point of Sale (POS) and inventory management system built with Flutter and Clean Architecture.

![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue)
![Dart](https://img.shields.io/badge/Dart-3.10+-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Tests](https://img.shields.io/badge/tests-300%2B-brightgreen)
![Coverage](https://img.shields.io/badge/coverage-75%25%2B-brightgreen)

## Features

### Core POS Features

- ✅ **Product Management** - Add, edit, delete, and search products
- ✅ **Shopping Cart** - Add items, update quantities, remove items
- ✅ **Checkout Process** - Complete checkout with payment processing
- ✅ **Multiple Payment Methods** - Cash, Card, QRIS, Transfer
- ✅ **Receipt Generation** - Print, share, or save PDF receipts
- ✅ **Sales History** - View and filter transaction history
- ✅ **Sales Reports** - Daily sales charts, top products, payment breakdown
- ✅ **Export to CSV** - Export sales reports for analysis

### Advanced Inventory Features

- ✅ **Categories** - Organize products by category
- ✅ **Suppliers** - Track product suppliers
- ✅ **Low Stock Alerts** - Get notified when stock is running low
- ✅ **Barcode Support** - Optional barcode scanning for products
- ✅ **Stock Management** - Track stock levels and cost prices
- ✅ **Profit Calculations** - Automatic profit margin tracking

### Technical Features

- ✅ **Clean Architecture** - Scalable and maintainable codebase
- ✅ **Comprehensive Testing** - 300+ tests with 75%+ coverage
- ✅ **Database Migrations** - Safe schema upgrades
- ✅ **Internationalization** - English and Indonesian support
- ✅ **Offline-First** - SQLite database for local data storage
- ✅ **Error Handling** - Comprehensive error handling and user feedback
- ✅ **Logging** - Detailed logging for debugging and monitoring

## Screenshots

### Main Features

- **POS Screen** - Intuitive point of sale interface
- **Inventory Management** - Product catalog with search and filters
- **Sales History** - Transaction history with advanced filtering
- **Sales Reports** - Visual charts and analytics

## Installation

### Prerequisites

- Flutter SDK 3.10.7 or higher
- Dart SDK 3.10.7 or higher
- Android Studio / VS Code with Flutter extensions
- iOS Simulator / Android Emulator / Physical device

### Setup

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd simple_pos
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Generate mock objects** (for testing)

   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**

   ```bash
   # Use the provided script (recommended)
   ./run.sh

   # Or run manually with DDS disabled (fixes WebSocket connection issues)
   flutter run --device-id=emulator-5554 --disable-dds

   # Run on different devices
   flutter run --device-id=chrome --disable-dds  # Web
   flutter run --device-id=linux --disable-dds   # Linux Desktop
   ```

   **Note:** If you encounter WebSocket connection errors when running `flutter run -v`, use the `--disable-dds` flag. This is a known issue with the Dart Development Service on some systems and doesn't affect app functionality.

## Running Tests

### Run All Tests

```bash
flutter test
```

### Run with Coverage

```bash
flutter test --coverage
```

### Run Specific Test Types

```bash
# Unit tests only
flutter test test/unit

# Widget tests only
flutter test test/widget

# Integration tests only
flutter test integration_test
```

For detailed testing information, see [TESTING.md](TESTING.md).

## Project Structure

```
lib/
├── core/                          # Core functionality
│   ├── constants/                 # App constants
│   ├── config/                    # Configuration management
│   ├── exceptions/                # Custom exceptions
│   ├── utils/                     # Utility functions
│   └── services/                  # Core services (receipt, etc.)
│
├── features/                      # Feature modules
│   ├── inventory/                 # Inventory management
│   │   ├── data/                  # Data layer
│   │   │   ├── datasources/       # Local/remote data sources
│   │   │   ├── models/            # Data transfer objects
│   │   │   └── repositories/      # Repository implementations
│   │   ├── domain/                # Domain layer
│   │   │   ├── entities/          # Business entities
│   │   │   ├── repositories/      # Repository interfaces
│   │   │   └── usecases/          # Business logic
│   │   └── presentation/          # Presentation layer
│   │       ├── controllers/       # State management
│   │       ├── screens/           # UI screens
│   │       └── widgets/           # Reusable widgets
│   │
│   ├── pos/                       # Point of Sale
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── sales/                     # Sales & Transactions
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── shared/                    # Shared components
│       └── presentation/
│           ├── widgets/           # Common widgets
│           └── screens/           # Navigation, etc.
│
├── services/                      # Global services
│   └── database/                  # Database setup
│
└── l10n/                          # Localization files
    ├── app_en.arb                 # English
    └── app_id.arb                 # Indonesian
```

For detailed architecture information, see [ARCHITECTURE.md](ARCHITECTURE.md).

## Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

### Layers

1. **Domain Layer** - Business logic and entities
   - Entities: Core business objects
   - Use Cases: Application business rules
   - Repository Interfaces: Data access contracts

2. **Data Layer** - Data management
   - Repository Implementations: Concrete data access
   - Data Sources: SQLite, APIs, etc.
   - Models: Data transfer objects

3. **Presentation Layer** - UI and state management
   - Controllers: State management with Provider
   - Screens: UI screens
   - Widgets: Reusable components

### Key Patterns

- **Repository Pattern** - Abstracts data access
- **Use Case Pattern** - Encapsulates business logic
- **Provider Pattern** - State management
- **Dependency Injection** - Inversion of Control

## Database

The app uses SQLite with the following schema:

- **products** - Product catalog
- **categories** - Product categories
- **suppliers** - Product suppliers
- **transactions** - Sales transactions
- **transaction_items** - Transaction line items
- **payments** - Payment records

### Database Version

Current version: **2**

Migration system supports safe upgrades from previous versions.

## Configuration

App configuration is managed through `AppConfig` service:

```dart
import 'package:simple_pos/core/config/app_config.dart';

// Get current config
final config = AppConfig.instance;

// Update config
await config.updateFromMap({'storeName': 'My Store'});

// Save config
await config.save();
```

### Configuration Options

- **Store Information** - Name, address, phone, email
- **Business Rules** - Low stock threshold, tax rate
- **Currency Settings** - Symbol, locale, decimal places
- **Receipt Settings** - Width, footer text

## Localization

The app supports multiple languages:

- English (en)
- Indonesian (id) - Default

To add a new language:

1. Create `lib/l10n/app_<locale>.arb`
2. Add translations following the existing format
3. Update `main.dart` to include the new locale
4. Generate localization files:
   ```bash
   flutter gen-l10n
   ```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Write/update tests
5. Ensure all tests pass
6. Submit a pull request

### Development Guidelines

- Follow Clean Architecture principles
- Write tests before implementation (TDD)
- Maintain test coverage above 75%
- Use descriptive commit messages
- Follow Dart style guidelines
- Document public APIs

## Code Quality

### Linting

```bash
flutter analyze
```

### Formatting

```bash
dart format .
```

### Coverage

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Dependencies

### Production Dependencies

- **flutter** - Flutter framework
- **provider** - State management
- **sqflite** - SQLite database
- **path** - Path manipulation
- **pdf** - PDF generation for receipts
- **printing** - Print functionality
- **share_plus** - Share functionality
- **path_provider** - File system access
- **fl_chart** - Chart visualization
- **csv** - CSV export
- **intl** - Internationalization
- **flutter_localizations** - Flutter localization

### Development Dependencies

- **flutter_test** - Testing framework
- **flutter_lints** - Linting rules
- **mockito** - Mocking framework
- **build_runner** - Code generation
- **integration_test** - Integration testing
- **coverage** - Code coverage

## Roadmap

### Completed ✅

- [x] Core POS functionality
- [x] Product management
- [x] Shopping cart
- [x] Checkout with payment processing
- [x] Receipt generation
- [x] Sales history and reporting
- [x] Category and supplier management
- [x] Low stock alerts
- [x] Database migrations
- [x] Internationalization
- [x] Comprehensive testing

### Future Features 🚧

- [ ] Barcode scanning integration
- [ ] Cloud sync support
- [ ] Multi-user authentication
- [ ] Discount and coupon system
- [ ] Customer management
- [ ] Email receipt support
- [ ] Dashboard analytics
- [ ] Role-based access control
- [ ] Multi-currency support
- [ ] Offline mode sync

## Troubleshooting

### WebSocket Connection Error

**Problem:** When running `flutter run -v`, you encounter:
```
Error connecting to the service protocol: failed to connect to http://127.0.0.1:XXXXX/
HttpException: Connection closed before full header was received
```

**Solution:** Use the `--disable-dds` flag to disable the Dart Development Service:
```bash
flutter run --device-id=emulator-5554 --disable-dds
```

**Explanation:** This is a known issue with DDS on some Linux configurations. It doesn't affect app functionality, only the development tooling connection. The app runs normally with this flag.

### Build Issues

**Problem:** Build fails after pulling latest changes.

**Solution:**
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run --device-id=emulator-5554 --disable-dds
```

### Database Migration Errors

**Problem:** App crashes after database schema changes.

**Solution:**
1. Uninstall the app from the emulator/device
2. Reinstall to trigger fresh database creation
3. Or implement proper migration in `DatabaseHelper._onUpgrade()`

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, email mreynaldigazali@gmail.com or open an issue in the repository.

## Acknowledgments

- Flutter team for the amazing framework
- Provider package for state management
- Clean Architecture principles by Robert C. Martin

---

**Built with ❤️ using Flutter**
