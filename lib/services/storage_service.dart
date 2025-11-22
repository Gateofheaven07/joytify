import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

class StorageService {
  static const String _userBoxName = 'users';
  static const String _playlistBoxName = 'playlists';
  static const String _currentUserBoxName = 'current_user';
  static const String _settingsBoxName = 'settings';

  static late Box<User> _userBox;
  static late Box<Playlist> _playlistBox;
  static late Box<String> _currentUserBox;
  static late Box<dynamic> _settingsBox;

  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      await Hive.initFlutter();
      
      // Register adapters
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(UserAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(PlaylistAdapter());
      }
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(SongAdapter());
      }
      
      // Open boxes
      _userBox = await Hive.openBox<User>(_userBoxName);
      _playlistBox = await Hive.openBox<Playlist>(_playlistBoxName);
      _currentUserBox = await Hive.openBox<String>(_currentUserBoxName);
      _settingsBox = await Hive.openBox(_settingsBoxName);
      
      _isInitialized = true;
    } catch (e) {
      print('Error initializing Hive: $e');
      // Try to open boxes anyway (might already be open)
      try {
        if (!_userBox.isOpen) {
          _userBox = await Hive.openBox<User>(_userBoxName);
        }
        if (!_playlistBox.isOpen) {
          _playlistBox = await Hive.openBox<Playlist>(_playlistBoxName);
        }
        if (!_currentUserBox.isOpen) {
          _currentUserBox = await Hive.openBox<String>(_currentUserBoxName);
        }
        if (!_settingsBox.isOpen) {
          _settingsBox = await Hive.openBox(_settingsBoxName);
        }
        _isInitialized = true;
      } catch (e2) {
        print('Error opening boxes: $e2');
        // App will continue but storage won't work
      }
    }
  }

  // User Management
  static Future<void> saveUser(User user) async {
    await _userBox.put(user.id, user);
  }

  static Future<void> updateUser(User user) async {
    await _userBox.put(user.id, user);
  }

  static User? getUser(String userId) {
    return _userBox.get(userId);
  }

  static User? getUserByEmail(String email) {
    return _userBox.values.cast<User?>().firstWhere(
      (user) => user?.email == email,
      orElse: () => null,
    );
  }

  static List<User> getAllUsers() {
    return _userBox.values.toList();
  }

  static Future<void> deleteUser(String userId) async {
    await _userBox.delete(userId);
  }

  // Current User Session
  static Future<void> setCurrentUser(String userId) async {
    await _currentUserBox.put('current_user_id', userId);
  }

  static String? getCurrentUserId() {
    return _currentUserBox.get('current_user_id');
  }

  static User? getCurrentUser() {
    final userId = getCurrentUserId();
    if (userId == null) return null;
    return getUser(userId);
  }

  static Future<void> clearCurrentUser() async {
    await _currentUserBox.clear();
  }

  // Playlist Management
  static Future<void> savePlaylist(Playlist playlist) async {
    await _playlistBox.put(playlist.id, playlist);
  }

  static Playlist? getPlaylist(String playlistId) {
    return _playlistBox.get(playlistId);
  }

  static List<Playlist> getUserPlaylists(String userId) {
    return _playlistBox.values
        .where((playlist) => playlist.userId == userId)
        .toList();
  }

  static List<Playlist> getAllPlaylists() {
    return _playlistBox.values.toList();
  }

  static Future<void> deletePlaylist(String playlistId) async {
    await _playlistBox.delete(playlistId);
  }

  // Settings Management
  static Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  static T? getSetting<T>(String key) {
    return _settingsBox.get(key) as T?;
  }

  static bool isDarkMode() {
    return getSetting<bool>('dark_mode') ?? true; // Default to dark mode
  }

  static Future<void> setDarkMode(bool isDark) async {
    await saveSetting('dark_mode', isDark);
  }

  // Volume settings
  static double getVolume() {
    return getSetting<double>('volume') ?? 0.7;
  }

  static Future<void> setVolume(double volume) async {
    await saveSetting('volume', volume);
  }

  // Sleep timer settings
  static int? getSleepTimer() {
    return getSetting<int>('sleep_timer_minutes');
  }

  static Future<void> setSleepTimer(int? minutes) async {
    if (minutes == null) {
      await _settingsBox.delete('sleep_timer_minutes');
    } else {
      await saveSetting('sleep_timer_minutes', minutes);
    }
  }

  // Clear all data (logout/reset)
  static Future<void> clearAllData() async {
    await _userBox.clear();
    await _playlistBox.clear();
    await _currentUserBox.clear();
    await _settingsBox.clear();
  }

  // Close all boxes
  static Future<void> close() async {
    await _userBox.close();
    await _playlistBox.close();
    await _currentUserBox.close();
    await _settingsBox.close();
  }
}
