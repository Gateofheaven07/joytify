import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../utils/utils.dart';
import 'player_screen.dart';

class GenreSongsScreen extends StatefulWidget {
  final Genre genre;

  const GenreSongsScreen({
    Key? key,
    required this.genre,
  }) : super(key: key);

  @override
  State<GenreSongsScreen> createState() => _GenreSongsScreenState();
}

class _GenreSongsScreenState extends State<GenreSongsScreen> {
  List<Song> _genreSongs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGenreSongs();
  }

  void _loadGenreSongs() {
    setState(() {
      _isLoading = true;
    });

    try {
      final allSongs = SongService.getAllSongs();
      _genreSongs = allSongs.where((song) => song.genre == widget.genre.name).toList();
    } catch (e) {
      print('Error loading genre songs: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _playSongAndNavigate(Song song) async {
    print('_playSongAndNavigate: Starting to play ${song.title}');
    try {
      // Play song first
      await MusicService().playSong(song, playlist: _genreSongs);
      print('_playSongAndNavigate: Song played, navigating to PlayerScreen');
      
      // Navigate immediately - the PlayerScreen will load current song from service
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              print('_playSongAndNavigate: Building PlayerScreen');
              return PlayerScreen();
            },
          ),
        ).then((_) {
          print('_playSongAndNavigate: Navigation completed');
        }).catchError((error) {
          print('_playSongAndNavigate: Navigation error: $error');
        });
      } else {
        print('_playSongAndNavigate: Widget not mounted, cannot navigate');
      }
    } catch (e) {
      print('_playSongAndNavigate: Error playing song: $e');
      // Still try to navigate even if playSong fails
      if (mounted) {
        print('_playSongAndNavigate: Attempting navigation despite error');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerScreen(),
          ),
        );
      }
    }
  }

  void _handleMenuAction(String action, Song song) {
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
      _showMessage(
        SongService.isSongLiked(song.id)
            ? 'Ditambahkan ke Liked Songs'
            : 'Dihapus dari Liked Songs',
        isError: false,
      );
      setState(() {}); // Refresh UI
    } catch (e) {
      _showMessage('Gagal mengupdate liked songs: $e', isError: true);
    }
  }

  Future<void> _showAddToPlaylistDialog(Song song) async {
    final playlists = SongService.getUserPlaylists();
    
    if (playlists.isEmpty) {
      // Show create playlist dialog
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
          _showMessage('Playlist dibuat dan lagu ditambahkan', isError: false);
        } catch (e) {
          _showMessage('Gagal membuat playlist: $e', isError: true);
        }
      }
      return;
    }

    // Show playlist selection dialog
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
                        _showMessage('Playlist dibuat dan lagu ditambahkan', isError: false);
                      } catch (e) {
                        _showMessage('Gagal membuat playlist: $e', isError: true);
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
          _showMessage('Lagu dihapus dari playlist', isError: false);
        } else {
          await SongService.addSongToPlaylist(selectedPlaylist.id, song.id);
          _showMessage('Lagu ditambahkan ke playlist', isError: false);
        }
      } catch (e) {
        _showMessage('Gagal mengupdate playlist: $e', isError: true);
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

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Text(
          widget.genre.name,
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
          : _genreSongs.isEmpty
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
                        'Tidak ada lagu di kategori ini',
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
                    // Header with genre info
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.genre.colorValue,
                              widget.genre.colorValue.withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.genre.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.genre.description,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${_genreSongs.length} lagu',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Songs List
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final song = _genreSongs[index];
                            return _buildSongListItem(song, index);
                          },
                          childCount: _genreSongs.length,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSongListItem(Song song, int index) {
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
}
