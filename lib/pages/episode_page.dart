import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:potcastplayer/data/hive_database.dart';
import 'package:potcastplayer/widgets/audio_control_bar.dart';
import '../model/episode.dart';
import '../widgets/episode_card.dart';
import '../service/audio_service.dart';

class EpisodesPage extends StatelessWidget {
  final String podcastTitle;

  const EpisodesPage({Key? key, required this.podcastTitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final episodeBox = HiveDatabase().episodeBox;
    List<Episode> episodesForPodcast = episodeBox.values
        .where((episode) => episode.podcastTitle == podcastTitle)
        .toList();

    episodesForPodcast.sort((a, b) => a.title.compareTo(b.title));

    return Scaffold(
      appBar: AppBar(
        title: Text(podcastTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: episodesForPodcast.length,
              itemBuilder: (context, index) {
                var episode = episodesForPodcast[index];
                return ValueListenableBuilder<Box<Episode>>(
                  valueListenable: episodeBox.listenable(keys: [episode.key]),
                  builder: (context, box, _) {
                    var updatedEpisode = box.get(episode.key)!;
                    double progressPercentage =
                    (updatedEpisode.progressInSeconds / updatedEpisode.totalDurationInSeconds)
                        .clamp(0, 1)
                        .toDouble();

                    return EpisodeCard(
                      episodeTitle: updatedEpisode.title,
                      progressPercentage: progressPercentage,
                      onTap: () {
                        AudioService.playEpisode(updatedEpisode);
                      },
                      albumArtData: updatedEpisode.albumArtData,
                      episodeNumber: index + 1,  // Pass the episode number (index + 1)
                    );
                  },
                );
              },
            ),
          ),
          AudioControlBar(),
        ],
      ),
    );
  }
}
