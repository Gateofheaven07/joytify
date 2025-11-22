import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'user.g.dart';

@JsonSerializable()
@HiveType(typeId: 1)
class User extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String email;
  
  @HiveField(2)
  final String hashedPassword;
  
  @HiveField(3)
  final String displayName;
  
  @HiveField(4)
  final DateTime createdAt;
  
  @HiveField(5)
  final List<String> likedSongs;
  
  @HiveField(6)
  final List<String> playlistIds;

  const User({
    required this.id,
    required this.email,
    required this.hashedPassword,
    required this.displayName,
    required this.createdAt,
    this.likedSongs = const [],
    this.playlistIds = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object?> get props => [
        id,
        email,
        hashedPassword,
        displayName,
        createdAt,
        likedSongs,
        playlistIds,
      ];

  User copyWith({
    String? id,
    String? email,
    String? hashedPassword,
    String? displayName,
    DateTime? createdAt,
    List<String>? likedSongs,
    List<String>? playlistIds,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      hashedPassword: hashedPassword ?? this.hashedPassword,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      likedSongs: likedSongs ?? this.likedSongs,
      playlistIds: playlistIds ?? this.playlistIds,
    );
  }

  // Helper methods
  bool hasLikedSong(String songId) {
    return likedSongs.contains(songId);
  }

  User addLikedSong(String songId) {
    if (hasLikedSong(songId)) return this;
    return copyWith(likedSongs: [...likedSongs, songId]);
  }

  User removeLikedSong(String songId) {
    if (!hasLikedSong(songId)) return this;
    return copyWith(
      likedSongs: likedSongs.where((id) => id != songId).toList(),
    );
  }

  User addPlaylist(String playlistId) {
    if (playlistIds.contains(playlistId)) return this;
    return copyWith(playlistIds: [...playlistIds, playlistId]);
  }

  User removePlaylist(String playlistId) {
    return copyWith(
      playlistIds: playlistIds.where((id) => id != playlistId).toList(),
    );
  }
}
