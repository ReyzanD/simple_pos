#!/bin/bash
# Simple POS Runner - Release Mode
# Runs in release mode which doesn't need debugger connection

echo "Building Simple POS in release mode..."

# Build release APK
flutter build apk --release

# Install and run
echo "Installing on emulator..."
flutter install --device-id=emulator-5554

echo "App installed! Launch it from your emulator home screen."
echo "Note: Release mode doesn't support hot reload or debugging."
