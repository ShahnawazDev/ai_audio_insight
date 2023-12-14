import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_app/models/recording.dart';
import 'package:my_app/services/transcription_handler.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:http/http.dart' as http;

class AudioPlayScreen extends StatefulWidget {
  const AudioPlayScreen({
    super.key,
    required this.index,
    required this.stopAudio,
  });

  final int index;
  final Function stopAudio;
  @override
  State<AudioPlayScreen> createState() => _AudioPlayScreenState();
}

class _AudioPlayScreenState extends State<AudioPlayScreen>
    with TickerProviderStateMixin {
  final Box<Recording> recordingsBox = Hive.box<Recording>('recordingsbox');

  late Recording recording;

  bool isPlaying = false;
  bool isButtonPressed = false;
  int? subTabIndex = 0;

  // String url = "/data/user/0/com.example.my_app/app_flutter/hello.m4a";

  AudioPlayer audioPlayer = AudioPlayer();

  // ignore: unused_element
  void _stopAudio() {
    // audioPlayer.pause();
    audioPlayer.stop();
    setState(() {
      isPlaying = false;
    });
    widget.stopAudio();
  }

  @override
  initState() {
    recording = recordingsBox.getAt(widget.index)!;
    super.initState();
    if (recording.transcribedText.isEmpty) {
      setState(() {
        isButtonPressed = true;
      });
      generateTranscription();
    }
  }

  @override
  dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> generateTranscription() async {
    if (recording.transcribedText.isNotEmpty) {
      return;
    }

    final transcriptionHandler = TranscriptionHandler(
      revAiAccessToken: 'REV_AI_ACCESS_TOKEN', //get access token from rev.ai
      client: http.Client(),
    );
    final jobId = await transcriptionHandler.submitJob(recording.path);

    while (true) {
      var job = await transcriptionHandler.getJob(jobId);
      if (job['status'] == 'transcribed') {
        var transcript = await transcriptionHandler.getTranscript(jobId);

        setState(() {
          print("RECORDING TRANSCRIPED: ${recording.transcribedText}");
          recording.transcribedText =
              transcriptionHandler.transcriptToText(transcript);
          // final newRecording = recording.copyWith(
          //     transcribedText:
          //         transcriptionHandler.transcriptToText(transcript));
          recordingsBox.putAt(widget.index, recording);
          print("RECORDING TRANSCRIPED: ${recording.transcribedText}");
        });
        break;
      } else {
        // Wait for a few seconds before checking again
        await Future.delayed(const Duration(seconds: 5));
      }
    }

    // final transcript = await transcriptionHandler.getTranscript(jobId);
    // print("TRANSCRIPT");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Spacer(
            //   flex: 1,
            // ),
            Flexible(
              child: Container(
                height: 800,
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: subTabIndex == 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 50),
                        child: const LoadingIndicator(
                          // colors: [
                          //   Colors.red,
                          //   Colors.orange,
                          //   Colors.yellow,
                          //   Colors.green,
                          //   Colors.blue,
                          //   Colors.indigo,
                          //   Colors.purple,
                          // ],
                          indicatorType: Indicator.lineScalePulseOutRapid,
                          strokeWidth: 1,
                          // pause: pause,
                          // pathBackgroundColor: Colors.black45,
                        ),
                      )
                    : recording.transcribedText.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: isButtonPressed
                                ? [
                                    const LoadingIndicator(
                                      indicatorType:
                                          Indicator.ballClipRotateMultiple,
                                    ),
                                    const Text(
                                      "Plese wait while AI is Transcribing...",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ]
                                : [
                                    const Text(
                                      'Press button to generate transcription',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        setState(() {
                                          isButtonPressed = true;
                                        });
                                        await generateTranscription();
                                        setState(() {
                                          isButtonPressed = false;
                                        });
                                      },
                                      child: const Text(
                                        "Generate Transcription",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                          )
                        : SingleChildScrollView(
                            child: Text(
                              recording.transcribedText,
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.black87),
                            ),
                          ),
              ),
            ),
            // Spacer(
            //   flex: 1,
            // ),
            Center(
              child: Text(
                recording.duration.split('.')[0],
                // Utils.formatDuration(recording.duration),
                style: const TextStyle(fontSize: 30, color: Colors.black87),
              ),
            ),
            Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: ToggleSwitch(
                  minWidth: 140.0,
                  cornerRadius: 20.0,
                  activeBgColors: const [
                    [Colors.lightBlueAccent],
                    [Colors.lightBlueAccent]
                  ],
                  activeFgColor: Colors.white,
                  inactiveBgColor: Colors.black12,
                  inactiveFgColor: Colors.black87,
                  initialLabelIndex: subTabIndex,
                  totalSwitches: 2,
                  labels: const ['Audio', 'Transcription'],
                  radiusStyle: true,
                  onToggle: (index) {
                    setState(() {
                      subTabIndex = index;
                    });
                  },
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.replay_10),
                  iconSize: 40,
                  onPressed: () async {
                    int currentPosition =
                        (await audioPlayer.getCurrentPosition()) as int;
                    await audioPlayer
                        .seek(Duration(milliseconds: currentPosition - 10000));
                  },
                ),
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: isPlaying
                      ? IconButton(
                          icon: const Icon(Icons.pause),
                          iconSize: 50,
                          onPressed: () async {
                            setState(() {
                              isPlaying = false;
                            });
                            await audioPlayer.pause();
                          },
                        )
                      : IconButton(
                          icon: const Icon(Icons.play_arrow),
                          iconSize: 50,
                          onPressed: () async {
                            setState(() {
                              isPlaying = true;
                            });
                            await audioPlayer.play(
                              UrlSource(recording.path),
                            );
                          },
                        ),
                ),
                IconButton(
                  icon: const Icon(Icons.forward_10),
                  iconSize: 40,
                  onPressed: () async {
                    int currentPosition =
                        (await audioPlayer.getCurrentPosition()) as int;
                    await audioPlayer
                        .seek(Duration(milliseconds: currentPosition + 10000));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
