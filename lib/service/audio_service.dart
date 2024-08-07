// audio_service.dart
import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../data/hive_database.dart';
import '/model/episode.dart';

class AudioService {
  static final AudioPlayer player = AudioPlayer();
  static Episode? currentEpisode;

  static final _currentEpisodeStreamController = StreamController<Episode?>.broadcast();
  static Stream<Episode?> get currentEpisodeStream => _currentEpisodeStreamController.stream;

  static Future<void> playEpisode(Episode episode) async {
    if (player.playing) {
      await player.stop();
    }

    // Using HiveDatabase singleton to access the episodeBox
    var episodeBox = HiveDatabase().episodeBox;

    // Finding an existing episode in the box or adding a new one
    Episode hiveEpisode = episodeBox.values.firstWhere(
          (ep) => ep.title == episode.title && ep.audioUrl == episode.audioUrl,
      orElse: () => episode,
    );

    if (!episodeBox.containsKey(hiveEpisode.key)) {
      await episodeBox.add(hiveEpisode); // Add the episode to the Hive box if it's not already there
    } else {
      hiveEpisode.save(); // Save changes to the existing episode
    }

    currentEpisode = hiveEpisode;

    _currentEpisodeStreamController.add(currentEpisode!);

    var mediaItem = MediaItem(
      id: currentEpisode!.audioUrl,
      title: currentEpisode!.title,
      album: currentEpisode!.podcastTitle,
      artUri: currentEpisode!.albumArtData != null
          ? Uri.dataFromBytes(currentEpisode!.albumArtData!)
          : Uri.file('assets/images/placeholder.jpg'),
    );

    await player.setAudioSource(
      AudioSource.uri(
          Uri.parse(currentEpisode!.audioUrl),
          tag: mediaItem
      ),
      preload: true,
    );

    await player.seek(Duration(seconds: currentEpisode!.progressInSeconds));
    player.play();

    player.positionStream.listen((position) {
      if (currentEpisode != null && player.playing) {
        currentEpisode!.progressInSeconds = position.inSeconds;
        currentEpisode!.save();
      }
    });

    // Listen to playerStateStream to react to completion of playback
    player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        // Handle completion of playback
        _handlePlaybackCompletion();
      }
    });
  }

  static void _handlePlaybackCompletion() {
    // Logic to handle completion of playback
    print("Playback completed for episode: ${currentEpisode?.title}");
    player.stop(); // Stop the player
  }

  static void dispose() {
    _currentEpisodeStreamController.close();
    player.dispose();
  }
}
