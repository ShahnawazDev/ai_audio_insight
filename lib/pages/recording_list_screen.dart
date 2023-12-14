import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_app/models/recording.dart';
import 'package:my_app/pages/recording_view_screen.dart';

class RecordingListScreen extends StatefulWidget {
  const RecordingListScreen({super.key});

  @override
  State<RecordingListScreen> createState() => _RecordingListScreenState();
}

class _RecordingListScreenState extends State<RecordingListScreen> {
  late Future<Box<Recording>> recordingsBox;

  @override
  void initState() {
    super.initState();
    recordingsBox = Hive.openBox<Recording>('recordingsbox');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: <Widget>[
          FutureBuilder(
            future: recordingsBox,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.error != null) {
                  return Text(snapshot.error.toString());
                } else {
                  final recordingsBox = Hive.box<Recording>('recordingsbox');
                  return ValueListenableBuilder(
                      valueListenable: recordingsBox.listenable(),
                      builder: (context, Box<Recording> box, _) {
                        final recordings = box.values.toList();
                        return myCustomScrollView(recordings);
                      });
                }
              } else {
                return const CircularProgressIndicator();
              }
            },
          )
        ],
      ),
    );
  }

  CustomScrollView myCustomScrollView(List<Recording> recordings) {
    return CustomScrollView(
      slivers: <Widget>[
        const SliverAppBar(
          expandedHeight: 100,
          pinned: true,
          floating: false,
          elevation: 0,
          backgroundColor: Color.fromRGBO(240, 238, 238, 1.0),
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            collapseMode: CollapseMode.pin,
            title: Text(
              "Recordings",
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w300,
                  color: Colors.black),
              textAlign: TextAlign.left,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25.0)),
              child: const TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black54,
                  ),
                  hintText: "Search you're looking for",
                ),
              ),
            ),
          ),
        ),
        SliverList(
            delegate:
                SliverChildBuilderDelegate((BuildContext context, int index) {
          final recording = recordings[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            //make this container clickable and navigate to the recording view screen
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecordingViewScreen(index: index),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: Colors.white,
                ),
                child: ListTile(
                  title: Text(
                    recording.title,
                    // dataModel.title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    recording.duration.split('.')[0],
                    // Utils.formatDuration(Duration.parse(recording.duration)),
                  ), //dataModel.description
                  leading: const Icon(
                    Icons.music_note,
                    color: Colors.black,
                  ),
                  trailing: Container(
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromRGBO(240, 238, 238, 1.0)),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RecordingViewScreen(index: index),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.play_arrow,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }, childCount: recordings.length))
      ],
    );
  }
}
