import 'package:flutter/material.dart';
import 'dart:async';
import '../models/models.dart';
import '../services/services.dart';
import '../utils/utils.dart';

class PlayerScreen extends StatefulWidget {
  PlayerScreen({Key? key}) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final MusicService _musicService = MusicService();
  Song? _currentSong;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  bool _isShuffled = false;
  RepeatMode _repeatMode = RepeatMode.none;
  bool _isDragging = false;
  double? _dragPosition;
  StreamSubscription? _songSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _stateSubscription;

  @override
  void initState() {
    super.initState();
    // Load current song immediately
    _loadCurrentSong();
    // Subscribe to streams
    _subscribeToStreams();
    // Also check after a frame to ensure we have the latest song
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentSong();
    });
  }

  @override
  void dispose() {
    _songSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _stateSubscription?.cancel();
    super.dispose();
  }

  void _loadCurrentSong() {
    final currentSong = _musicService.currentSong;
    print('_loadCurrentSong: Current song from service = ${currentSong?.title} by ${currentSong?.artist}');
    print('_loadCurrentSong: Previous _currentSong = ${_currentSong?.title}');
    
    if (currentSong != null) {
      setState(() {
        _currentSong = currentSong;
        _isShuffled = _musicService.isShuffled;
        _repeatMode = _musicService.repeatMode;
      });
      print('_loadCurrentSong: Updated _currentSong to ${_currentSong?.title}');
    } else {
      print('_loadCurrentSong: WARNING - currentSong is null!');
    }
  }

  void _subscribeToStreams() {
    // Load current song immediately first - CRITICAL: Do this before subscribing
    _loadCurrentSong();
    
    // Listen to current song changes
    _songSubscription = _musicService.currentSongStream.listen((song) {
      if (mounted && song != null) {
        print('Player Screen Stream: Song updated to ${song.title} by ${song.artist}');
        setState(() {
          _currentSong = song;
        });
      } else if (mounted && song == null) {
        print('Player Screen Stream: Song is null');
      }
    });
    
    // Also check current song after frame is built - multiple checks to ensure we get the right song
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentSong = _musicService.currentSong;
        print('Player Screen PostFrame: Current song = ${currentSong?.title} by ${currentSong?.artist}');
        if (currentSong != null && currentSong != _currentSong) {
          print('Player Screen PostFrame: Updating _currentSong from ${_currentSong?.title} to ${currentSong.title}');
          setState(() {
            _currentSong = currentSong;
          });
        }
      }
    });
    
    // One more check after a short delay to catch any late updates
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        final currentSong = _musicService.currentSong;
        if (currentSong != null && currentSong != _currentSong) {
          print('Player Screen Delayed: Updating _currentSong from ${_currentSong?.title} to ${currentSong.title}');
          setState(() {
            _currentSong = currentSong;
          });
        }
      }
    });

    _positionSubscription = _musicService.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    _durationSubscription = _musicService.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    _stateSubscription = _musicService.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == MusicPlayerState.playing;
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    // ALWAYS check current song from service on every build to ensure we have the latest
    final serviceCurrentSong = _musicService.currentSong;
    print('PlayerScreen.build: _currentSong = ${_currentSong?.title} (ID: ${_currentSong?.id}), serviceCurrentSong = ${serviceCurrentSong?.title} (ID: ${serviceCurrentSong?.id})');
    
    // Use serviceCurrentSong directly if _currentSong is null or different
    final songToDisplay = serviceCurrentSong ?? _currentSong;
    
    // If they don't match, update state immediately (but use serviceCurrentSong for this build)
    if (serviceCurrentSong != null && serviceCurrentSong.id != _currentSong?.id) {
      print('PlayerScreen.build: Mismatch detected! _currentSong will be updated from ${_currentSong?.title} to ${serviceCurrentSong.title}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _currentSong = serviceCurrentSong;
          });
        }
      });
    }
    
    // If no song at all, show loading
    if (songToDisplay == null) {
      return Scaffold(
        backgroundColor: AppTheme.darkBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Tidak ada lagu yang diputar',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }
    
    // Use songToDisplay for the rest of the build
    final displaySong = songToDisplay;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
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
                value: 'like',
                child: Row(
                  children: [
                    Icon(
                      SongService.isSongLiked(_currentSong?.id ?? '')
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 20,
                      color: SongService.isSongLiked(_currentSong?.id ?? '')
                          ? AppTheme.primaryColor
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      SongService.isSongLiked(_currentSong?.id ?? '')
                          ? 'Hapus dari Liked'
                          : 'Tambah ke Liked',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: displaySong.coverPath.isNotEmpty
              ? DecorationImage(
                  image: AssetImage(displaySong.coverPath),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.6),
                    BlendMode.darken,
                  ),
                )
              : null,
          color: displaySong.coverPath.isEmpty
              ? AppTheme.getGenreColor(displaySong.genre)
              : null,
        ),
        key: ValueKey(displaySong.id), // Force rebuild when song changes
        child: SafeArea(
            child: Column(
              children: [
                // Album Art / Background
              Expanded(
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.width * 0.85,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: displaySong.coverPath.isNotEmpty
                          ? Image.asset(
                              displaySong.coverPath,
                              key: ValueKey('${displaySong.id}_cover'), // Force rebuild
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('Error loading cover: ${displaySong.coverPath}');
                                return Container(
                                  color: AppTheme.getGenreColor(displaySong.genre),
                                  child: const Icon(
                                    Icons.music_note,
                                    size: 80,
                                    color: Colors.white70,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: AppTheme.getGenreColor(displaySong.genre),
                              child: const Icon(
                                Icons.music_note,
                                size: 80,
                                color: Colors.white70,
                              ),
                            ),
                    ),
                  ),
                ),
              ),

              // Song Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displaySong.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            displaySong.artist,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _currentSong != null && SongService.isSongLiked(_currentSong!.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: _currentSong != null && SongService.isSongLiked(_currentSong!.id)
                            ? AppTheme.primaryColor
                            : Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        if (_currentSong != null) {
                          _toggleLikeSong(_currentSong!);
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Progress Bar dengan animasi real-time
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    StreamBuilder<Duration>(
                      stream: _musicService.positionStream,
                      builder: (context, positionSnapshot) {
                        return StreamBuilder<Duration>(
                          stream: _musicService.durationStream,
                          builder: (context, durationSnapshot) {
                            final currentPosition = positionSnapshot.data ?? _position;
                            final currentDuration = durationSnapshot.data ?? _duration;
                            
                            // Gunakan drag position jika sedang drag, otherwise gunakan position real-time
                            final displayPosition = _isDragging && _dragPosition != null
                                ? _dragPosition!
                                : (currentDuration.inMilliseconds > 0
                                    ? currentPosition.inMilliseconds.toDouble()
                                    : 0.0);
                            
                            final maxValue = currentDuration.inMilliseconds > 0
                                ? currentDuration.inMilliseconds.toDouble()
                                : 100.0;

                            return SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 4,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                                activeTrackColor: Colors.white,
                                inactiveTrackColor: Colors.white.withOpacity(0.3),
                                thumbColor: Colors.white,
                                overlayColor: Colors.white.withOpacity(0.2),
                              ),
                              child: Slider(
                                value: displayPosition.clamp(0.0, maxValue),
                                max: maxValue,
                                activeColor: Colors.white,
                                inactiveColor: Colors.white.withOpacity(0.3),
                                onChanged: (value) {
                                  setState(() {
                                    _isDragging = true;
                                    _dragPosition = value;
                                  });
                                },
                                onChangeStart: (value) {
                                  setState(() {
                                    _isDragging = true;
                                    _dragPosition = value;
                                  });
                                },
                                onChangeEnd: (value) {
                                  setState(() {
                                    _isDragging = false;
                                    _dragPosition = null;
                                  });
                                  _musicService.seek(Duration(milliseconds: value.toInt()));
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                    StreamBuilder<Duration>(
                      stream: _musicService.positionStream,
                      builder: (context, positionSnapshot) {
                        return StreamBuilder<Duration>(
                          stream: _musicService.durationStream,
                          builder: (context, durationSnapshot) {
                            final currentPosition = positionSnapshot.data ?? _position;
                            final currentDuration = durationSnapshot.data ?? _duration;
                            
                            // Format durasi yang ditampilkan saat drag
                            final displayPosition = _isDragging && _dragPosition != null
                                ? Duration(milliseconds: _dragPosition!.toInt())
                                : currentPosition;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 100),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 12,
                                    ),
                                    child: Text(
                                      _formatDuration(displayPosition),
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(currentDuration),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Player Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  children: [
                    // Main Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Shuffle
                        IconButton(
                          icon: Icon(
                            Icons.shuffle,
                            color: _isShuffled ? AppTheme.primaryColor : Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            _musicService.toggleShuffle();
                            setState(() {
                              _isShuffled = _musicService.isShuffled;
                            });
                          },
                        ),

                        // Previous
                        IconButton(
                          icon: const Icon(
                            Icons.skip_previous,
                            color: Colors.white,
                            size: 36,
                          ),
                          onPressed: () => _musicService.previous(),
                        ),

                        // Play/Pause
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.black,
                              size: 40,
                            ),
                            onPressed: () {
                              if (_isPlaying) {
                                _musicService.pause();
                              } else {
                                _musicService.play();
                              }
                            },
                          ),
                        ),

                        // Next
                        IconButton(
                          icon: const Icon(
                            Icons.skip_next,
                            color: Colors.white,
                            size: 36,
                          ),
                          onPressed: () => _musicService.next(),
                        ),

                        // Repeat
                        IconButton(
                          icon: Icon(
                            _repeatMode == RepeatMode.all
                                ? Icons.repeat
                                : _repeatMode == RepeatMode.one
                                    ? Icons.repeat_one
                                    : Icons.repeat,
                            color: _repeatMode != RepeatMode.none
                                ? AppTheme.primaryColor
                                : Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            RepeatMode newMode;
                            switch (_repeatMode) {
                              case RepeatMode.none:
                                newMode = RepeatMode.all;
                                break;
                              case RepeatMode.all:
                                newMode = RepeatMode.one;
                                break;
                              case RepeatMode.one:
                                newMode = RepeatMode.none;
                                break;
                            }
                            _musicService.setRepeatMode(newMode);
                            setState(() {
                              _repeatMode = newMode;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Secondary Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.cast,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () {
                            // Cast functionality
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.share,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () {
                            // Share functionality
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleMenuAction(String action) async {
    if (_currentSong == null) return;

    switch (action) {
      case 'add_to_playlist':
        await _showAddToPlaylistDialog(_currentSong!);
        break;
      case 'like':
        await _toggleLikeSong(_currentSong!);
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
}
