import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Joytify';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Aplikasi Pemutar Musik Web seperti Spotify';

  // Layout Constants
  static const double sidebarWidth = 240.0;
  static const double miniPlayerHeight = 80.0;
  static const double maxPlayerHeight = 600.0;
  static const double bottomNavHeight = 60.0;

  // Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusXxl = 32.0;

  // Animation Durations
  static const Duration animationShort = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationLong = Duration(milliseconds: 500);

  // Player Constants
  static const double minVolume = 0.0;
  static const double maxVolume = 1.0;
  static const double defaultVolume = 0.7;
  static const Duration seekForwardDuration = Duration(seconds: 15);
  static const Duration seekBackwardDuration = Duration(seconds: 15);

  // Sleep Timer Options (in minutes)
  static const List<int> sleepTimerOptions = [15, 30, 45, 60, 90, 120];

  // Grid/List Constants
  static const int songsPerPageMobile = 20;
  static const int songsPerPageDesktop = 50;
  static const double albumCoverSize = 200.0;
  static const double albumCoverSizeSmall = 60.0;
  static const double albumCoverSizeMini = 40.0;

  // Error Messages
  static const String errorGeneral = 'Terjadi kesalahan. Silakan coba lagi.';
  static const String errorNetwork = 'Tidak dapat terhubung. Periksa koneksi internet Anda.';
  static const String errorAuth = 'Gagal melakukan autentikasi.';
  static const String errorNotFound = 'Data tidak ditemukan.';
  static const String errorPermission = 'Anda tidak memiliki izin untuk melakukan aksi ini.';

  // Success Messages
  static const String successLogin = 'Login berhasil!';
  static const String successRegister = 'Registrasi berhasil!';
  static const String successPlaylistCreated = 'Playlist berhasil dibuat!';
  static const String successPlaylistUpdated = 'Playlist berhasil diperbarui!';
  static const String successSongAdded = 'Lagu berhasil ditambahkan!';
  static const String successSongRemoved = 'Lagu berhasil dihapus!';

  // Validation Rules
  static const int minPasswordLength = 6;
  static const int maxPlaylistNameLength = 50;
  static const int maxPlaylistDescriptionLength = 200;

  // Storage Keys
  static const String keyCurrentUser = 'current_user';
  static const String keyDarkMode = 'dark_mode';
  static const String keyVolume = 'volume';
  static const String keySleepTimer = 'sleep_timer';
  static const String keyLastPlayedSong = 'last_played_song';
  static const String keyLastPlaylist = 'last_playlist';

  // Route Names
  static const String routeSplash = '/';
  static const String routeAuth = '/auth';
  static const String routeHome = '/home';
  static const String routeSearch = '/search';
  static const String routePlaylists = '/playlists';
  static const String routeLikedSongs = '/liked';
  static const String routePlayer = '/player';
  static const String routeSettings = '/settings';
  static const String routeProfile = '/profile';

  // Navigation Items
  static const List<NavigationItem> navigationItems = [
    NavigationItem(
      icon: Icons.home,
      activeIcon: Icons.home,
      label: 'Home',
      route: routeHome,
    ),
    NavigationItem(
      icon: Icons.search,
      activeIcon: Icons.search,
      label: 'Search',
      route: routeSearch,
    ),
    NavigationItem(
      icon: Icons.queue_music,
      activeIcon: Icons.queue_music,
      label: 'Playlist',
      route: routePlaylists,
    ),
    NavigationItem(
      icon: Icons.favorite_border,
      activeIcon: Icons.favorite,
      label: 'Liked',
      route: routeLikedSongs,
    ),
  ];

  // Genre Icons
  static const Map<String, IconData> genreIcons = {
    'Pop': Icons.star,
    'Rock': Icons.electric_bolt,
    'Jazz': Icons.piano,
    'Lo-Fi': Icons.nights_stay,
    'Indie': Icons.palette,
  };

  // Default Placeholder Images
  static const String defaultAlbumCover = 'assets/images/default_album.png';
  static const String defaultUserAvatar = 'assets/images/default_avatar.png';
  static const String appLogo = 'assets/images/logo.png';

  // Web-specific constants
  static const String webTitle = 'Joytify - Pemutar Musik Web';
  static const String webDescription = 'Nikmati musik favorit Anda dengan Joytify, pemutar musik web yang modern dan elegan.';
  
  // SEO/Meta tags
  static const List<String> webKeywords = [
    'musik',
    'pemutar musik',
    'spotify',
    'streaming',
    'playlist',
    'lagu',
    'audio',
    'web player',
  ];
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}

// Helper classes for responsive design
class Responsive {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < AppConstants.mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppConstants.mobileBreakpoint && width < AppConstants.desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppConstants.desktopBreakpoint;
  }

  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Get number of columns for grid based on screen size
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) {
      return 2;
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 5;
    }
  }

  // Get appropriate font size based on screen size
  static double getFontSize(BuildContext context, double baseSize) {
    if (isMobile(context)) {
      return baseSize * 0.9;
    } else if (isTablet(context)) {
      return baseSize;
    } else {
      return baseSize * 1.1;
    }
  }
}

// Utility extensions
extension StringExtension on String {
  String get capitalize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  String get truncate {
    if (length <= 30) return this;
    return '${substring(0, 30)}...';
  }
}

extension DurationExtension on Duration {
  String get formatTime {
    final minutes = inMinutes;
    final seconds = inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
