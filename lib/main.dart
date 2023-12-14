import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:my_app/models/recording.dart';
import 'package:my_app/pages/home_screen.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocumentDirectory =
      await path_provider.getApplicationDocumentsDirectory();

  await Hive.initFlutter(appDocumentDirectory.path);
  Hive.registerAdapter(RecordingAdapter());
  await Hive.openBox<Recording>('recordingsbox');

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const MyApp());
  });
  await Hive.close();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Meeting Assistent',
      home: HomePage(),
    );
  }
}
