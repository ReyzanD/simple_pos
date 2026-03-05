#!/bin/bash

# Simple POS - Test Coverage Script
# This script runs all tests and generates coverage reports

echo "Running tests with coverage..."
flutter test --coverage

echo "Generating HTML coverage report..."
genhtml coverage/lcov.info -o coverage/html

echo "Coverage report generated at coverage/html/index.html"

# Optional: Open the report in the default browser (uncomment on macOS)
# open coverage/html/index.html

# Optional: Open the report in the default browser (uncomment on Linux)
# xdg-open coverage/html/index.html

# Optional: Open the report in the default browser (uncomment on Windows)
# start coverage/html/index.html
