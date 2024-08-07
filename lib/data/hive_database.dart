import 'package:hive/hive.dart';
import '/model/episode.dart';

class HiveDatabase {
  static final HiveDatabase _instance = HiveDatabase._internal();
  late Box<Episode> episodeBox;

  factory HiveDatabase() {
    return _instance;
  }

  HiveDatabase._internal();

  Future<void> init() async {
    // Initialize Hive and open the box here
    Hive.registerAdapter(EpisodeAdapter());
    episodeBox = await Hive.openBox<Episode>('episodes');
    //_populateInitialData();
  }
}
