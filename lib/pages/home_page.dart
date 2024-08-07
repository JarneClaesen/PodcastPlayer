
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:id3tag/id3tag.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mp3_info/mp3_info.dart';
import 'package:rxdart/rxdart.dart';
import '../data/hive_database.dart';
import '../service/audio_service.dart';
import '../widgets/audio_control_bar.dart';
import '../widgets/podcast_card.dart';
import '/model/episode.dart';
import '/model/podcast.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';



import 'episode_page.dart';
import 'episode_player_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Episode? _currentEpisode;
  bool _isSelectionMode = false;
  Set<int> _selectedEpisodes = {};
  Set<String> _selectedPodcastTitles = {};


  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    //checkAsset();
    _init();
  }

  Future<void> checkAsset() async {
    try {
      final byteData = await rootBundle.load('assets/audio/HeyJude.mp3');
      print('Success: Loaded ${byteData.lengthInBytes} bytes');
    } catch (e) {
      print('Error: Could not load asset. $e');
    }
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
          print('A stream error occurred: $e');
        });
  }

  @override
  void dispose() {
    _player.dispose();
    AudioService.dispose();
    super.dispose();
  }

  void _playEpisode(Episode episode) async {
    await AudioService.playEpisode(episode);
    setState(() {}); // Trigger a rebuild to update the UI
  }

  // todo: loadingcicle and error handling
  Future<void> uploadEpisodes() async {
    var episodeBox = HiveDatabase().episodeBox;
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;

      for (PlatformFile file in result.files) {
        if (file.path != null) {
          File originalFile = File(file.path!);
          String newFilePath = '$appDocPath/${path.basename(file.path!)}';

          // Copy the file to the new location
          await originalFile.copy(newFilePath);

          // Use id3tag to read the podcast title and other data
          final parser = ID3TagReader.path(newFilePath);
          final tag = parser.readTagSync();
          String podcastTitle = tag.album ?? 'Unknown Podcast';
          String episodeTitle = tag.title ?? path.basenameWithoutExtension(file.name);
          int totalDuration = getDurationFromFile(newFilePath);

          Uint8List? albumArtData;
          if (tag.pictures.isNotEmpty) {
            var picture = tag.pictures.first;
            albumArtData = Uint8List.fromList(picture.imageData);
          }

          // Check if the episode already exists
          bool episodeExists = episodeBox.values.any((ep) =>
          ep.title == episodeTitle && ep.podcastTitle == podcastTitle);

          if (!episodeExists) {
            // Create and add a new episode with the new file path
            var newEpisode = Episode(
              title: episodeTitle,
              audioUrl: newFilePath, // Use the new file path
              podcastTitle: podcastTitle,
              totalDurationInSeconds: totalDuration,
              albumArtData: albumArtData,
            );
            episodeBox.add(newEpisode);
          }
        }
      }
    }
    setState(() {}); // Refresh the UI
  }

  int getDurationFromFile(String filePath) {
    // Use mp3_info or another package to get the duration of the file
    MP3Info mp3 = MP3Processor.fromFile(File(filePath));
    return mp3.duration?.inSeconds ?? 0;
  }


  Future<void> deleteEpisodes() async {
    var episodeBox = HiveDatabase().episodeBox; // Accessing episodeBox using HiveDatabase singleton

    // Show confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete thes selected episodes?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirmDelete) {
      // Perform deletion
      var sortedIndexes = _selectedEpisodes.toList()..sort((a, b) => b.compareTo(a));
      for (var index in sortedIndexes) {
        var episode = episodeBox.getAt(index);
        if (episode != null) {
          var file = File(episode.audioUrl);
          if (await file.exists()) {
            await file.delete();
            if (!(await file.exists())) {
              print('File deleted successfully.');
            } else {
              print('Failed to delete the file.');
            }
          }
          // Delete the episode from Hive box
          await episodeBox.deleteAt(index);
        }
      }

      setState(() {
        _isSelectionMode = false;
        _selectedEpisodes.clear();
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    var episodeBox = HiveDatabase().episodeBox;
    Set<String> uniquePodcastTitles = episodeBox.values.map((e) => e.podcastTitle).toSet();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isSelectionMode ? 'Select Podcasts' : 'Podcasts'),
        leading: _isSelectionMode ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _isSelectionMode = false;
              _selectedPodcastTitles.clear();
            });
          },
        ) : null,
        actions: [
          if (_isSelectionMode)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child:
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  await deletePodcasts(_selectedPodcastTitles);
                },
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: const Icon(Icons.add),
                onPressed: uploadEpisodes,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: uniquePodcastTitles.length,
              itemBuilder: (context, index) {
                String podcastTitle = uniquePodcastTitles.elementAt(index);
                bool isSelected = _selectedPodcastTitles.contains(podcastTitle);

                // Retrieve the first episode's album art for this podcast title
                // or provide a default Episode object
                Episode firstEpisode = episodeBox.values.firstWhere(
                        (ep) => ep.podcastTitle == podcastTitle,
                    orElse: () => Episode(
                      title: '',
                      audioUrl: '',
                      podcastTitle: '',
                      totalDurationInSeconds: 0,
                      // other required Episode fields with default values
                    )
                );
                Uint8List? albumArtData = firstEpisode.albumArtData;

                return PodcastCard(
                  podcastTitle: podcastTitle,
                  isSelected: isSelected,
                  showCheckbox: _isSelectionMode,
                  onTap: () => handlePodcastTap(podcastTitle),
                  onLongPress: () => handlePodcastLongPress(podcastTitle),
                  onCheckboxChanged: (bool? value) => handlePodcastTap(podcastTitle),
                  albumArtData: albumArtData,
                );
              },
            ),
          ),
          AudioControlBar(),
        ],
      ),
    );
  }

  void handlePodcastTap(String podcastTitle) {
    if (_isSelectionMode) {
      setState(() {
        if (_selectedPodcastTitles.contains(podcastTitle)) {
          _selectedPodcastTitles.remove(podcastTitle);
        } else {
          _selectedPodcastTitles.add(podcastTitle);
        }
        // Automatically exit selection mode if no podcasts are selected
        if (_selectedPodcastTitles.isEmpty) {
          _isSelectionMode = false;
        }
      });
    } else {
      // Navigate to EpisodesPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EpisodesPage(podcastTitle: podcastTitle),
        ),
      );
    }
  }


  void handlePodcastLongPress(String podcastTitle) {
    setState(() {
      _isSelectionMode = true;
      _selectedPodcastTitles.add(podcastTitle);
    });
  }

  Future<void> deletePodcasts(Set<String> podcastTitlesToDelete) async {
    var episodeBox = HiveDatabase().episodeBox;

    // Show confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.1),
          title: Text("Confirm Delete", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          content: Text("Are you sure you want to delete the selected podcasts and their episodes?",
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirmDelete) {
      // Delete episodes that belong to the selected podcast titles
      episodeBox.values.where((episode) => podcastTitlesToDelete.contains(episode.podcastTitle)).toList().forEach((episode) {
        // Delete the MP3 file from the device
        try {
          File(episode.audioUrl).delete();
        } catch (e) {
          print("Error deleting file: $e");
        }
        episodeBox.delete(episode.key);
      });

      setState(() {
        _isSelectionMode = false;
        _selectedPodcastTitles.clear();
      });
    }
  }



}