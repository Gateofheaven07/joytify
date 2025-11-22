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
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isDragging = false;
  double? _dragPosition;
  StreamSubscription? _songSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;

  @override
  void initState() {
    super.initState();
    _loadCurrentSong();
    _subscribeToStreams();
  }

  @override
  void dispose() {
    _songSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    super.dispose();
  }

  void _loadCurrentSong() {
    final currentSong = _musicService.currentSong;
    
    if (mounted) {
      setState(() {
        _currentSong = currentSong;
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

    // State subscription tidak diperlukan karena kita menggunakan StreamBuilder di build method
    // _stateSubscription = _musicService.playerStateStream.listen((state) {
    //   if (mounted) {
    //     setState(() {
    //       _isPlaying = state == MusicPlayerState.playing;
    //     });
    //   }
    // });

    _positionSubscription = _musicService.positionStream.listen((position) {
      if (mounted && !_isDragging) {
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
  }

  void _togglePlayPause() {
    // Selalu gunakan state dari service untuk memastikan sinkronisasi
    final currentIsPlaying = _musicService.isPlaying;
    if (currentIsPlaying) {
      _musicService.pause();
    } else {
      _musicService.play();
    }
  }

  void _openPlayerScreen() async {
    if (_currentSong != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerScreen(),
        ),
      );
      // Refresh state setelah kembali dari player screen
      // StreamBuilder akan otomatis update state, jadi tidak perlu setState manual
      if (mounted) {
        setState(() {
          _currentSong = _musicService.currentSong;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't show mini player if no song is playing
    if (_currentSong == null) {
      return const SizedBox.shrink();
    }
    
    // Gunakan StreamBuilder untuk memastikan state play/pause selalu sinkron
    // StreamBuilder akan otomatis rebuild ketika state berubah dari stream
    return StreamBuilder<MusicPlayerState>(
      stream: _musicService.playerStateStream,
      initialData: _musicService.playerState,
      builder: (context, stateSnapshot) {
        // Selalu gunakan data terbaru dari stream
        final currentState = stateSnapshot.data ?? _musicService.playerState;
        final isPlaying = currentState == MusicPlayerState.playing;
        
        return _buildMiniPlayerContent(isPlaying);
      },
    );
  }
  
  Widget _buildMiniPlayerContent(bool isPlaying) {

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mini Player Container
        Container(
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
                      isPlaying ? Icons.pause : Icons.play_arrow,
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
        ),
        
        // Seek Bar dengan animasi real-time (di bawah mini player)
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

                return Container(
                  color: AppTheme.darkCard,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
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
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

