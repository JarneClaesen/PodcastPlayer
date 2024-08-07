import 'package:hive/hive.dart';
import 'episode.dart';

part 'podcast.g.dart'; // Hive generates this file

@HiveType(typeId: 1)
class Podcast extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final List<Episode> episodes;

  Podcast({required this.title, required this.episodes});
}
