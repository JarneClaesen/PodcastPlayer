import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../pages/episode_player_page.dart';
import '../service/audio_service.dart';
import '/model/episode.dart';

// todo: make invisible when no episode is playing instead of "Select an Episode"

class AudioControlBar extends StatefulWidget {
  const AudioControlBar({Key? key}) : super(key: key);

  @override
  State<AudioControlBar> createState() => _AudioControlBarState();
}

class _AudioControlBarState extends State<AudioControlBar> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: AudioService.player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final playing = playerState?.playing;
        return GestureDetector(
          onTap: () {
            if (AudioService.currentEpisode != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EpisodePlayerPage(episode: AudioService.currentEpisode!),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        if (playing == true)
                          IconButton(
                            icon: const Icon(Icons.pause),
                            onPressed: () => AudioService.player.pause(),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.play_arrow),
                            onPressed: () => AudioService.player.play(),
                          ),
                        Expanded(
                          child: StreamBuilder<Episode?>(
                            stream: AudioService.currentEpisodeStream,
                            builder: (context, snapshot) {
                              String nowPlayingTitle = snapshot.data != null ? snapshot.data!.title : 'Select an Episode';
                              return Text(
                                  nowPlayingTitle,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                                  ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0), // Padding for the progress bar
                    child: StreamBuilder<Duration?>(
                      stream: AudioService.player.durationStream,
                      builder: (context, snapshot) {
                        final totalDuration = snapshot.data ?? Duration.zero;
                        return StreamBuilder<Duration?>(
                          stream: AudioService.player.positionStream,
                          builder: (context, snapshot) {
                            var position = snapshot.data ?? Duration.zero;
                            return Container(
                              height: 3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: LinearProgressIndicator(
                                  value: totalDuration.inMilliseconds == 0 ? 0 : position.inMilliseconds / totalDuration.inMilliseconds,
                                  minHeight: 2,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onSecondaryContainer),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
