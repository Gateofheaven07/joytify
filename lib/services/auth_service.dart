import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import '../models/models.dart';
import 'storage_service.dart';

class AuthService {
  static const int _minPasswordLength = 6;

  // Generate a unique user ID
  static String _generateUserId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = random.nextInt(999999);
    return 'user_${timestamp}_$randomSuffix';
  }

  // Hash password using SHA-256
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Validate email format
  static bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  // Register new user
  static Future<AuthResult> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Validate input
      if (email.isEmpty || password.isEmpty || displayName.isEmpty) {
        return AuthResult.failure('Semua field harus diisi');
      }

      if (!_isValidEmail(email)) {
        return AuthResult.failure('Format email tidak valid');
      }

      if (password.length < _minPasswordLength) {
        return AuthResult.failure(
          'Password minimal $_minPasswordLength karakter',
        );
      }

      // Check if email already exists
      final existingUser = StorageService.getUserByEmail(email);
      if (existingUser != null) {
        return AuthResult.failure('Email sudah terdaftar');
      }

      // Create new user
      final user = User(
        id: _generateUserId(),
        email: email.toLowerCase().trim(),
        hashedPassword: _hashPassword(password),
        displayName: displayName.trim(),
        createdAt: DateTime.now(),
      );

      // Save user to storage
      await StorageService.saveUser(user);
      await StorageService.setCurrentUser(user.id);

      return AuthResult.success(user, 'Registrasi berhasil!');
    } catch (e) {
      return AuthResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // Login user
  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      // Validate input
      if (email.isEmpty || password.isEmpty) {
        return AuthResult.failure('Email dan password harus diisi');
      }

      // Find user by email
      final user = StorageService.getUserByEmail(email.toLowerCase().trim());
      if (user == null) {
        return AuthResult.failure('Email tidak terdaftar');
      }

      // Verify password
      final hashedInputPassword = _hashPassword(password);
      if (user.hashedPassword != hashedInputPassword) {
        return AuthResult.failure('Password salah');
      }

      // Set current user
      await StorageService.setCurrentUser(user.id);

      return AuthResult.success(user, 'Login berhasil!');
    } catch (e) {
      return AuthResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // Logout user
  static Future<void> logout() async {
    await StorageService.clearCurrentUser();
  }

  // Get current logged in user
  static User? getCurrentUser() {
    return StorageService.getCurrentUser();
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    try {
      return getCurrentUser() != null;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Change password
  static Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = getCurrentUser();
      if (user == null) {
        return AuthResult.failure('User tidak ditemukan');
      }

      // Verify current password
      final hashedCurrentPassword = _hashPassword(currentPassword);
      if (user.hashedPassword != hashedCurrentPassword) {
        return AuthResult.failure('Password lama salah');
      }

      // Validate new password
      if (newPassword.length < _minPasswordLength) {
        return AuthResult.failure(
          'Password baru minimal $_minPasswordLength karakter',
        );
      }

      // Update password
      final updatedUser = user.copyWith(
        hashedPassword: _hashPassword(newPassword),
      );

      await StorageService.saveUser(updatedUser);

      return AuthResult.success(updatedUser, 'Password berhasil diubah!');
    } catch (e) {
      return AuthResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // Update user profile
  static Future<AuthResult> updateProfile({
    String? displayName,
  }) async {
    try {
      final user = getCurrentUser();
      if (user == null) {
        return AuthResult.failure('User tidak ditemukan');
      }

      final updatedUser = user.copyWith(
        displayName: displayName?.trim(),
      );

      await StorageService.saveUser(updatedUser);

      return AuthResult.success(updatedUser, 'Profil berhasil diupdate!');
    } catch (e) {
      return AuthResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // Delete user account
  static Future<AuthResult> deleteAccount() async {
    try {
      final user = getCurrentUser();
      if (user == null) {
        return AuthResult.failure('User tidak ditemukan');
      }

      // Delete user's playlists
      final userPlaylists = StorageService.getUserPlaylists(user.id);
      for (final playlist in userPlaylists) {
        await StorageService.deletePlaylist(playlist.id);
      }

      // Delete user
      await StorageService.deleteUser(user.id);
      await StorageService.clearCurrentUser();

      return AuthResult.success(null, 'Akun berhasil dihapus');
    } catch (e) {
      return AuthResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }
}

// Auth result class
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String message;

  AuthResult._({
    required this.isSuccess,
    this.user,
    required this.message,
  });

  factory AuthResult.success(User? user, String message) {
    return AuthResult._(
      isSuccess: true,
      user: user,
      message: message,
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(
      isSuccess: false,
      user: null,
      message: message,
    );
  }
}
