import 'package:flutter/services.dart';
import 'logger.dart';

/// Helper class for providing audio and haptic feedback
/// Useful for barcode scanning, button clicks, and other user interactions
class AudioFeedbackHelper {
  static final AudioFeedbackHelper instance = AudioFeedbackHelper._init();
  static bool _isMuted = false;

  AudioFeedbackHelper._init();

  /// Initialize the audio feedback system
  Future<void> init() async {
    try {
      // Test if system sounds are available
      await SystemSound.play(SystemSoundType.click);
      AppLogger.info('Audio feedback initialized');
    } catch (e) {
      AppLogger.warning('Failed to initialize audio feedback: $e');
    }
  }

  /// Play a beep sound (for successful scans)
  Future<void> playBeep() async {
    if (_isMuted) return;

    try {
      // Use system click sound - works on both Android and iOS
      await SystemSound.play(SystemSoundType.click);
      await HapticFeedback.mediumImpact();
    } catch (e) {
      AppLogger.warning('Failed to play beep: $e');
      // Fallback to haptic feedback only
      await HapticFeedback.mediumImpact();
    }
  }

  /// Play a success sound (higher pitch beep)
  Future<void> playSuccess() async {
    if (_isMuted) return;

    try {
      await HapticFeedback.heavyImpact();
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      AppLogger.warning('Failed to play success sound: $e');
    }
  }

  /// Play an error sound (lower pitch buzz)
  Future<void> playError() async {
    if (_isMuted) return;

    try {
      await HapticFeedback.heavyImpact();
      // Use alert sound for errors
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      AppLogger.warning('Failed to play error sound: $e');
    }
  }

  /// Play a click sound (for button interactions)
  Future<void> playClick() async {
    if (_isMuted) return;

    try {
      await HapticFeedback.lightImpact();
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      // Silent fail for click sounds
    }
  }

  /// Toggle mute state
  void toggleMute() {
    _isMuted = !_isMuted;
    AppLogger.info('Audio feedback ${_isMuted ? "muted" : "unmuted"}');
  }

  /// Get current mute state
  bool get isMuted => _isMuted;

  /// Clean up resources
  Future<void> dispose() async {
    // No resources to clean up since we're using system sounds
  }
}
