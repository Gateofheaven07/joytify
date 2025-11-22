import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'app_settings.g.dart';

@JsonSerializable()
@HiveType(typeId: 4)
class AppSettings extends Equatable {
  // Audio Settings
  @HiveField(0)
  final AudioQuality audioQuality;
  
  @HiveField(1)
  final bool volumeNormalization;
  
  @HiveField(2)
  final int crossfadeDuration;
  
  @HiveField(3)
  final bool gaplessPlayback;
  
  // Display Settings
  @HiveField(4)
  final AppThemeMode themeMode;
  
  @HiveField(5)
  final String language;
  
  @HiveField(6)
  final TextSize textSize;
  
  // Storage Settings
  @HiveField(7)
  final int maxCacheSize;
  
  @HiveField(8)
  final bool offlineMode;
  
  // Notifications Settings
  @HiveField(9)
  final bool pushNotifications;
  
  @HiveField(10)
  final bool soundNotifications;
  
  // Privacy Settings
  @HiveField(11)
  final bool dataSharing;
  
  @HiveField(12)
  final bool analytics;
  
  // General Settings
  @HiveField(13)
  final bool autoPlay;
  
  @HiveField(14)
  final StartupBehavior startupBehavior;
  
  @HiveField(15)
  final bool showLyrics;

  const AppSettings({
    this.audioQuality = AudioQuality.high,
    this.volumeNormalization = true,
    this.crossfadeDuration = 3,
    this.gaplessPlayback = true,
    this.themeMode = AppThemeMode.dark,
    this.language = 'id',
    this.textSize = TextSize.medium,
    this.maxCacheSize = 1024, // MB
    this.offlineMode = false,
    this.pushNotifications = true,
    this.soundNotifications = true,
    this.dataSharing = false,
    this.analytics = true,
    this.autoPlay = true,
    this.startupBehavior = StartupBehavior.home,
    this.showLyrics = true,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$AppSettingsToJson(this);

  @override
  List<Object?> get props => [
        audioQuality,
        volumeNormalization,
        crossfadeDuration,
        gaplessPlayback,
        themeMode,
        language,
        textSize,
        maxCacheSize,
        offlineMode,
        pushNotifications,
        soundNotifications,
        dataSharing,
        analytics,
        autoPlay,
        startupBehavior,
        showLyrics,
      ];

  AppSettings copyWith({
    AudioQuality? audioQuality,
    bool? volumeNormalization,
    int? crossfadeDuration,
    bool? gaplessPlayback,
    AppThemeMode? themeMode,
    String? language,
    TextSize? textSize,
    int? maxCacheSize,
    bool? offlineMode,
    bool? pushNotifications,
    bool? soundNotifications,
    bool? dataSharing,
    bool? analytics,
    bool? autoPlay,
    StartupBehavior? startupBehavior,
    bool? showLyrics,
  }) {
    return AppSettings(
      audioQuality: audioQuality ?? this.audioQuality,
      volumeNormalization: volumeNormalization ?? this.volumeNormalization,
      crossfadeDuration: crossfadeDuration ?? this.crossfadeDuration,
      gaplessPlayback: gaplessPlayback ?? this.gaplessPlayback,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      textSize: textSize ?? this.textSize,
      maxCacheSize: maxCacheSize ?? this.maxCacheSize,
      offlineMode: offlineMode ?? this.offlineMode,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      soundNotifications: soundNotifications ?? this.soundNotifications,
      dataSharing: dataSharing ?? this.dataSharing,
      analytics: analytics ?? this.analytics,
      autoPlay: autoPlay ?? this.autoPlay,
      startupBehavior: startupBehavior ?? this.startupBehavior,
      showLyrics: showLyrics ?? this.showLyrics,
    );
  }
}

@HiveType(typeId: 5)
enum AudioQuality {
  @HiveField(0)
  low,
  
  @HiveField(1)
  medium,
  
  @HiveField(2)
  high,
  
  @HiveField(3)
  lossless,
}

@HiveType(typeId: 6)
enum AppThemeMode {
  @HiveField(0)
  light,
  
  @HiveField(1)
  dark,
  
  @HiveField(2)
  system,
}

@HiveType(typeId: 7)
enum TextSize {
  @HiveField(0)
  small,
  
  @HiveField(1)
  medium,
  
  @HiveField(2)
  large,
}

@HiveType(typeId: 8)
enum StartupBehavior {
  @HiveField(0)
  home,
  
  @HiveField(1)
  lastPlayed,
  
  @HiveField(2)
  library,
}

// Extension methods for better display
extension AudioQualityExtension on AudioQuality {
  String get displayName {
    switch (this) {
      case AudioQuality.low:
        return 'Rendah (96 kbps)';
      case AudioQuality.medium:
        return 'Sedang (160 kbps)';
      case AudioQuality.high:
        return 'Tinggi (320 kbps)';
      case AudioQuality.lossless:
        return 'Lossless (FLAC)';
    }
  }
}

extension AppThemeModeExtension on AppThemeMode {
  String get displayName {
    switch (this) {
      case AppThemeMode.light:
        return 'Terang';
      case AppThemeMode.dark:
        return 'Gelap';
      case AppThemeMode.system:
        return 'Sistem';
    }
  }
}

extension TextSizeExtension on TextSize {
  String get displayName {
    switch (this) {
      case TextSize.small:
        return 'Kecil';
      case TextSize.medium:
        return 'Sedang';
      case TextSize.large:
        return 'Besar';
    }
  }
}

extension StartupBehaviorExtension on StartupBehavior {
  String get displayName {
    switch (this) {
      case StartupBehavior.home:
        return 'Beranda';
      case StartupBehavior.lastPlayed:
        return 'Terakhir Diputar';
      case StartupBehavior.library:
        return 'Perpustakaan';
    }
  }
}
