#!/bin/bash
# Simple POS Runner
# Run the app without DDS to avoid WebSocket connection errors

echo "Starting Simple POS app..."
echo "Checking for connected devices..."

# Check if any device is available
if ! flutter devices | grep -q "emulator-5554"; then
    echo "Warning: emulator-5554 not found in Flutter devices."
    echo ""
    echo "Available devices:"
    flutter devices
    echo ""
    echo "If emulator is running but not detected, try:"
    echo "  1. Run: flutter devices"
    echo "  2. Use the device ID shown above with: flutter run --device-id=<device-id> --disable-dds"
    echo ""
    echo "To start emulator:"
    echo "  flutter emulators"
    echo "  flutter emulators --launch <emulator_id>"
    read -p "Press Enter to try running anyway, or Ctrl+C to cancel..."
fi

# Run the app with DDS disabled
flutter run --device-id=emulator-5554 --disable-dds

# Alternative: Run on different devices
# flutter run --device-id=chrome --disable-dds  # Web
# flutter run --device-id=linux --disable-dds   # Linux Desktop
