// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 4;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      audioQuality: fields[0] as AudioQuality,
      volumeNormalization: fields[1] as bool,
      crossfadeDuration: fields[2] as int,
      gaplessPlayback: fields[3] as bool,
      themeMode: fields[4] as AppThemeMode,
      language: fields[5] as String,
      textSize: fields[6] as TextSize,
      maxCacheSize: fields[7] as int,
      offlineMode: fields[8] as bool,
      pushNotifications: fields[9] as bool,
      soundNotifications: fields[10] as bool,
      dataSharing: fields[11] as bool,
      analytics: fields[12] as bool,
      autoPlay: fields[13] as bool,
      startupBehavior: fields[14] as StartupBehavior,
      showLyrics: fields[15] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.audioQuality)
      ..writeByte(1)
      ..write(obj.volumeNormalization)
      ..writeByte(2)
      ..write(obj.crossfadeDuration)
      ..writeByte(3)
      ..write(obj.gaplessPlayback)
      ..writeByte(4)
      ..write(obj.themeMode)
      ..writeByte(5)
      ..write(obj.language)
      ..writeByte(6)
      ..write(obj.textSize)
      ..writeByte(7)
      ..write(obj.maxCacheSize)
      ..writeByte(8)
      ..write(obj.offlineMode)
      ..writeByte(9)
      ..write(obj.pushNotifications)
      ..writeByte(10)
      ..write(obj.soundNotifications)
      ..writeByte(11)
      ..write(obj.dataSharing)
      ..writeByte(12)
      ..write(obj.analytics)
      ..writeByte(13)
      ..write(obj.autoPlay)
      ..writeByte(14)
      ..write(obj.startupBehavior)
      ..writeByte(15)
      ..write(obj.showLyrics);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AudioQualityAdapter extends TypeAdapter<AudioQuality> {
  @override
  final int typeId = 5;

  @override
  AudioQuality read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AudioQuality.low;
      case 1:
        return AudioQuality.medium;
      case 2:
        return AudioQuality.high;
      case 3:
        return AudioQuality.lossless;
      default:
        return AudioQuality.low;
    }
  }

  @override
  void write(BinaryWriter writer, AudioQuality obj) {
    switch (obj) {
      case AudioQuality.low:
        writer.writeByte(0);
        break;
      case AudioQuality.medium:
        writer.writeByte(1);
        break;
      case AudioQuality.high:
        writer.writeByte(2);
        break;
      case AudioQuality.lossless:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioQualityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppThemeModeAdapter extends TypeAdapter<AppThemeMode> {
  @override
  final int typeId = 6;

  @override
  AppThemeMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AppThemeMode.light;
      case 1:
        return AppThemeMode.dark;
      case 2:
        return AppThemeMode.system;
      default:
        return AppThemeMode.light;
    }
  }

  @override
  void write(BinaryWriter writer, AppThemeMode obj) {
    switch (obj) {
      case AppThemeMode.light:
        writer.writeByte(0);
        break;
      case AppThemeMode.dark:
        writer.writeByte(1);
        break;
      case AppThemeMode.system:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppThemeModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TextSizeAdapter extends TypeAdapter<TextSize> {
  @override
  final int typeId = 7;

  @override
  TextSize read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TextSize.small;
      case 1:
        return TextSize.medium;
      case 2:
        return TextSize.large;
      default:
        return TextSize.small;
    }
  }

  @override
  void write(BinaryWriter writer, TextSize obj) {
    switch (obj) {
      case TextSize.small:
        writer.writeByte(0);
        break;
      case TextSize.medium:
        writer.writeByte(1);
        break;
      case TextSize.large:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextSizeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StartupBehaviorAdapter extends TypeAdapter<StartupBehavior> {
  @override
  final int typeId = 8;

  @override
  StartupBehavior read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return StartupBehavior.home;
      case 1:
        return StartupBehavior.lastPlayed;
      case 2:
        return StartupBehavior.library;
      default:
        return StartupBehavior.home;
    }
  }

  @override
  void write(BinaryWriter writer, StartupBehavior obj) {
    switch (obj) {
      case StartupBehavior.home:
        writer.writeByte(0);
        break;
      case StartupBehavior.lastPlayed:
        writer.writeByte(1);
        break;
      case StartupBehavior.library:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StartupBehaviorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => AppSettings(
      audioQuality:
          $enumDecodeNullable(_$AudioQualityEnumMap, json['audioQuality']) ??
              AudioQuality.high,
      volumeNormalization: json['volumeNormalization'] as bool? ?? true,
      crossfadeDuration: (json['crossfadeDuration'] as num?)?.toInt() ?? 3,
      gaplessPlayback: json['gaplessPlayback'] as bool? ?? true,
      themeMode:
          $enumDecodeNullable(_$AppThemeModeEnumMap, json['themeMode']) ??
              AppThemeMode.dark,
      language: json['language'] as String? ?? 'id',
      textSize: $enumDecodeNullable(_$TextSizeEnumMap, json['textSize']) ??
          TextSize.medium,
      maxCacheSize: (json['maxCacheSize'] as num?)?.toInt() ?? 1024,
      offlineMode: json['offlineMode'] as bool? ?? false,
      pushNotifications: json['pushNotifications'] as bool? ?? true,
      soundNotifications: json['soundNotifications'] as bool? ?? true,
      dataSharing: json['dataSharing'] as bool? ?? false,
      analytics: json['analytics'] as bool? ?? true,
      autoPlay: json['autoPlay'] as bool? ?? true,
      startupBehavior: $enumDecodeNullable(
              _$StartupBehaviorEnumMap, json['startupBehavior']) ??
          StartupBehavior.home,
      showLyrics: json['showLyrics'] as bool? ?? true,
    );

Map<String, dynamic> _$AppSettingsToJson(AppSettings instance) =>
    <String, dynamic>{
      'audioQuality': _$AudioQualityEnumMap[instance.audioQuality]!,
      'volumeNormalization': instance.volumeNormalization,
      'crossfadeDuration': instance.crossfadeDuration,
      'gaplessPlayback': instance.gaplessPlayback,
      'themeMode': _$AppThemeModeEnumMap[instance.themeMode]!,
      'language': instance.language,
      'textSize': _$TextSizeEnumMap[instance.textSize]!,
      'maxCacheSize': instance.maxCacheSize,
      'offlineMode': instance.offlineMode,
      'pushNotifications': instance.pushNotifications,
      'soundNotifications': instance.soundNotifications,
      'dataSharing': instance.dataSharing,
      'analytics': instance.analytics,
      'autoPlay': instance.autoPlay,
      'startupBehavior': _$StartupBehaviorEnumMap[instance.startupBehavior]!,
      'showLyrics': instance.showLyrics,
    };

const _$AudioQualityEnumMap = {
  AudioQuality.low: 'low',
  AudioQuality.medium: 'medium',
  AudioQuality.high: 'high',
  AudioQuality.lossless: 'lossless',
};

const _$AppThemeModeEnumMap = {
  AppThemeMode.light: 'light',
  AppThemeMode.dark: 'dark',
  AppThemeMode.system: 'system',
};

const _$TextSizeEnumMap = {
  TextSize.small: 'small',
  TextSize.medium: 'medium',
  TextSize.large: 'large',
};

const _$StartupBehaviorEnumMap = {
  StartupBehavior.home: 'home',
  StartupBehavior.lastPlayed: 'lastPlayed',
  StartupBehavior.library: 'library',
};
