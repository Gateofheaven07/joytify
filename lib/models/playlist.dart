import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'playlist.g.dart';

@JsonSerializable()
@HiveType(typeId: 2)
class Playlist extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final String userId;
  
  @HiveField(4)
  final List<String> songIds;
  
  @HiveField(5)
  final DateTime createdAt;
  
  @HiveField(6)
  final DateTime updatedAt;
  
  @HiveField(7)
  final String? coverImagePath;

  const Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.userId,
    this.songIds = const [],
    required this.createdAt,
    required this.updatedAt,
    this.coverImagePath,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) => _$PlaylistFromJson(json);
  Map<String, dynamic> toJson() => _$PlaylistToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        userId,
        songIds,
        createdAt,
        updatedAt,
        coverImagePath,
      ];

  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    String? userId,
    List<String>? songIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? coverImagePath,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      songIds: songIds ?? this.songIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      coverImagePath: coverImagePath ?? this.coverImagePath,
    );
  }

  // Helper methods
  bool containsSong(String songId) {
    return songIds.contains(songId);
  }

  Playlist addSong(String songId) {
    if (containsSong(songId)) return this;
    return copyWith(
      songIds: [...songIds, songId],
      updatedAt: DateTime.now(),
    );
  }

  Playlist removeSong(String songId) {
    if (!containsSong(songId)) return this;
    return copyWith(
      songIds: songIds.where((id) => id != songId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  Playlist reorderSongs(List<String> newSongIds) {
    return copyWith(
      songIds: newSongIds,
      updatedAt: DateTime.now(),
    );
  }

  int get songCount => songIds.length;

  String get displayDuration {
    // This would be calculated based on actual songs
    // For now, return estimated duration
    final minutes = songIds.length * 3; // Average 3 minutes per song
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    } else {
      return '${remainingMinutes}m';
    }
  }
}
