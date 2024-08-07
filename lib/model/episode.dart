import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'episode.g.dart'; // Hive generates this file

@HiveType(typeId: 0)
class Episode extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String audioUrl;

  @HiveField(2)
  int progressInSeconds;

  @HiveField(3)
  final String podcastTitle;

  @HiveField(4)
  final int totalDurationInSeconds;

  @HiveField(5)
  Uint8List? albumArtData;

  Episode({required this.title, required this.audioUrl, this.progressInSeconds = 0, required this.podcastTitle, required this.totalDurationInSeconds, this.albumArtData});
}
