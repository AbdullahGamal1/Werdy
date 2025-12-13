// Audio Service - خدمة التلاوة الصوتية

import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../models/reciter.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  Reciter? _currentReciter;
  RecitationTrack? _currentTrack;

  // Stream controllers for player state
  Stream<AudioPlayerState> get playerStateStream =>
      _audioPlayer.playerStateStream.map(
        (state) => AudioPlayerState(
          state: _mapPlaybackEvent(state),
          position: _audioPlayer.position,
          duration: _audioPlayer.duration ?? Duration.zero,
          currentTrack: _currentTrack,
          currentReciter: _currentReciter,
        ),
      );

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  PlaybackState _mapPlaybackEvent(PlayerState state) {
    if (state.processingState == ProcessingState.loading ||
        state.processingState == ProcessingState.buffering) {
      return PlaybackState.loading;
    } else if (state.playing) {
      return PlaybackState.playing;
    } else if (state.processingState == ProcessingState.completed) {
      return PlaybackState.completed;
    } else {
      return PlaybackState.paused;
    }
  }

  // Play a recitation
  Future<void> play({
    required Reciter reciter,
    required RecitationTrack track,
  }) async {
    try {
      _currentReciter = reciter;
      _currentTrack = track;

      String audioUrl;

      // Check if downloaded locally
      if (track.isDownloaded && track.localPath != null) {
        audioUrl = track.localPath!;
      } else {
        audioUrl = track.getAudioUrl(reciter);
      }

      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
      rethrow;
    }
  }

  // Pause playback
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  // Resume playback
  Future<void> resume() async {
    await _audioPlayer.play();
  }

  // Stop playback
  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentTrack = null;
    _currentReciter = null;
  }

  // Seek to position
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // Set playback speed
  Future<void> setSpeed(double speed) async {
    await _audioPlayer.setSpeed(speed);
  }

  // Download a recitation for offline use
  Future<void> downloadRecitation({
    required Reciter reciter,
    required RecitationTrack track,
    Function(int, int)? onProgress,
  }) async {
    try {
      final dio = Dio();
      final audioUrl = track.getAudioUrl(reciter);

      // Get app directory
      final directory = await getApplicationDocumentsDirectory();
      final reciterDir = Directory('${directory.path}/audio/${reciter.id}');

      if (!await reciterDir.exists()) {
        await reciterDir.create(recursive: true);
      }

      final filePath =
          '${reciterDir.path}/${track.surahNumber.toString().padLeft(3, '0')}.mp3';

      // Download file
      await dio.download(
        audioUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (onProgress != null && total != -1) {
            onProgress(received, total);
          }
        },
      );

      // Update track with local path
      _currentTrack = track.copyWith(isDownloaded: true, localPath: filePath);

      print('Downloaded recitation to: $filePath');
    } catch (e) {
      print('Error downloading recitation: $e');
      rethrow;
    }
  }

  // Delete downloaded recitation
  Future<void> deleteDownload(RecitationTrack track) async {
    try {
      if (track.localPath != null) {
        final file = File(track.localPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      print('Error deleting download: $e');
    }
  }

  // Get total size of downloaded recitations
  Future<int> getTotalDownloadSize(String reciterId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final reciterDir = Directory('${directory.path}/audio/$reciterId');

      if (!await reciterDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (var file in reciterDir.list()) {
        if (file is File) {
          totalSize += await file.length();
        }
      }

      return totalSize;
    } catch (e) {
      print('Error calculating download size: $e');
      return 0;
    }
  }

  // Clean up resources
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
