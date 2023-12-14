import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:my_app/models/recording.dart';
import 'package:my_app/services/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioRecordingScreen extends StatefulWidget {
  const AudioRecordingScreen({super.key});

  @override
  State<AudioRecordingScreen> createState() => _AudioRecordingScreenState();
}

class _AudioRecordingScreenState extends State<AudioRecordingScreen> {
  // final Box<Recording> recordingsBox = Hive.box<Recording>('recordingsbox');

  // HiveDatabaseHandler hiveDatabaseHandler = HiveDatabaseHandler();
  final recordingsBox = Hive.box<Recording>('recordingsbox');

  final recordAudio = AudioRecorder();

  final _stopwatch = Stopwatch();
  final _timeStreamController = StreamController<Duration>();

  final titleController = TextEditingController();
  // bool isRecordingStated = false;
  bool isCurrentlyRecording = false;
  late Recording currentRecording;
  

  @override
  void initState() {
    titleController.text = 'Untitled';
    startRecording();
    super.initState();
  }

  @override
  build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recorder',
          style: TextStyle(color: Colors.black87, fontSize: 30),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color.fromRGBO(240, 238, 238, 1.0),
        foregroundColor: Colors.black87,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black87,
          ),
        ),
      ),
      // resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromRGBO(240, 238, 238, 1.0),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: titleController,
                style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w300,
                    color: Colors.black),
                decoration: const InputDecoration(
                  hintText: 'Enter a title',
                ),
              ),
            ),
            Flexible(
              child: Container(
                margin: const EdgeInsets.all(5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  color: Colors.white,
                ),
                child: LoadingIndicator(
                  indicatorType: Indicator.lineScale,
                  pause: !isCurrentlyRecording,
                  // color: Colors.blue,
                ),
              ),
            ),
            Center(
              child: StreamBuilder<Duration>(
                stream: _timeStreamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      Utils.formatDuration(snapshot.data!),
                      style:
                          const TextStyle(fontSize: 30, color: Colors.black87),
                    );
                  } else {
                    return const Text(
                      "00:00:00",
                      style: TextStyle(fontSize: 30, color: Colors.black87),
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: IconButton(
                        onPressed: deleteRecording,
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.black87,
                          size: 40,
                        ),
                      )),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: isCurrentlyRecording
                        ? IconButton(
                            onPressed: pauseRecording,
                            icon: const Icon(
                              Icons.pause,
                              color: Colors.black87,
                              size: 40,
                            ),
                          )
                        : IconButton(
                            onPressed: resumeRecording,
                            icon: const Icon(
                              Icons.mic,
                              color: Colors.black87,
                              size: 40,
                            ),
                          ),
                  ),
                  Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: IconButton(
                        onPressed: saveRecording,
                        icon: const Icon(
                          Icons.save,
                          size: 40,
                          color: Colors.black87,
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void startRecording() async {
    
    final directory = await getApplicationDocumentsDirectory();
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    if (!isCurrentlyRecording) {
      _stopwatch.start();
      _timeStreamController
          .addStream(Stream.periodic(const Duration(milliseconds: 100), (_) {
        return _stopwatch.elapsed;
      }));
      bool result = await recordAudio.hasPermission();
      if (result) {
        String dateTime = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
        String path = '${directory.path}/$dateTime.m4a';
        DateTime recordingDateTime = DateTime.now();
        await recordAudio.start(
          const RecordConfig(
            encoder: AudioEncoder.aacEld,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );
        // Duration duration = const Duration(seconds: 1);

        currentRecording = Recording(
          id: 1,
          title: "Titles is not set",
          date: recordingDateTime,
          path: path,
          duration: '00:00:00',
          description: '',
          summarizedText: '',
          transcribedText: '',
        );
      }
    } else {
      await recordAudio.stop();
    }
    setState(() {
      isCurrentlyRecording = !isCurrentlyRecording;
    });
  }

  void pauseRecording() async {
    _stopwatch.stop();
    await recordAudio.pause();
    setState(() {
      isCurrentlyRecording = false;
    });
  }

  void resumeRecording() async {
    _stopwatch.start();
    setState(() {
      isCurrentlyRecording = true;
    });
    await recordAudio.resume();
  }

  void saveRecording() async {
    final Duration finalDuration =
        _stopwatch.elapsed + const Duration(milliseconds: 500);

    setState(() {
      isCurrentlyRecording = false;

      Recording newRecording = currentRecording.copyWith(
        title:
            titleController.text.isNotEmpty ? titleController.text : 'Untitled',
        duration: finalDuration.toString(),
      );
      // _stopwatch.stop();
      // _timeStreamController.close();
      recordAudio.stop;

      recordingsBox.add(newRecording);
    });
    recordAudio.dispose();
    Navigator.pop(context);
  }

  void deleteRecording() async {
    recordAudio.dispose();
    Navigator.pop(context);
  }
}
