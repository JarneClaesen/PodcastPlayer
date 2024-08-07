import 'package:audio_service/audio_service.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:potcastplayer/data/hive_database.dart';
import 'data/DatabaseHelper.dart';
import 'model/episode.dart';
import 'model/podcast.dart';
import 'pages/home_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme/theme_provider.dart';

Future<void> main() async {
  //WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  await Hive.initFlutter();
  await HiveDatabase().init();
  runApp(PodcastApp());
}

class PodcastApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
          ColorScheme darkColorScheme;

          darkColorScheme = ColorScheme.fromSeed(
              seedColor: Colors.green, brightness: Brightness.dark);

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Podcast App',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: darkColorScheme,
              scaffoldBackgroundColor: darkColorScheme.background,
              textTheme: GoogleFonts.poppinsTextTheme(),
              //
            ),
            home: const HomePage(),
          );
        }
    );
  }
}
