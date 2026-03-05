@echo off
REM Simple POS - Run All Tests Script (Windows)
REM This script runs unit, widget, and integration tests

echo 🧪 Running Unit Tests...
call flutter test test/unit
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

echo 🎨 Running Widget Tests...
call flutter test test/widget
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

echo 🔄 Running Integration Tests...
call flutter test integration_test
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

echo ✅ All tests passed!
