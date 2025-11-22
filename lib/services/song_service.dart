import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/models.dart';
import 'storage_service.dart';

class SongService {
  static List<Song> _allSongs = [];
  static List<Genre> _allGenres = [];
  static bool _isInitialized = false;

  // Load songs from JSON assets
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Load songs data from JSON
      final String jsonString = await rootBundle.loadString('assets/data/songs.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Parse songs
      final List<dynamic> songsJson = jsonData['songs'] ?? [];
      _allSongs = songsJson.map((json) => Song.fromJson(json)).toList();

      // Parse genres
      final List<dynamic> genresJson = jsonData['genres'] ?? [];
      _allGenres = genresJson.map((json) => Genre.fromJson(json)).toList();

      _isInitialized = true;
    } catch (e) {
      print('Error loading songs: $e');
      // Fallback to default genres if JSON loading fails
      _allGenres = List.from(Genre.defaultGenres);
    }
  }

  // Get methods
  static List<Song> getAllSongs() {
    return List.from(_allSongs);
  }

  static List<Genre> getAllGenres() {
    return List.from(_allGenres);
  }

  static Song? getSongById(String id) {
    try {
      return _allSongs.firstWhere((song) => song.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Song> getSongsByIds(List<String> ids) {
    return ids
        .map((id) => getSongById(id))
        .where((song) => song != null)
        .cast<Song>()
        .toList();
  }

  static List<Song> getSongsByGenre(String genre) {
    return _allSongs.where((song) => song.genre.toLowerCase() == genre.toLowerCase()).toList();
  }

  // Search functionality
  static List<Song> searchSongs(String query) {
    if (query.isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    return _allSongs.where((song) {
      return song.title.toLowerCase().contains(lowerQuery) ||
             song.artist.toLowerCase().contains(lowerQuery) ||
             song.album.toLowerCase().contains(lowerQuery) ||
             song.genre.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Get popular songs (can be based on play count in a real app)
  static List<Song> getPopularSongs({int limit = 10}) {
    final songs = List<Song>.from(_allSongs);
    songs.shuffle(); // Random for now, in real app would be based on analytics
    return songs.take(limit).toList();
  }

  // Get recently added songs (based on year or ID)
  static List<Song> getRecentSongs({int limit = 10}) {
    final songs = List<Song>.from(_allSongs);
    songs.sort((a, b) => b.year.compareTo(a.year));
    return songs.take(limit).toList();
  }

  // Get recommended songs based on user's liked songs
  static List<Song> getRecommendedSongs({int limit = 10}) {
    final user = StorageService.getCurrentUser();
    if (user == null || user.likedSongs.isEmpty) {
      return getPopularSongs(limit: limit);
    }

    // Get genres of liked songs
    final likedSongs = getSongsByIds(user.likedSongs);
    final likedGenres = likedSongs.map((song) => song.genre).toSet();

    // Find songs from same genres that user hasn't liked
    final recommended = _allSongs.where((song) {
      return likedGenres.contains(song.genre) && !user.likedSongs.contains(song.id);
    }).toList();

    recommended.shuffle();
    return recommended.take(limit).toList();
  }

  // Playlist operations
  static Future<String> createPlaylist({
    required String name,
    String description = '',
    List<String> songIds = const [],
  }) async {
    final user = StorageService.getCurrentUser();
    if (user == null) throw Exception('User not logged in');

    final playlistId = _generatePlaylistId();
    final now = DateTime.now();

    final playlist = Playlist(
      id: playlistId,
      name: name,
      description: description,
      userId: user.id,
      songIds: List.from(songIds),
      createdAt: now,
      updatedAt: now,
    );

    await StorageService.savePlaylist(playlist);
    
    // Update user's playlist IDs
    final updatedUser = user.addPlaylist(playlistId);
    await StorageService.saveUser(updatedUser);

    return playlistId;
  }

  static Future<void> updatePlaylist({
    required String playlistId,
    String? name,
    String? description,
    List<String>? songIds,
  }) async {
    final playlist = StorageService.getPlaylist(playlistId);
    if (playlist == null) throw Exception('Playlist not found');

    final user = StorageService.getCurrentUser();
    if (user == null || playlist.userId != user.id) {
      throw Exception('Unauthorized');
    }

    final updatedPlaylist = playlist.copyWith(
      name: name,
      description: description,
      songIds: songIds,
      updatedAt: DateTime.now(),
    );

    await StorageService.savePlaylist(updatedPlaylist);
  }

  static Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final playlist = StorageService.getPlaylist(playlistId);
    if (playlist == null) throw Exception('Playlist not found');

    final user = StorageService.getCurrentUser();
    if (user == null || playlist.userId != user.id) {
      throw Exception('Unauthorized');
    }

    final updatedPlaylist = playlist.addSong(songId);
    await StorageService.savePlaylist(updatedPlaylist);
  }

  static Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final playlist = StorageService.getPlaylist(playlistId);
    if (playlist == null) throw Exception('Playlist not found');

    final user = StorageService.getCurrentUser();
    if (user == null || playlist.userId != user.id) {
      throw Exception('Unauthorized');
    }

    final updatedPlaylist = playlist.removeSong(songId);
    await StorageService.savePlaylist(updatedPlaylist);
  }

  static Future<void> deletePlaylist(String playlistId) async {
    final playlist = StorageService.getPlaylist(playlistId);
    if (playlist == null) throw Exception('Playlist not found');

    final user = StorageService.getCurrentUser();
    if (user == null || playlist.userId != user.id) {
      throw Exception('Unauthorized');
    }

    await StorageService.deletePlaylist(playlistId);

    // Remove from user's playlist IDs
    final updatedUser = user.removePlaylist(playlistId);
    await StorageService.saveUser(updatedUser);
  }

  // Liked songs operations
  static Future<void> toggleLikeSong(String songId) async {
    final user = StorageService.getCurrentUser();
    if (user == null) throw Exception('User not logged in');

    final updatedUser = user.hasLikedSong(songId)
        ? user.removeLikedSong(songId)
        : user.addLikedSong(songId);

    await StorageService.saveUser(updatedUser);
  }

  static bool isSongLiked(String songId) {
    final user = StorageService.getCurrentUser();
    return user?.hasLikedSong(songId) ?? false;
  }

  static List<Song> getLikedSongs() {
    final user = StorageService.getCurrentUser();
    if (user == null) return [];
    return getSongsByIds(user.likedSongs);
  }

  // Get user's playlists
  static List<Playlist> getUserPlaylists() {
    final user = StorageService.getCurrentUser();
    if (user == null) return [];
    return StorageService.getUserPlaylists(user.id);
  }

  // Get songs from a playlist
  static List<Song> getPlaylistSongs(String playlistId) {
    final playlist = StorageService.getPlaylist(playlistId);
    if (playlist == null) return [];
    return getSongsByIds(playlist.songIds);
  }

  // Utility methods
  static String _generatePlaylistId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'playlist_$timestamp';
  }

  // Statistics
  static Map<String, int> getGenreStatistics() {
    final genreCount = <String, int>{};
    for (final song in _allSongs) {
      genreCount[song.genre] = (genreCount[song.genre] ?? 0) + 1;
    }
    return genreCount;
  }

  static int getTotalSongs() => _allSongs.length;
  static int getTotalGenres() => _allGenres.length;

  // Get featured playlists (for home screen)
  static List<Map<String, dynamic>> getFeaturedPlaylists() {
    return [
      {
        'name': 'Top Hits',
        'description': 'Lagu-lagu populer terkini',
        'songs': getPopularSongs(limit: 20),
        'color': '#FF6B6B',
      },
      {
        'name': 'Recently Added',
        'description': 'Lagu-lagu terbaru',
        'songs': getRecentSongs(limit: 15),
        'color': '#4ECDC4',
      },
      {
        'name': 'For You',
        'description': 'Rekomendasi khusus untukmu',
        'songs': getRecommendedSongs(limit: 12),
        'color': '#45B7D1',
      },
    ];
  }
}
