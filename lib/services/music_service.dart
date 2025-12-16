import 'dart:async';
import 'dart:math';
import 'package:just_audio/just_audio.dart';
import '../models/models.dart';
import 'storage_service.dart';

enum RepeatMode { none, one, all }
enum MusicPlayerState { stopped, playing, paused, loading, error }

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();

  late AudioPlayer _audioPlayer;
  Timer? _sleepTimer;

  // Current playing info
  Song? _currentSong;
  List<Song> _currentPlaylist = [];
  int _currentIndex = 0;
  
  // Player settings
  bool _isShuffled = false;
  RepeatMode _repeatMode = RepeatMode.none;
  double _volume = 0.7;

  // Stream controllers
  final _playerStateController = StreamController<MusicPlayerState>.broadcast();
  final _currentSongController = StreamController<Song?>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();
  final _playlistController = StreamController<List<Song>>.broadcast();

  // Getters
  Song? get currentSong => _currentSong;
  List<Song> get currentPlaylist => _currentPlaylist;
  int get currentIndex => _currentIndex;
  bool get isShuffled => _isShuffled;
  RepeatMode get repeatMode => _repeatMode;
  double get volume => _volume;
  MusicPlayerState get playerState => _currentPlayerState;
  bool get isPlaying => _currentPlayerState == MusicPlayerState.playing;

  // Streams
  Stream<MusicPlayerState> get playerStateStream => _playerStateController.stream;
  Stream<Song?> get currentSongStream => _currentSongController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;
  Stream<List<Song>> get playlistStream => _playlistController.stream;

  MusicPlayerState _currentPlayerState = MusicPlayerState.stopped;

  Future<void> init() async {
    _audioPlayer = AudioPlayer();
    
    // Load saved settings
    _volume = StorageService.getVolume();
    await _audioPlayer.setVolume(_volume);

    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((state) {
      _updatePlayerState(state);
    });

    // Listen to position changes
    _audioPlayer.positionStream.listen((position) {
      _positionController.add(position);
    });

    // Listen to duration changes
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _durationController.add(duration);
      }
    });

    // Listen to sequence state for playlist changes
    // NOTE: This might fire after playSong, so we need to be careful not to override
    // the song that was explicitly set in playSong
    _audioPlayer.sequenceStateStream.listen((sequenceState) {
      if (sequenceState != null) {
        final newIndex = sequenceState.currentIndex;
        // Only update if index actually changed and we have a playlist
        if (newIndex != _currentIndex && _currentPlaylist.isNotEmpty) {
          print('sequenceStateStream: Index changed from $_currentIndex to $newIndex');
          _currentIndex = newIndex;
          // Only update if the new song is different
          if (_currentIndex < _currentPlaylist.length) {
            final newSong = _currentPlaylist[_currentIndex];
            // Check if this is different from what we explicitly set
            if (newSong.id != _currentSong?.id) {
              print('sequenceStateStream: Updating currentSong to ${newSong.title}');
              _updateCurrentSong();
            } else {
              print('sequenceStateStream: New song same as current, skipping update');
            }
          }
        }
      }
    });

    // Listen for track completion
    _audioPlayer.processingStateStream.listen((processingState) {
      if (processingState == ProcessingState.completed) {
        _handleTrackCompletion();
      }
    });
  }

  void _updatePlayerState(PlayerState state) {
    _currentPlayerState = _mapPlayerState(state);
    _playerStateController.add(_currentPlayerState);
  }

  MusicPlayerState _mapPlayerState(PlayerState state) {
    switch (state.processingState) {
      case ProcessingState.idle:
        return MusicPlayerState.stopped;
      case ProcessingState.loading:
      case ProcessingState.buffering:
        return MusicPlayerState.loading;
      case ProcessingState.ready:
        return state.playing ? MusicPlayerState.playing : MusicPlayerState.paused;
      case ProcessingState.completed:
        return MusicPlayerState.stopped;
    }
  }

  void _updateCurrentSong() {
    if (_currentPlaylist.isNotEmpty && _currentIndex < _currentPlaylist.length) {
      final newSong = _currentPlaylist[_currentIndex];
      // Only update if it's different to avoid unnecessary updates
      if (newSong.id != _currentSong?.id) {
        print('_updateCurrentSong: Updating from ${_currentSong?.title} to ${newSong.title}');
        _currentSong = newSong;
        _currentSongController.add(_currentSong);
      }
    }
  }

  void _handleTrackCompletion() {
    switch (_repeatMode) {
      case RepeatMode.one:
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.play();
        break;
      case RepeatMode.all:
        next();
        break;
      case RepeatMode.none:
        if (_currentIndex < _currentPlaylist.length - 1) {
          next();
        } else {
          stop();
        }
        break;
    }
  }

  // Playback control methods
  Future<void> playSong(Song song, {List<Song>? playlist}) async {
    try {
      print('=== MusicService.playSong START ===');
      print('MusicService.playSong: Requested song = ${song.title} by ${song.artist}, ID = ${song.id}');
      print('MusicService.playSong: Previous currentSong = ${_currentSong?.title}, ID = ${_currentSong?.id}');
      
      _currentPlayerState = MusicPlayerState.loading;
      _playerStateController.add(_currentPlayerState);

      // Update current song FIRST before anything else - SYNCHRONOUS
      _currentSong = song;
      print('MusicService.playSong: _currentSong set to ${_currentSong?.title}, ID = ${_currentSong?.id}');
      _currentSongController.add(_currentSong);
      print('MusicService.playSong: Current song broadcasted to stream');

      if (playlist != null && playlist.isNotEmpty) {
        _currentPlaylist = List.from(playlist);
        // Find index by ID instead of object comparison
        _currentIndex = _currentPlaylist.indexWhere((s) => s.id == song.id);
        if (_currentIndex == -1) {
          _currentIndex = 0;
          print('MusicService.playSong: WARNING - Song not found in playlist, using index 0');
        } else {
          print('MusicService.playSong: Found song at index $_currentIndex in playlist');
        }
        _playlistController.add(_currentPlaylist);
      } else {
        // If no new playlist is provided, check if the song exists in the current playlist
        // This is crucial for next/previous functionality which calls playSong with just the song
        final existingIndex = _currentPlaylist.indexWhere((s) => s.id == song.id);
        
        if (existingIndex != -1) {
          // Song is in current playlist, preserve the playlist
          _currentIndex = existingIndex;
          print('MusicService.playSong: Playing song from existing playlist at index $_currentIndex');
        } else {
          // Song is not in current playlist (e.g. playing from search result), create new playlist
          _currentPlaylist = [song];
          _currentIndex = 0;
          _playlistController.add(_currentPlaylist);
          print('MusicService.playSong: Created new playlist with single song');
        }
      }

      // Verify current song is still correct before loading audio
      print('MusicService.playSong: Before loading audio, _currentSong = ${_currentSong?.title}, ID = ${_currentSong?.id}');
      
      // Load audio from assets
      print('MusicService.playSong: Loading audio from ${song.audioPath}');
      await _audioPlayer.setAsset(song.audioPath);
      
      // Verify again after setAsset (sequenceStateStream might have fired)
      if (_currentSong?.id != song.id) {
        print('MusicService.playSong: WARNING - _currentSong changed after setAsset! Resetting to ${song.title}');
        _currentSong = song;
        _currentSongController.add(_currentSong);
      }
      
      print('MusicService.playSong: Starting playback');
      await _audioPlayer.play();
      print('MusicService.playSong: Playback started, final _currentSong = ${_currentSong?.title}, ID = ${_currentSong?.id}');
      print('=== MusicService.playSong END ===');

    } catch (e) {
      _currentPlayerState = MusicPlayerState.error;
      _playerStateController.add(_currentPlayerState);
      print('Error playing song: $e');
    }
  }

  Future<void> playPlaylist(List<Song> playlist, {int startIndex = 0}) async {
    if (playlist.isEmpty) return;
    
    _currentPlaylist = List.from(playlist);
    _currentIndex = startIndex.clamp(0, playlist.length - 1);
    _playlistController.add(_currentPlaylist);

    await playSong(_currentPlaylist[_currentIndex]);
  }

  Future<void> play() async {
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentPlayerState = MusicPlayerState.stopped;
    _playerStateController.add(_currentPlayerState);
  }

  Future<void> stopAndClear() async {
    await stop();
    _currentSong = null;
    _currentPlaylist = [];
    _currentIndex = 0;
    _currentSongController.add(null);
  }

  Future<void> next() async {
    if (_currentPlaylist.isEmpty) return;

    print('MusicService.next: Moving to next song');

    if (_isShuffled) {
      final random = Random();
      int nextIndex;
      do {
        nextIndex = random.nextInt(_currentPlaylist.length);
      } while (nextIndex == _currentIndex && _currentPlaylist.length > 1);
      _currentIndex = nextIndex;
    } else {
      _currentIndex = (_currentIndex + 1) % _currentPlaylist.length;
    }
    
    print('MusicService.next: New index $_currentIndex');
    await playSong(_currentPlaylist[_currentIndex]);
  }

  DateTime? _lastPreviousTapTime;

  Future<void> previous() async {
    if (_currentPlaylist.isEmpty) return;

    // Smart Previous Logic:
    // Jika user klik 2x cepat (< 1 detik), paksa pindah ke lagu sebelumnya
    final now = DateTime.now();
    final bool isDoubleTap = _lastPreviousTapTime != null && 
        now.difference(_lastPreviousTapTime!) < const Duration(milliseconds: 1000);
    
    _lastPreviousTapTime = now;

    if (isDoubleTap) {
       print('MusicService.previous: Double tap detected, forcing previous song');
       await forcePrevious();
       _lastPreviousTapTime = null; // Reset
       return;
    }

    // Normal Logic:
    // Selalu kembali ke awal lagu jika posisi > 3 detik
    if (_audioPlayer.position > Duration(seconds: 3)) {
      print('MusicService.previous: Seeking to start of song');
      await _audioPlayer.seek(Duration.zero);
    } else {
      print('MusicService.previous: Going to previous song');
      await forcePrevious();
    }
  }

  Future<void> forcePrevious() async {
      if (_currentPlaylist.isEmpty) return;
      
      // Go to previous song
      if (_isShuffled) {
        final random = Random();
        int prevIndex;
        do {
          prevIndex = random.nextInt(_currentPlaylist.length);
        } while (prevIndex == _currentIndex && _currentPlaylist.length > 1);
        _currentIndex = prevIndex;
      } else {
        _currentIndex = (_currentIndex - 1 + _currentPlaylist.length) % _currentPlaylist.length;
      }
      await playSong(_currentPlaylist[_currentIndex]);
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _audioPlayer.setVolume(_volume);
    await StorageService.setVolume(_volume);
  }

  void toggleShuffle() {
    _isShuffled = !_isShuffled;
  }

  void setRepeatMode(RepeatMode mode) {
    _repeatMode = mode;
  }

  void toggleRepeatMode() {
    switch (_repeatMode) {
      case RepeatMode.none:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.none;
        break;
    }
  }

  // Sleep timer
  void setSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    
    _sleepTimer = Timer(Duration(minutes: minutes), () {
      pause();
      _sleepTimer = null;
    });

    StorageService.setSleepTimer(minutes);
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    StorageService.setSleepTimer(null);
  }

  bool get hasSleepTimer => _sleepTimer != null;

  Duration? get sleepTimerRemaining {
    if (_sleepTimer == null) return null;
    
    final savedMinutes = StorageService.getSleepTimer();
    if (savedMinutes == null) return null;
    
    // This is a simplified implementation
    // In a real app, you'd track the exact remaining time
    return Duration(minutes: savedMinutes);
  }

  // Add song to queue
  void addToQueue(Song song) {
    _currentPlaylist.add(song);
    _playlistController.add(_currentPlaylist);
  }

  void removeFromQueue(int index) {
    if (index < 0 || index >= _currentPlaylist.length) return;
    
    if (index == _currentIndex) {
      // If removing current song, skip to next
      if (_currentPlaylist.length > 1) {
        next();
      } else {
        stop();
      }
    } else if (index < _currentIndex) {
      _currentIndex--;
    }

    _currentPlaylist.removeAt(index);
    _playlistController.add(_currentPlaylist);
  }

  // Cleanup
  void dispose() {
    _sleepTimer?.cancel();
    _audioPlayer.dispose();
    _playerStateController.close();
    _currentSongController.close();
    _positionController.close();
    _durationController.close();
    _playlistController.close();
  }
}
