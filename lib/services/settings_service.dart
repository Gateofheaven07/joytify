import 'package:hive_flutter/hive_flutter.dart';
import '../models/app_settings.dart';

class SettingsService {
  static const String _settingsKey = 'app_settings';
  static Box<AppSettings>? _settingsBox;

  static Future<void> init() async {
    try {
      // Register adapters if not already registered
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(AppSettingsAdapter());
      }
      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(AudioQualityAdapter());
      }
      if (!Hive.isAdapterRegistered(6)) {
        Hive.registerAdapter(AppThemeModeAdapter());
      }
      if (!Hive.isAdapterRegistered(7)) {
        Hive.registerAdapter(TextSizeAdapter());
      }
      if (!Hive.isAdapterRegistered(8)) {
        Hive.registerAdapter(StartupBehaviorAdapter());
      }

      // Open settings box
      _settingsBox = await Hive.openBox<AppSettings>('settings');
    } catch (e) {
      print('Error initializing SettingsService: $e');
      rethrow;
    }
  }

  static Box<AppSettings> get _box {
    if (_settingsBox == null || !_settingsBox!.isOpen) {
      throw Exception('SettingsService not initialized or box is closed');
    }
    return _settingsBox!;
  }

  // Get current settings
  static AppSettings getSettings() {
    try {
      return _box.get(_settingsKey, defaultValue: const AppSettings()) ?? const AppSettings();
    } catch (e) {
      print('Error getting settings: $e');
      return const AppSettings();
    }
  }

  // Save settings
  static Future<void> saveSettings(AppSettings settings) async {
    try {
      await _box.put(_settingsKey, settings);
    } catch (e) {
      print('Error saving settings: $e');
      rethrow;
    }
  }

  // Update specific setting
  static Future<void> updateAudioQuality(AudioQuality quality) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(audioQuality: quality));
  }

  static Future<void> updateVolumeNormalization(bool enabled) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(volumeNormalization: enabled));
  }

  static Future<void> updateCrossfadeDuration(int duration) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(crossfadeDuration: duration));
  }

  static Future<void> updateGaplessPlayback(bool enabled) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(gaplessPlayback: enabled));
  }

  static Future<void> updateThemeMode(AppThemeMode mode) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(themeMode: mode));
  }

  static Future<void> updateLanguage(String language) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(language: language));
  }

  static Future<void> updateTextSize(TextSize size) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(textSize: size));
  }

  static Future<void> updateMaxCacheSize(int size) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(maxCacheSize: size));
  }

  static Future<void> updateOfflineMode(bool enabled) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(offlineMode: enabled));
  }

  static Future<void> updatePushNotifications(bool enabled) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(pushNotifications: enabled));
  }

  static Future<void> updateSoundNotifications(bool enabled) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(soundNotifications: enabled));
  }

  static Future<void> updateDataSharing(bool enabled) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(dataSharing: enabled));
  }

  static Future<void> updateAnalytics(bool enabled) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(analytics: enabled));
  }

  static Future<void> updateAutoPlay(bool enabled) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(autoPlay: enabled));
  }

  static Future<void> updateStartupBehavior(StartupBehavior behavior) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(startupBehavior: behavior));
  }

  static Future<void> updateShowLyrics(bool enabled) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(showLyrics: enabled));
  }

  // Reset to defaults
  static Future<void> resetToDefaults() async {
    await saveSettings(const AppSettings());
  }

  // Clear cache (placeholder for actual implementation)
  static Future<void> clearCache() async {
    // In a real app, this would clear audio cache, covers cache, etc.
    print('Cache cleared');
  }

  // Get cache size (placeholder for actual implementation)
  static Future<int> getCacheSize() async {
    // In a real app, this would calculate actual cache size
    return 45; // MB (placeholder)
  }
}
