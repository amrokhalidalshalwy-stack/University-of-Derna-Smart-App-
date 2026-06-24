import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_project/core/services/error_tracking_service.dart'; // ← أضف هذا السطر
/// Audio Service for handling startup/welcome sound playback
/// Handles Chrome autoplay policy by requiring user interaction before playing
/// Arabic  → man_voice.mp3
/// English → alternates between eng_man_voice.mp3 and eng_woman_voice.mp3
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isInitialized = false;
  bool _hasPlayedStartupSound = false;

  static const String _englishVoiceToggleKey = 'english_voice_toggle';
  static const String _arabicVoiceToggleKey = 'arabic_voice_toggle';
  static const String _languageCodeKey = 'language_code';
  static const String _legacyLocaleKey = 'locale_code';

  // ─────────────────────────────────────────────────────────
  // Initialization
  // ─────────────────────────────────────────────────────────

  /// Pre-loads audio assets (does NOT play — respects Chrome autoplay policy)
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('🎵 [AudioService] Already initialized');
      return;
    }

    try {
      debugPrint('🎵 [AudioService] Initializing audio player...');
      _isInitialized = true;
      debugPrint('✅ [AudioService] Audio player initialized successfully');
    } catch (e, stackTrace) {
      ErrorTrackingService.recordError(e, stackTrace, context: '❌ [AudioService] Failed to initialize audio player');
      debugPrint('⚠️ [AudioService] Audio playback will be disabled');
    }
  }

  // ─────────────────────────────────────────────────────────
  // Language Detection (fallback only — prefer passing directly)
  // ─────────────────────────────────────────────────────────

  /// Reads language code from SharedPreferences.
  /// Only used as fallback when [languageCode] is NOT passed to [playStartupSound].
  Future<String> _getCurrentLanguageCode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var code =
          prefs.getString(_languageCodeKey) ??
          prefs.getString(_legacyLocaleKey);

      debugPrint('🎵 [AudioService] Raw language code from prefs: $code');

      if (code == null || code == 'system') {
        final deviceCode =
            WidgetsBinding.instance.platformDispatcher.locale.languageCode;
        code = deviceCode == 'en' ? 'en' : 'ar';
        debugPrint('🎵 [AudioService] Resolved device locale: $code');
      }

      debugPrint('🎵 [AudioService] Final language code: $code');
      return code;
    } catch (e, stackTrace) {
      ErrorTrackingService.recordError(e, stackTrace, context: '❌ [AudioService] Failed to get language code');
      return 'ar';
    }
  }

  // ─────────────────────────────────────────────────────────
  // English Voice Toggle
  // ─────────────────────────────────────────────────────────

  /// Returns true (male) or false (female) and flips the toggle for next call.
  /// Returns true for male, false for female and flips the toggle for the given language.
  Future<bool> _getAndToggleVoice(String toggleKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isMale = prefs.getBool(toggleKey) ?? true;
      await prefs.setBool(toggleKey, !isMale);
      return isMale;
    } catch (e, stackTrace) {
      ErrorTrackingService.recordError(e, stackTrace, context: '❌ [AudioService] Failed to toggle voice for $toggleKey');
      return true;
    }
  }

  // ─────────────────────────────────────────────────────────
  // Main Playback
  // ─────────────────────────────────────────────────────────

  /// Plays the startup/welcome sound.
  ///
  /// ✅ Pass [languageCode] directly from Riverpod (e.g. `locale.languageCode`)
  ///    to avoid race conditions with SharedPreferences.
  ///
  /// Arabic  (`ar`) → man_voice.mp3
  /// English (`en`) → alternates: eng_man_voice.mp3 / eng_woman_voice.mp3
  Future<void> playStartupSound({String? languageCode}) async {
    if (!_isInitialized) {
      debugPrint('⚠️ [AudioService] Not initialized — initializing now...');
      await initialize();
    }

    if (_hasPlayedStartupSound) {
      debugPrint('ℹ️ [AudioService] Startup sound already played, skipping');
      return;
    }

    try {
      // ✅ Prefer the passed languageCode; fall back to SharedPreferences
      final lang = languageCode ?? await _getCurrentLanguageCode();
      debugPrint('🎵 [AudioService] Language resolved to: $lang');

      String voiceAsset;
      String voiceLabel;

      if (lang == 'ar') {
        // Arabic toggles between male and female voices
        final isMale = await _getAndToggleVoice(_arabicVoiceToggleKey);
        voiceAsset = isMale ? 'sounds/man_voice.mp3' : 'sounds/woman_voice.mp3';
        voiceLabel = isMale ? 'Arabic (Man)' : 'Arabic (Woman)';
      } else {
        // English toggles between male and female voices
        final isMale = await _getAndToggleVoice(_englishVoiceToggleKey);
        voiceAsset =
            isMale
                ? 'sounds/derna_male_english.mp3'
                : 'sounds/derna_female_english.mp3';
        voiceLabel = isMale ? 'English (Man)' : 'English (Woman)';
      }

      debugPrint('🎵 [AudioService] Playing $voiceLabel → $voiceAsset');

      // ✅ play() alone is sufficient — no setSource() + resume() needed
      await _audioPlayer.play(AssetSource(voiceAsset));

      _hasPlayedStartupSound = true;
      debugPrint('✅ [AudioService] Sound played successfully ($voiceLabel)');
    } catch (e, stackTrace) {
      ErrorTrackingService.recordError(e, stackTrace, context: '❌ [AudioService] Failed to play startup sound');

      if (e.toString().contains('NotAllowedError') ||
          e.toString().contains('play() failed') ||
          e.toString().contains('user gesture')) {
        debugPrint('🚫 [AudioService] Chrome autoplay policy blocked audio');
        debugPrint('💡 [AudioService] Must be triggered by user interaction');
      }
    }
  }

  // ─────────────────────────────────────────────────────────
  // Utilities
  // ─────────────────────────────────────────────────────────

  /// Play any arbitrary audio asset by path
  Future<void> playAudio(String assetPath) async {
    if (!_isInitialized) await initialize();

    try {
      debugPrint('🎵 [AudioService] Playing audio: $assetPath');
      await _audioPlayer.play(AssetSource(assetPath));
      debugPrint('✅ [AudioService] Audio played successfully');
    } catch (e, stackTrace) {
      ErrorTrackingService.recordError(e, stackTrace, context: '❌ [AudioService] Failed to play audio');
    }
  }

  /// Stop any currently playing audio
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      debugPrint('🛑 [AudioService] Audio stopped');
    } catch (e, stackTrace) {
      ErrorTrackingService.recordError(e, stackTrace, context: '❌ [AudioService] Failed to stop audio');
    }
  }

  /// Release audio resources
  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
      _isInitialized = false;
      debugPrint('🗑️ [AudioService] Audio player disposed');
    } catch (e, stackTrace) {
      ErrorTrackingService.recordError(e, stackTrace, context: '❌ [AudioService] Failed to dispose audio player');
    }
  }

  bool get isInitialized => _isInitialized;
  bool get hasPlayedStartupSound => _hasPlayedStartupSound;
}

// ─────────────────────────────────────────────────────────
// Extension
// ─────────────────────────────────────────────────────────

extension AudioServiceExtension on BuildContext {
  Future<void> playStartupSoundOnInteraction({String? languageCode}) async {
    final audioService = AudioService();
    if (!audioService.hasPlayedStartupSound) {
      debugPrint('🎵 [AudioService] Triggered by user interaction');
      await audioService.playStartupSound(languageCode: languageCode);
    }
  }
}

