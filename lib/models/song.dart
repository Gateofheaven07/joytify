import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'song.g.dart';

@JsonSerializable()
@HiveType(typeId: 0)
class Song extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String artist;
  
  @HiveField(3)
  final String genre;
  
  @HiveField(4)
  final String duration;
  
  @HiveField(5)
  final int durationSeconds;
  
  @HiveField(6)
  final String audioPath;
  
  @HiveField(7)
  final String coverPath;
  
  @HiveField(8)
  final String album;
  
  @HiveField(9)
  final int year;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.genre,
    required this.duration,
    required this.durationSeconds,
    required this.audioPath,
    required this.coverPath,
    required this.album,
    required this.year,
  });

  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);
  Map<String, dynamic> toJson() => _$SongToJson(this);

  @override
  List<Object?> get props => [
        id,
        title,
        artist,
        genre,
        duration,
        durationSeconds,
        audioPath,
        coverPath,
        album,
        year,
      ];

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? genre,
    String? duration,
    int? durationSeconds,
    String? audioPath,
    String? coverPath,
    String? album,
    int? year,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      genre: genre ?? this.genre,
      duration: duration ?? this.duration,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      audioPath: audioPath ?? this.audioPath,
      coverPath: coverPath ?? this.coverPath,
      album: album ?? this.album,
      year: year ?? this.year,
    );
  }
}
