import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import '../service/audio_service.dart';
import '/model/episode.dart';

class EpisodePlayerPage extends StatefulWidget {
  final Episode episode;

  const EpisodePlayerPage({Key? key, required this.episode}) : super(key: key);

  @override
  _EpisodePlayerPageState createState() => _EpisodePlayerPageState();
}

class _EpisodePlayerPageState extends State<EpisodePlayerPage> {
  late Stream<Duration> _positionStream;

  @override
  void initState() {
    super.initState();
    _positionStream = AudioService.player.positionStream;
  }

  Future<void> _initializeAndPlay() async {
    try {
      await AudioService.player.setAsset(widget.episode.audioUrl);
      AudioService.player.play();
    } catch (e) {
      print('Error loading audio: $e');
    }
  }

  void _rewindAudio() {
    final currentPosition = AudioService.player.position;
    final rewindPosition = currentPosition - Duration(seconds: 10);
    AudioService.player.seek(rewindPosition > Duration.zero ? rewindPosition : Duration.zero);
  }

  void _forwardAudio() {
    final currentPosition = AudioService.player.position;
    final duration = AudioService.player.duration ?? Duration.zero;
    final forwardPosition = currentPosition + Duration(seconds: 10);
    AudioService.player.seek(forwardPosition < duration ? forwardPosition : duration);
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.episode.title),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: widget.episode.albumArtData != null
                      ? Image.memory(
                    widget.episode.albumArtData!,
                    fit: BoxFit.contain,
                  )
                      : Image.asset(
                    'assets/images/placeholder.jpg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Audio Control Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.replay_10),
                      onPressed: _rewindAudio,
                    ),
                    StreamBuilder<PlayerState>(
                      stream: AudioService.player.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final processingState = playerState?.processingState;
                        final playing = playerState?.playing;
                        if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
                        } if (playing != true) {
                          return IconButton(
                            icon: const Icon(Icons.play_circle_fill_rounded),
                            iconSize: 80.0,
                            onPressed: AudioService.player.play,
                          );
                        } else {
                          return IconButton(
                            icon: const Icon(Icons.pause_circle_filled_rounded),
                            iconSize: 80.0,
                            onPressed: AudioService.player.pause,
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.forward_10),
                      onPressed: _forwardAudio,
                    ),
                  ],
                ),
                // Audio Position Slider and Duration
                StreamBuilder<Duration>(
                  stream: _positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final totalDuration = AudioService.player.duration ?? Duration.zero;
                    return Column(
                      children: [
                        Slider(
                          value: position.inSeconds.toDouble(),
                          max: totalDuration.inSeconds.toDouble(),
                          onChanged: (value) {
                            AudioService.player.seek(Duration(seconds: value.toInt()));
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formatDuration(position),
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                              ),
                              Text(
                                formatDuration(totalDuration),
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



}
