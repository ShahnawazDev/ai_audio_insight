import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_app/models/recording.dart';
import 'package:my_app/pages/audio_play_screen.dart';
import 'package:my_app/pages/chat_screen.dart';
import 'package:my_app/pages/summary_screen.dart';

class RecordingViewScreen extends StatefulWidget {
  const RecordingViewScreen({super.key, required this.index});

  final int index;

  @override
  State<RecordingViewScreen> createState() => _RecordingViewScreenState();
}

class _RecordingViewScreenState extends State<RecordingViewScreen>
    with TickerProviderStateMixin {
  late List<Recording> recordings;

  late Future<Box<Recording>> recordingsBox;
  // late Box<Recording> recordingsBox;

  @override
  void initState() {
    super.initState();
    recordingsBox = Hive.openBox<Recording>('recordingsbox');
  }

  void stopAudio() {
    // ...
  }

  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 3, vsync: this);
    return FutureBuilder(
        future: recordingsBox,
        builder: (context, snapshot) {
          final recordingsBox = Hive.box<Recording>('recordingsbox');
          return ValueListenableBuilder(
              valueListenable: recordingsBox.listenable(),
              builder: (context, Box<Recording> box, _) {
                Recording recording = box.getAt(widget.index)!;
                return Scaffold(
                  appBar: AppBar(
                    title: Text(recording.title),
                    centerTitle: true,
                    elevation: 0,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                  ),
                  body: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(15, 15, 15, 10),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: RecordingViewTabBar(
                          tabController: tabController,
                          stopAudio: stopAudio,
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: tabController,
                          children: <Widget>[
                            AudioPlayScreen(
                              index: widget.index,
                              stopAudio: stopAudio,
                            ),
                            SummaryScreen(
                              index: widget.index,
                            ),
                            ChatScreen(
                              contextText: recording.transcribedText,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              });
        });
  }
}

class RecordingViewTabBar extends StatelessWidget {
  const RecordingViewTabBar({
    super.key,
    required this.tabController,
    required this.stopAudio,
  });

  final TabController tabController;
  final Function stopAudio;

  @override
  Widget build(BuildContext context) {
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        stopAudio();
      }
    });
    return TabBar(
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.lightBlue,
      ),
      indicatorSize: TabBarIndicatorSize.label,
      controller: tabController,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.black87,
      isScrollable: false,
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 0),
      tabs: ["Audio", "Summary", "Chat"]
          .map(
            (text) => Tab(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Text(
                  text,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
