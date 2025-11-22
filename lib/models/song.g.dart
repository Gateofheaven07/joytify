// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SongAdapter extends TypeAdapter<Song> {
  @override
  final int typeId = 0;

  @override
  Song read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Song(
      id: fields[0] as String,
      title: fields[1] as String,
      artist: fields[2] as String,
      genre: fields[3] as String,
      duration: fields[4] as String,
      durationSeconds: fields[5] as int,
      audioPath: fields[6] as String,
      coverPath: fields[7] as String,
      album: fields[8] as String,
      year: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Song obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.artist)
      ..writeByte(3)
      ..write(obj.genre)
      ..writeByte(4)
      ..write(obj.duration)
      ..writeByte(5)
      ..write(obj.durationSeconds)
      ..writeByte(6)
      ..write(obj.audioPath)
      ..writeByte(7)
      ..write(obj.coverPath)
      ..writeByte(8)
      ..write(obj.album)
      ..writeByte(9)
      ..write(obj.year);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Song _$SongFromJson(Map<String, dynamic> json) => Song(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      genre: json['genre'] as String,
      duration: json['duration'] as String,
      durationSeconds: (json['durationSeconds'] as num).toInt(),
      audioPath: json['audioPath'] as String,
      coverPath: json['coverPath'] as String,
      album: json['album'] as String,
      year: (json['year'] as num).toInt(),
    );

Map<String, dynamic> _$SongToJson(Song instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'artist': instance.artist,
      'genre': instance.genre,
      'duration': instance.duration,
      'durationSeconds': instance.durationSeconds,
      'audioPath': instance.audioPath,
      'coverPath': instance.coverPath,
      'album': instance.album,
      'year': instance.year,
    };
