import 'package:flutter/material.dart';
import 'dart:async';
import '../models/models.dart';
import '../services/services.dart';
import '../utils/utils.dart';
import '../screens/player_screen.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  final MusicService _musicService = MusicService();
  Song? _currentSong;
  bool _isPlaying = false;
  StreamSubscription? _songSubscription;
  StreamSubscription? _stateSubscription;

  @override
  void initState() {
    super.initState();
    _loadCurrentSong();
    _subscribeToStreams();
  }

  @override
  void dispose() {
    _songSubscription?.cancel();
    _stateSubscription?.cancel();
    super.dispose();
  }

  void _loadCurrentSong() {
    final currentSong = _musicService.currentSong;
    final isPlaying = _musicService.isPlaying;
    
    if (mounted) {
      setState(() {
        _currentSong = currentSong;
        _isPlaying = isPlaying;
      });
    }
  }

  void _subscribeToStreams() {
    _songSubscription = _musicService.currentSongStream.listen((song) {
      if (mounted) {
        setState(() {
          _currentSong = song;
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

  void _togglePlayPause() {
    if (_isPlaying) {
      _musicService.pause();
    } else {
      _musicService.play();
    }
  }

  void _openPlayerScreen() {
    if (_currentSong != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't show mini player if no song is playing
    if (_currentSong == null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
          children: [
            // Album Cover (Tapable to open player screen)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: _openPlayerScreen,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset(
                    _currentSong!.coverPath,
                    width: 54,
                    height: 54,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 54,
                        height: 54,
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        child: const Icon(
                          Icons.music_note,
                          color: Colors.white,
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Song Info (Tapable to open player screen)
            Expanded(
              child: InkWell(
                onTap: _openPlayerScreen,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentSong!.title,
                        style: AppTheme.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentSong!.artist,
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Controls
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Previous Button
                IconButton(
                  icon: const Icon(
                    Icons.skip_previous,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () {
                    _musicService.previous();
                  },
                ),
                
                // Play/Pause Button
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: _togglePlayPause,
                ),
                
                // Next Button
                IconButton(
                  icon: const Icon(
                    Icons.skip_next,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () {
                    _musicService.next();
                  },
                ),
                
                // Close Button
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () async {
                    await _musicService.stopAndClear();
                  },
                ),
              ],
            ),
          ],
        ),
    );
  }
}

