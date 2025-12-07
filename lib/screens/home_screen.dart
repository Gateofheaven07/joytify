import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../services/services.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'faq_screen.dart';
import 'terms_screen.dart';
import 'privacy_screen.dart';
import 'genre_songs_screen.dart';
import 'player_screen.dart';
import '../widgets/mini_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;
  List<Song> _allSongs = [];
  List<Genre> _allGenres = [];
  List<Map<String, dynamic>> _featuredPlaylists = [];
  bool _isLoading = true;
  User? _currentUser;
  
  // Search state
  final TextEditingController _searchController = TextEditingController();
  List<Song> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
    } else {
      setState(() {
        _isSearching = true;
        _searchResults = SongService.searchSongs(query);
      });
    }
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);

    try {
      // Initialize song service
      await SongService.init();
      
      // Get data
      _allSongs = SongService.getAllSongs();
      _allGenres = SongService.getAllGenres();
      _featuredPlaylists = SongService.getFeaturedPlaylists();
      _currentUser = AuthService.getCurrentUser();

      setState(() => _isLoading = false);
    } catch (e) {
      print('Error initializing data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _onNavItemTapped(int index) {
    setState(() => _selectedNavIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildProfileDrawer(),
      body: Row(
        children: [
          // Sidebar (Desktop only)
          if (Responsive.isDesktop(context)) 
            _buildSidebar(),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                _buildTopAppBar(),
                
                // Content Area
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildContent(),
                ),
                
                // Mini Player
                const MiniPlayer(),
              ],
            ),
          ),
        ],
      ),
      
      // Bottom Navigation (Mobile/Tablet only)
      bottomNavigationBar: Responsive.isMobile(context) || Responsive.isTablet(context)
          ? _buildBottomNavigation()
          : null,
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: AppConstants.sidebarWidth,
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          // App Logo
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/joytify_logo_3.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Text(
                  AppConstants.appName,
                  style: AppTheme.titleLarge,
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
              children: [
                _buildNavItem(
                  icon: Icons.home,
                  label: 'Home',
                  isSelected: _selectedNavIndex == 0,
                  onTap: () => _onNavItemTapped(0),
                ),
                _buildNavItem(
                  icon: Icons.search,
                  label: 'Search',
                  isSelected: _selectedNavIndex == 1,
                  onTap: () => _onNavItemTapped(1),
                ),
                _buildNavItem(
                  icon: Icons.queue_music,
                  label: 'Your Library',
                  isSelected: _selectedNavIndex == 2,
                  onTap: () => _onNavItemTapped(2),
                ),
                
                const SizedBox(height: AppConstants.spacingL),
                
                // Quick Access
                _buildSectionHeader('Made for you'),
                _buildNavItem(
                  icon: Icons.favorite,
                  label: 'Liked Songs',
                  isSelected: false,
                  onTap: () => _onNavItemTapped(3),
                ),
                
                // User's Playlists
                ..._buildUserPlaylists(),
              ],
            ),
          ),
          
          // User Profile
          _buildUserProfile(),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingS),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
        ),
        title: Text(
          label,
          style: AppTheme.bodyLarge.copyWith(
            color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        tileColor: isSelected 
            ? AppTheme.primaryColor.withOpacity(0.1)
            : Colors.transparent,
        onTap: onTap,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
      ),
      child: Text(
        title,
        style: AppTheme.labelMedium.copyWith(
          color: AppTheme.textTertiary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<Widget> _buildUserPlaylists() {
    final playlists = SongService.getUserPlaylists();
    return playlists.take(5).map((playlist) => 
      _buildNavItem(
        icon: Icons.queue_music,
        label: playlist.name,
        isSelected: false,
        onTap: () {
          // Navigate to playlist detail
        },
      ),
    ).toList();
  }

  Widget _buildUserProfile() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              _currentUser?.displayName.substring(0, 1).toUpperCase() ?? 'U',
              style: AppTheme.titleMedium.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentUser?.displayName ?? 'User',
                  style: AppTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _currentUser?.email ?? '',
                  style: AppTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  // Navigate to profile
                  break;
                case 'settings':
                  // Navigate to settings
                  break;
                case 'logout':
                  _handleLogout();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Text('Profile'),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Text('Settings'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL, vertical: AppConstants.spacingM),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Hamburger Menu Button
          Builder(
            builder: (context) => IconButton(
              icon: Icon(
                Icons.menu_rounded,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: 'Menu',
            ),
          ),
          
          const SizedBox(width: AppConstants.spacingM),
          
          // App Title
          Expanded(
            child: Text(
              'Joytify',
              textAlign: TextAlign.center,
              style: AppTheme.headlineSmall.copyWith(
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          
          // Sleep Timer Timer Icon
          IconButton(
            icon: Icon(
              Icons.timer,
              color: Colors.white,
              size: 24,
            ),
            onPressed: _showSleepTimerDialog,
            tooltip: 'Sleep Timer',
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedNavIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildSearchContent();
      case 2:
        return _buildLibraryContent();
      case 3:
        return _buildLikedSongsContent();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return CustomScrollView(
      slivers: [
        // Quick Access
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            child: _buildQuickAccess(),
          ),
        ),
        
        // Genres
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
            child: _buildGenresSection(),
          ),
        ),
        
        // Featured Playlists
        ..._featuredPlaylists.map((playlist) => 
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
              child: _buildPlaylistSection(playlist),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccess() {
    final quickItems = [
      {
        'title': 'Liked Songs',
        'icon': Icons.favorite,
        'color': AppTheme.primaryColor,
        'onTap': () {
          _onNavItemTapped(3); // Navigate to Liked tab
        },
      },
      {
        'title': 'Top Hits',
        'icon': Icons.star,
        'color': AppTheme.accentColor,
        'onTap': () {
          _navigateToTopHits();
        },
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access',
          style: AppTheme.headlineSmall,
        ),
        const SizedBox(height: AppConstants.spacingM),
        StaggeredGrid.count(
          crossAxisCount: Responsive.isMobile(context) ? 1 : 2,
          mainAxisSpacing: AppConstants.spacingM,
          crossAxisSpacing: AppConstants.spacingM,
          children: quickItems.map((item) => 
            _buildQuickAccessCard(
              title: item['title'] as String,
              icon: item['icon'] as IconData,
              color: item['color'] as Color,
              onTap: item['onTap'] as VoidCallback,
            ),
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingS),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToTopHits() {
    final topHitsSongs = SongService.getPopularSongs(limit: 50);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _TopHitsScreen(songs: topHitsSongs),
      ),
    );
  }

  void _navigateToPlaylistScreen(Map<String, dynamic> playlist) {
    final songs = playlist['songs'] as List<Song>;
    final playlistName = playlist['name'] as String;
    final playlistColor = playlist['color'] as String?;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FeaturedPlaylistDetailScreen(
          title: playlistName,
          songs: songs,
          color: playlistColor,
        ),
      ),
    );
  }

  Widget _buildGenresSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppConstants.spacingXl),
        Text(
          'Browse by Genre',
          style: AppTheme.headlineSmall,
        ),
        const SizedBox(height: AppConstants.spacingM),
        StaggeredGrid.count(
          crossAxisCount: Responsive.getGridColumns(context),
          mainAxisSpacing: AppConstants.spacingM,
          crossAxisSpacing: AppConstants.spacingM,
          children: _allGenres.map((genre) => 
            _buildGenreCard(genre),
          ).toList(),
        ),
      ],
    );
  }

  String _getGenreImagePath(String genreName) {
    final genreMap = {
      'Pop': 'assets/images/pop_music.jpg',
      'Rock': 'assets/images/rock_music.jpg',
      'Jazz': 'assets/images/jazz_music.jpg',
      'Lo-Fi': 'assets/images/lo-fi_music.jpg',
      'Indie': 'assets/images/indie_music.jpg',
    };
    return genreMap[genreName] ?? 'assets/images/pop_music.jpg';
  }

  Widget _buildGenreCard(Genre genre) {
    final imagePath = _getGenreImagePath(genre.name);
    
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GenreSongsScreen(genre: genre),
            ),
          );
        },
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: AppConstants.spacingM,
                  left: AppConstants.spacingM,
                  child: Text(
                    genre.name,
                    style: AppTheme.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: -10,
                  right: -10,
                  child: Transform.rotate(
                    angle: 0.2,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      ),
                      child: Icon(
                        AppConstants.genreIcons[genre.name] ?? Icons.music_note,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistSection(Map<String, dynamic> playlist) {
    final songs = playlist['songs'] as List<Song>;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppConstants.spacingXl),
        Row(
          children: [
            Text(
              playlist['name'],
              style: AppTheme.headlineSmall,
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                _navigateToPlaylistScreen(playlist);
              },
              child: const Text('Show all'),
            ),
          ],
        ),
        Text(
          playlist['description'],
          style: AppTheme.bodyMedium,
        ),
        const SizedBox(height: AppConstants.spacingM),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: songs.take(10).length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: AppConstants.spacingM),
                child: _buildSongCard(song),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSongCard(Song song) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _playSongAndNavigate(song);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Album Cover
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppConstants.radiusL),
              ),
              child: Container(
                height: 120,
                width: double.infinity,
                color: AppTheme.getGenreColor(song.genre).withOpacity(0.3),
                child: song.coverPath.isNotEmpty
                    ? Image.asset(
                        song.coverPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.music_note,
                              size: 48,
                              color: Colors.white70,
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(
                          Icons.music_note,
                          size: 48,
                          color: Colors.white70,
                        ),
                      ),
              ),
            ),
            
            // Song Info - Fixed height container
            SizedBox(
              height: 62,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 4, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              song.title,
                              style: AppTheme.titleSmall.copyWith(
                                fontSize: 13,
                                height: 1.1,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 2),
                          PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_vert,
                              size: 16,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            iconSize: 16,
                            tooltip: '',
                            onSelected: (value) => _handleSongMenuAction(value, song),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'play',
                                child: Row(
                                  children: [
                                    const Icon(Icons.play_arrow, size: 18),
                                    const SizedBox(width: 8),
                                    const Text('Putar'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'like',
                                child: Row(
                                  children: [
                                    Icon(
                                      SongService.isSongLiked(song.id)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 18,
                                      color: SongService.isSongLiked(song.id)
                                          ? AppTheme.primaryColor
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      SongService.isSongLiked(song.id)
                                          ? 'Hapus dari Liked'
                                          : 'Tambah ke Liked',
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'add_to_playlist',
                                child: Row(
                                  children: [
                                    const Icon(Icons.playlist_add, size: 18),
                                    const SizedBox(width: 8),
                                    const Text('Tambah ke Playlist'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      song.artist,
                      style: AppTheme.bodySmall.copyWith(
                        fontSize: 11,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _playSongAndNavigate(Song song) {
    print('_playSongAndNavigate: Starting to play ${song.title}');
    
    // Play song without awaiting completion
    MusicService().playSong(song, playlist: _allSongs).catchError((e) {
      print('_playSongAndNavigate: Error playing song: $e');
    });

    print('_playSongAndNavigate: Navigating to PlayerScreen immediately');
    
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerScreen(),
        ),
      );
    }
  }

  void _handleSongMenuAction(String action, Song song) {
    switch (action) {
      case 'play':
        _playSongAndNavigate(song);
        break;
      case 'like':
        _toggleLikeSong(song);
        break;
      case 'add_to_playlist':
        _showAddToPlaylistDialog(song);
        break;
    }
  }

  Future<void> _toggleLikeSong(Song song) async {
    try {
      await SongService.toggleLikeSong(song.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            SongService.isSongLiked(song.id)
                ? 'Ditambahkan ke Liked Songs'
                : 'Dihapus dari Liked Songs',
          ),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {}); // Refresh UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengupdate liked songs: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showAddToPlaylistDialog(Song song) async {
    final playlists = SongService.getUserPlaylists();
    
    if (playlists.isEmpty) {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => _buildCreatePlaylistDialog(),
      );
      
      if (result != null && result.isNotEmpty) {
        try {
          await SongService.createPlaylist(
            name: result,
            songIds: [song.id],
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Playlist dibuat dan lagu ditambahkan'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal membuat playlist: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      return;
    }

    final selectedPlaylist = await showDialog<Playlist>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text(
          'Pilih Playlist',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: playlists.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  leading: const Icon(Icons.add, color: AppTheme.primaryColor),
                  title: const Text(
                    'Buat Playlist Baru',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await showDialog<String>(
                      context: context,
                      builder: (context) => _buildCreatePlaylistDialog(),
                    );
                    
                    if (result != null && result.isNotEmpty) {
                      try {
                        await SongService.createPlaylist(
                          name: result,
                          songIds: [song.id],
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Playlist dibuat dan lagu ditambahkan'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal membuat playlist: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                );
              }
              
              final playlist = playlists[index - 1];
              final isInPlaylist = playlist.songIds.contains(song.id);
              
              return ListTile(
                leading: Icon(
                  isInPlaylist ? Icons.check_circle : Icons.playlist_play,
                  color: isInPlaylist ? AppTheme.primaryColor : Colors.white,
                ),
                title: Text(
                  playlist.name,
                  style: TextStyle(
                    color: isInPlaylist ? AppTheme.primaryColor : Colors.white,
                  ),
                ),
                subtitle: Text(
                  '${playlist.songIds.length} lagu',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context, playlist);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );

    if (selectedPlaylist != null) {
      try {
        if (selectedPlaylist.songIds.contains(song.id)) {
          await SongService.removeSongFromPlaylist(selectedPlaylist.id, song.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lagu dihapus dari playlist'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          await SongService.addSongToPlaylist(selectedPlaylist.id, song.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lagu ditambahkan ke playlist'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {}); // Refresh UI to update library/playlist list
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengupdate playlist: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildCreatePlaylistDialog() {
    final controller = TextEditingController();
    
    return AlertDialog(
      backgroundColor: AppTheme.darkCard,
      title: const Text(
        'Buat Playlist Baru',
        style: TextStyle(color: Colors.white),
      ),
      content: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Nama playlist',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          filled: true,
          fillColor: AppTheme.darkBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            if (controller.text.trim().isNotEmpty) {
              Navigator.pop(context, controller.text.trim());
            }
          },
          child: const Text('Buat'),
        ),
      ],
    );
  }

  Future<void> _showCreatePlaylistDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _buildCreatePlaylistDialog(),
    );
    
    if (result != null && result.isNotEmpty) {
      try {
        await SongService.createPlaylist(
          name: result,
          songIds: [],
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Playlist berhasil dibuat'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {}); // Refresh UI to show new playlist
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat playlist: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSearchContent() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, value, child) {
                return TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Cari lagu, artis, atau album...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    suffixIcon: value.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Search Results
        Expanded(
          child: _isSearching
              ? _searchResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada hasil ditemukan',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Coba cari dengan kata kunci lain',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingL,
                      ),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final song = _searchResults[index];
                        return _buildSearchResultItem(song, index);
                      },
                    )
              : _buildSearchSuggestions(),
        ),
      ],
    );
  }

  Widget _buildSearchSuggestions() {
    return CustomScrollView(
      slivers: [
        // Recent Searches / Suggestions
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cari Musik',
                  style: AppTheme.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cari berdasarkan judul lagu, artis, album, atau genre',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Popular Genres
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
            child: Text(
              'Kategori Populer',
              style: AppTheme.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final genre = _allGenres[index];
                return _buildGenreCard(genre);
              },
              childCount: _allGenres.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResultItem(Song song, int index) {
    return Card(
      color: AppTheme.darkCard,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _playSongAndNavigate(song);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Album Cover
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 56,
                  height: 56,
                  color: AppTheme.getGenreColor(song.genre).withOpacity(0.3),
                  child: song.coverPath.isNotEmpty
                      ? Image.asset(
                          song.coverPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.music_note,
                              color: Colors.white70,
                              size: 24,
                            );
                          },
                        )
                      : const Icon(
                          Icons.music_note,
                          color: Colors.white70,
                          size: 24,
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Song Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      song.artist,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${song.album} • ${song.genre}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Duration
              Text(
                song.duration,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),

              // Menu Button
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white.withOpacity(0.7),
                ),
                onSelected: (value) => _handleSongMenuAction(value, song),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'play',
                    child: Row(
                      children: [
                        const Icon(Icons.play_arrow, size: 20),
                        const SizedBox(width: 8),
                        const Text('Putar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'like',
                    child: Row(
                      children: [
                        Icon(
                          SongService.isSongLiked(song.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 20,
                          color: SongService.isSongLiked(song.id)
                              ? AppTheme.primaryColor
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          SongService.isSongLiked(song.id)
                              ? 'Hapus dari Liked'
                              : 'Tambah ke Liked',
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'add_to_playlist',
                    child: Row(
                      children: [
                        const Icon(Icons.playlist_add, size: 20),
                        const SizedBox(width: 8),
                        const Text('Tambah ke Playlist'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLibraryContent() {
    // Refresh playlists every time this is built
    final playlists = SongService.getUserPlaylists();
    
    if (playlists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.playlist_add,
                size: 64,
                color: Colors.white.withOpacity(0.5),
              ),
              onPressed: () {
                _showCreatePlaylistDialog();
              },
              iconSize: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada playlist',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Klik icon di atas untuk membuat playlist baru',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        final songs = SongService.getPlaylistSongs(playlist.id);
        
        return Card(
          color: AppTheme.darkCard,
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              // Navigate to playlist detail screen
              _navigateToPlaylistDetail(playlist);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Playlist Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.queue_music,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Playlist Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playlist.name,
                          style: AppTheme.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${songs.length} lagu',
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Arrow Icon
                  Icon(
                    Icons.chevron_right,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLikedSongsContent() {
    // Refresh liked songs every time this is built
    final likedSongs = SongService.getLikedSongs();
    
    if (likedSongs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada lagu yang disukai',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ketuk ikon hati pada lagu untuk menambahkannya ke sini',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.7),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Liked Songs',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${likedSongs.length} lagu',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Songs List
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final song = likedSongs[index];
              return _buildSongListItem(song, index);
            },
            childCount: likedSongs.length,
          ),
        ),
      ],
    );
  }

  Widget _buildSongListItem(Song song, int index) {
    return Card(
      color: AppTheme.darkCard,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () {
          _playSongAndNavigate(song);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Song Number
              SizedBox(
                width: 32,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 12),

              // Album Cover
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 56,
                  height: 56,
                  color: AppTheme.getGenreColor(song.genre).withOpacity(0.3),
                  child: song.coverPath.isNotEmpty
                      ? Image.asset(
                          song.coverPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.music_note,
                              color: Colors.white70,
                              size: 24,
                            );
                          },
                        )
                      : const Icon(
                          Icons.music_note,
                          color: Colors.white70,
                          size: 24,
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Song Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      song.artist,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Duration
              Text(
                song.duration,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),

              // Menu Button
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white.withOpacity(0.7),
                ),
                onSelected: (value) => _handleSongMenuAction(value, song),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'play',
                    child: Row(
                      children: [
                        const Icon(Icons.play_arrow, size: 20),
                        const SizedBox(width: 8),
                        const Text('Putar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'like',
                    child: Row(
                      children: [
                        Icon(
                          SongService.isSongLiked(song.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 20,
                          color: SongService.isSongLiked(song.id)
                              ? AppTheme.primaryColor
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          SongService.isSongLiked(song.id)
                              ? 'Hapus dari Liked'
                              : 'Tambah ke Liked',
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'add_to_playlist',
                    child: Row(
                      children: [
                        const Icon(Icons.playlist_add, size: 20),
                        const SizedBox(width: 8),
                        const Text('Tambah ke Playlist'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPlaylistDetail(Playlist playlist) {
    // Navigate to a playlist detail screen (similar to GenreSongsScreen)
    // For now, we can show a dialog or navigate to a new screen
    // Let's create a simple implementation
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _PlaylistDetailScreen(playlist: playlist),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _selectedNavIndex,
      onTap: _onNavItemTapped,
      type: BottomNavigationBarType.fixed,
      items: AppConstants.navigationItems.map((item) => 
        BottomNavigationBarItem(
          icon: Icon(item.icon),
          activeIcon: Icon(item.activeIcon),
          label: item.label,
        ),
      ).toList(),
    );
  }

  void _handleLogout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/auth',
        (route) => false,
      );
    }
  }

  Widget _buildProfileDrawer() {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(24),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Profile Picture
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppTheme.primaryColor,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // User Name
                  if (_currentUser != null) ...[
                    Text(
                      _currentUser!.displayName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _currentUser!.email,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  title: 'Profile',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.help_outline,
                  title: 'Pertanyaan Umum & Masukan',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FAQScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.description_outlined,
                  title: 'Perjanjian Pengguna',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Kebijakan Privasi',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  textColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _handleLogout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? Colors.white.withOpacity(0.8),
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  void _showSleepTimerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.timer,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Sleep Timer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih waktu kapan musik akan berhenti otomatis:',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              _buildSleepTimerOption('15 menit', 15),
              _buildSleepTimerOption('30 menit', 30),
              _buildSleepTimerOption('45 menit', 45),
              _buildSleepTimerOption('1 jam', 60),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSleepTimerOption(String label, int minutes) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          _setSleepTimer(minutes);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          foregroundColor: AppTheme.primaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppTheme.primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _setSleepTimer(int minutes) {
    // TODO: Implement sleep timer functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sleep timer set for $minutes minutes'),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

// Playlist Detail Screen
class _PlaylistDetailScreen extends StatefulWidget {
  final Playlist playlist;

  const _PlaylistDetailScreen({required this.playlist});

  @override
  State<_PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<_PlaylistDetailScreen> {
  List<Song> _playlistSongs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylistSongs();
  }

  void _loadPlaylistSongs() {
    setState(() {
      _isLoading = true;
      _playlistSongs = SongService.getPlaylistSongs(widget.playlist.id);
      _isLoading = false;
    });
  }

  void _playSongAndNavigate(Song song) {
    final playlist = SongService.getPlaylistSongs(widget.playlist.id);
    // Play song without awaiting
    MusicService().playSong(song, playlist: playlist).catchError((e) {
      print('Error playing song: $e');
    });
    
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerScreen(),
        ),
      );
    }
  }

  Future<void> _handleMenuAction(String action, Song song) async {
    switch (action) {
      case 'play':
        _playSongAndNavigate(song);
        break;
      case 'like':
        await _toggleLikeSong(song);
        break;
      case 'add_to_playlist':
        await _showAddToPlaylistDialog(song);
        break;
      case 'remove_from_playlist':
        await _removeFromPlaylist(song);
        break;
    }
  }

  Future<void> _removeFromPlaylist(Song song) async {
    try {
      await SongService.removeSongFromPlaylist(widget.playlist.id, song.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lagu dihapus dari playlist'),
          backgroundColor: Colors.green,
        ),
      );
      _loadPlaylistSongs(); // Refresh playlist songs
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus lagu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleLikeSong(Song song) async {
    try {
      await SongService.toggleLikeSong(song.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            SongService.isSongLiked(song.id)
                ? 'Ditambahkan ke Liked Songs'
                : 'Dihapus dari Liked Songs',
          ),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {}); // Refresh UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengupdate liked songs: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showAddToPlaylistDialog(Song song) async {
    final playlists = SongService.getUserPlaylists();
    
    if (playlists.isEmpty) {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => _buildCreatePlaylistDialog(),
      );
      
      if (result != null && result.isNotEmpty) {
        try {
          await SongService.createPlaylist(
            name: result,
            songIds: [song.id],
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Playlist dibuat dan lagu ditambahkan'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal membuat playlist: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      return;
    }

    final selectedPlaylist = await showDialog<Playlist>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text(
          'Pilih Playlist',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              final isInPlaylist = playlist.songIds.contains(song.id);
              return ListTile(
                title: Text(
                  playlist.name,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '${playlist.songIds.length} lagu',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
                trailing: isInPlaylist
                    ? const Icon(Icons.check, color: AppTheme.primaryColor)
                    : null,
                onTap: () {
                  Navigator.pop(context, playlist);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );

    if (selectedPlaylist != null) {
      try {
        if (selectedPlaylist.songIds.contains(song.id)) {
          await SongService.removeSongFromPlaylist(selectedPlaylist.id, song.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lagu dihapus dari playlist'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          await SongService.addSongToPlaylist(selectedPlaylist.id, song.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lagu ditambahkan ke playlist'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadPlaylistSongs(); // Refresh playlist songs
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengupdate playlist: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildCreatePlaylistDialog() {
    final controller = TextEditingController();
    
    return AlertDialog(
      backgroundColor: AppTheme.darkCard,
      title: const Text(
        'Buat Playlist Baru',
        style: TextStyle(color: Colors.white),
      ),
      content: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Nama playlist',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          filled: true,
          fillColor: AppTheme.darkBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            if (controller.text.trim().isNotEmpty) {
              Navigator.pop(context, controller.text.trim());
            }
          },
          child: const Text('Buat'),
        ),
      ],
    );
  }

  Widget _buildSongListItem(Song song, int index) {
    return Card(
      color: AppTheme.darkCard,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () {
          _playSongAndNavigate(song);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Song Number
              SizedBox(
                width: 32,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 12),

              // Album Cover
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 56,
                  height: 56,
                  color: AppTheme.getGenreColor(song.genre).withOpacity(0.3),
                  child: song.coverPath.isNotEmpty
                      ? Image.asset(
                          song.coverPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.music_note,
                              color: Colors.white70,
                              size: 24,
                            );
                          },
                        )
                      : const Icon(
                          Icons.music_note,
                          color: Colors.white70,
                          size: 24,
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Song Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      song.artist,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Duration
              Text(
                song.duration,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),

              // Menu Button
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white.withOpacity(0.7),
                ),
                onSelected: (value) => _handleMenuAction(value, song),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'play',
                    child: Row(
                      children: [
                        const Icon(Icons.play_arrow, size: 20),
                        const SizedBox(width: 8),
                        const Text('Putar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'like',
                    child: Row(
                      children: [
                        Icon(
                          SongService.isSongLiked(song.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 20,
                          color: SongService.isSongLiked(song.id)
                              ? AppTheme.primaryColor
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          SongService.isSongLiked(song.id)
                              ? 'Hapus dari Liked'
                              : 'Tambah ke Liked',
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'add_to_playlist',
                    child: Row(
                      children: [
                        const Icon(Icons.playlist_add, size: 20),
                        const SizedBox(width: 8),
                        const Text('Tambah ke Playlist'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'remove_from_playlist',
                    child: Row(
                      children: [
                        const Icon(Icons.remove_circle_outline, size: 20),
                        const SizedBox(width: 8),
                        const Text('Hapus dari Playlist'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Text(
          widget.playlist.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.darkCard,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _playlistSongs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.music_off,
                        size: 64,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Playlist kosong',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.primaryColor.withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.queue_music,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.playlist.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_playlistSongs.length} lagu',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Songs List
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final song = _playlistSongs[index];
                          return _buildSongListItem(song, index);
                        },
                        childCount: _playlistSongs.length,
                      ),
                    ),
                  ],
                ),
    );
  }
}

// Featured Playlist Detail Screen (for Top Hits, Recently Added, For You)
class _FeaturedPlaylistDetailScreen extends StatefulWidget {
  final String title;
  final List<Song> songs;
  final String? color;

  const _FeaturedPlaylistDetailScreen({
    required this.title,
    required this.songs,
    this.color,
  });

  @override
  State<_FeaturedPlaylistDetailScreen> createState() => _FeaturedPlaylistDetailScreenState();
}

class _FeaturedPlaylistDetailScreenState extends State<_FeaturedPlaylistDetailScreen> {
  void _playSongAndNavigate(Song song) {
    final playlist = widget.songs;
    // Play song without awaiting
    MusicService().playSong(song, playlist: playlist).catchError((e) {
      print('Error playing song: $e');
    });
    
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerScreen(),
        ),
      );
    }
  }

  Future<void> _handleMenuAction(String action, Song song) async {
    switch (action) {
      case 'play':
        _playSongAndNavigate(song);
        break;
      case 'like':
        await _toggleLikeSong(song);
        break;
      case 'add_to_playlist':
        await _showAddToPlaylistDialog(song);
        break;
    }
  }

  Future<void> _toggleLikeSong(Song song) async {
    try {
      await SongService.toggleLikeSong(song.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            SongService.isSongLiked(song.id)
                ? 'Ditambahkan ke Liked Songs'
                : 'Dihapus dari Liked Songs',
          ),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {}); // Refresh UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengupdate liked songs: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showAddToPlaylistDialog(Song song) async {
    final playlists = SongService.getUserPlaylists();
    
    if (playlists.isEmpty) {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => _buildCreatePlaylistDialog(),
      );
      
      if (result != null && result.isNotEmpty) {
        try {
          await SongService.createPlaylist(
            name: result,
            songIds: [song.id],
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Playlist dibuat dan lagu ditambahkan'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal membuat playlist: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      return;
    }

    final selectedPlaylist = await showDialog<Playlist>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text(
          'Pilih Playlist',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: playlists.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  leading: const Icon(Icons.add, color: AppTheme.primaryColor),
                  title: const Text(
                    'Buat Playlist Baru',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await showDialog<String>(
                      context: context,
                      builder: (context) => _buildCreatePlaylistDialog(),
                    );
                    
                    if (result != null && result.isNotEmpty) {
                      try {
                        await SongService.createPlaylist(
                          name: result,
                          songIds: [song.id],
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Playlist dibuat dan lagu ditambahkan'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal membuat playlist: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                );
              }
              
              final playlist = playlists[index - 1];
              final isInPlaylist = playlist.songIds.contains(song.id);
              
              return ListTile(
                leading: Icon(
                  isInPlaylist ? Icons.check_circle : Icons.playlist_play,
                  color: isInPlaylist ? AppTheme.primaryColor : Colors.white,
                ),
                title: Text(
                  playlist.name,
                  style: TextStyle(
                    color: isInPlaylist ? AppTheme.primaryColor : Colors.white,
                  ),
                ),
                subtitle: Text(
                  '${playlist.songIds.length} lagu',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context, playlist);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );

    if (selectedPlaylist != null) {
      try {
        if (selectedPlaylist.songIds.contains(song.id)) {
          await SongService.removeSongFromPlaylist(selectedPlaylist.id, song.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lagu dihapus dari playlist'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          await SongService.addSongToPlaylist(selectedPlaylist.id, song.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lagu ditambahkan ke playlist'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengupdate playlist: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildCreatePlaylistDialog() {
    final controller = TextEditingController();
    
    return AlertDialog(
      backgroundColor: AppTheme.darkCard,
      title: const Text(
        'Buat Playlist Baru',
        style: TextStyle(color: Colors.white),
      ),
      content: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Nama playlist',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          filled: true,
          fillColor: AppTheme.darkBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            if (controller.text.trim().isNotEmpty) {
              Navigator.pop(context, controller.text.trim());
            }
          },
          child: const Text('Buat'),
        ),
      ],
    );
  }

  Widget _buildSongListItem(Song song, int index) {
    return Card(
      color: AppTheme.darkCard,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () {
          _playSongAndNavigate(song);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Song Number
              SizedBox(
                width: 32,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 12),

              // Album Cover
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 56,
                  height: 56,
                  color: AppTheme.getGenreColor(song.genre).withOpacity(0.3),
                  child: song.coverPath.isNotEmpty
                      ? Image.asset(
                          song.coverPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.music_note,
                              color: Colors.white70,
                              size: 24,
                            );
                          },
                        )
                      : const Icon(
                          Icons.music_note,
                          color: Colors.white70,
                          size: 24,
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Song Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      song.artist,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Duration
              Text(
                song.duration,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),

              // Menu Button
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white.withOpacity(0.7),
                ),
                onSelected: (value) => _handleMenuAction(value, song),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'play',
                    child: Row(
                      children: [
                        const Icon(Icons.play_arrow, size: 20),
                        const SizedBox(width: 8),
                        const Text('Putar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'like',
                    child: Row(
                      children: [
                        Icon(
                          SongService.isSongLiked(song.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 20,
                          color: SongService.isSongLiked(song.id)
                              ? AppTheme.primaryColor
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          SongService.isSongLiked(song.id)
                              ? 'Hapus dari Liked'
                              : 'Tambah ke Liked',
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'add_to_playlist',
                    child: Row(
                      children: [
                        const Icon(Icons.playlist_add, size: 20),
                        const SizedBox(width: 8),
                        const Text('Tambah ke Playlist'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorFromString(String? colorString) {
    if (colorString == null) return AppTheme.primaryColor;
    try {
      // Remove # if present
      final hex = colorString.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return AppTheme.primaryColor;
    }
  }

  IconData _getIconForTitle(String title) {
    if (title.toLowerCase().contains('top hits')) {
      return Icons.star;
    } else if (title.toLowerCase().contains('recently')) {
      return Icons.history;
    } else if (title.toLowerCase().contains('for you')) {
      return Icons.favorite;
    }
    return Icons.queue_music;
  }

  @override
  Widget build(BuildContext context) {
    final gradientColor = _getColorFromString(widget.color);
    
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.darkCard,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: widget.songs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.music_off,
                    size: 64,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada lagu',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          gradientColor,
                          gradientColor.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getIconForTitle(widget.title),
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.songs.length} lagu',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Songs List
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final song = widget.songs[index];
                      return _buildSongListItem(song, index);
                    },
                    childCount: widget.songs.length,
                  ),
                ),
              ],
            ),
    );
  }
}

// Top Hits Screen
class _TopHitsScreen extends StatefulWidget {
  final List<Song> songs;

  const _TopHitsScreen({required this.songs});

  @override
  State<_TopHitsScreen> createState() => _TopHitsScreenState();
}

class _TopHitsScreenState extends State<_TopHitsScreen> {
  void _playSongAndNavigate(Song song) {
    final playlist = widget.songs;
    // Play song without awaiting
    MusicService().playSong(song, playlist: playlist).catchError((e) {
      print('Error playing song: $e');
    });
    
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerScreen(),
        ),
      );
    }
  }

  Future<void> _handleMenuAction(String action, Song song) async {
    switch (action) {
      case 'play':
        _playSongAndNavigate(song);
        break;
      case 'like':
        await _toggleLikeSong(song);
        break;
      case 'add_to_playlist':
        await _showAddToPlaylistDialog(song);
        break;
    }
  }

  Future<void> _toggleLikeSong(Song song) async {
    try {
      await SongService.toggleLikeSong(song.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            SongService.isSongLiked(song.id)
                ? 'Ditambahkan ke Liked Songs'
                : 'Dihapus dari Liked Songs',
          ),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {}); // Refresh UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengupdate liked songs: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showAddToPlaylistDialog(Song song) async {
    final playlists = SongService.getUserPlaylists();
    
    if (playlists.isEmpty) {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => _buildCreatePlaylistDialog(),
      );
      
      if (result != null && result.isNotEmpty) {
        try {
          await SongService.createPlaylist(
            name: result,
            songIds: [song.id],
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Playlist dibuat dan lagu ditambahkan'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal membuat playlist: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      return;
    }

    final selectedPlaylist = await showDialog<Playlist>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text(
          'Pilih Playlist',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: playlists.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  leading: const Icon(Icons.add, color: AppTheme.primaryColor),
                  title: const Text(
                    'Buat Playlist Baru',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await showDialog<String>(
                      context: context,
                      builder: (context) => _buildCreatePlaylistDialog(),
                    );
                    
                    if (result != null && result.isNotEmpty) {
                      try {
                        await SongService.createPlaylist(
                          name: result,
                          songIds: [song.id],
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Playlist dibuat dan lagu ditambahkan'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal membuat playlist: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                );
              }
              
              final playlist = playlists[index - 1];
              final isInPlaylist = playlist.songIds.contains(song.id);
              
              return ListTile(
                leading: Icon(
                  isInPlaylist ? Icons.check_circle : Icons.playlist_play,
                  color: isInPlaylist ? AppTheme.primaryColor : Colors.white,
                ),
                title: Text(
                  playlist.name,
                  style: TextStyle(
                    color: isInPlaylist ? AppTheme.primaryColor : Colors.white,
                  ),
                ),
                subtitle: Text(
                  '${playlist.songIds.length} lagu',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context, playlist);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );

    if (selectedPlaylist != null) {
      try {
        if (selectedPlaylist.songIds.contains(song.id)) {
          await SongService.removeSongFromPlaylist(selectedPlaylist.id, song.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lagu dihapus dari playlist'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          await SongService.addSongToPlaylist(selectedPlaylist.id, song.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lagu ditambahkan ke playlist'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengupdate playlist: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildCreatePlaylistDialog() {
    final controller = TextEditingController();
    
    return AlertDialog(
      backgroundColor: AppTheme.darkCard,
      title: const Text(
        'Buat Playlist Baru',
        style: TextStyle(color: Colors.white),
      ),
      content: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Nama playlist',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          filled: true,
          fillColor: AppTheme.darkBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            if (controller.text.trim().isNotEmpty) {
              Navigator.pop(context, controller.text.trim());
            }
          },
          child: const Text('Buat'),
        ),
      ],
    );
  }

  Widget _buildSongListItem(Song song, int index) {
    return Card(
      color: AppTheme.darkCard,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () {
          _playSongAndNavigate(song);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Song Number
              SizedBox(
                width: 32,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 12),

              // Album Cover
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 56,
                  height: 56,
                  color: AppTheme.getGenreColor(song.genre).withOpacity(0.3),
                  child: song.coverPath.isNotEmpty
                      ? Image.asset(
                          song.coverPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.music_note,
                              color: Colors.white70,
                              size: 24,
                            );
                          },
                        )
                      : const Icon(
                          Icons.music_note,
                          color: Colors.white70,
                          size: 24,
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Song Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      song.artist,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Duration
              Text(
                song.duration,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),

              // Menu Button
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white.withOpacity(0.7),
                ),
                onSelected: (value) => _handleMenuAction(value, song),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'play',
                    child: Row(
                      children: [
                        const Icon(Icons.play_arrow, size: 20),
                        const SizedBox(width: 8),
                        const Text('Putar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'like',
                    child: Row(
                      children: [
                        Icon(
                          SongService.isSongLiked(song.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 20,
                          color: SongService.isSongLiked(song.id)
                              ? AppTheme.primaryColor
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          SongService.isSongLiked(song.id)
                              ? 'Hapus dari Liked'
                              : 'Tambah ke Liked',
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'add_to_playlist',
                    child: Row(
                      children: [
                        const Icon(Icons.playlist_add, size: 20),
                        const SizedBox(width: 8),
                        const Text('Tambah ke Playlist'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text(
          'Top Hits',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.darkCard,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: widget.songs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.music_off,
                    size: 64,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada lagu',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.accentColor,
                          AppTheme.accentColor.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Top Hits',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.songs.length} lagu',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Songs List
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final song = widget.songs[index];
                      return _buildSongListItem(song, index);
                    },
                    childCount: widget.songs.length,
                  ),
                ),
              ],
            ),
    );
  }
}
