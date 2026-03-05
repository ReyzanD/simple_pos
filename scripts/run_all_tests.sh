#!/bin/bash

# Simple POS - Run All Tests Script
# This script runs unit, widget, and integration tests

echo "🧪 Running Unit Tests..."
flutter test test/unit || exit 1

echo "🎨 Running Widget Tests..."
flutter test test/widget || exit 1

echo "🔄 Running Integration Tests..."
flutter test integration_test || exit 1

echo "✅ All tests passed!"
