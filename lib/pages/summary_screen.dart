import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:loading_indicator/loading_indicator.dart';
import 'package:my_app/models/recording.dart';

class SummaryScreen extends StatefulWidget {
  final int index;

  const SummaryScreen({super.key, required this.index});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final Box<Recording> recordingsBox = Hive.box<Recording>('recordingsbox');

  // HiveDatabaseHandler hiveDatabaseHandler = HiveDatabaseHandler();

  bool isSummaryPresent = false;
  bool isButtonPressed = false;
  String summarizedText = '';
  late Recording recording;

  @override
  void initState() {
    super.initState();
    recording = recordingsBox.getAt(widget.index)!;
    if (recording.summarizedText.isNotEmpty) {
      setState(() {
        isSummaryPresent = true;
      });
    }
  }

  Future<String> generateSummary() async {
    var apiKey =
        'GOOGLE_GEN_AI_PaLM_API_KEY'; //Get API key from google PaLM GenAI

    var url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta3/models/text-bison-001:generateText?key=$apiKey');
    var headers = {'Content-Type': 'application/json; charset=UTF-8'};
    final body = jsonEncode({
      "prompt": {
        "text":
            "${recording.transcribedText}.\n\nSummarize the above text and give response",
      },
      "candidate_count": 1,
      "temperature": 1,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        String summary = decodedResponse['candidates'][0]['output'];
        return summary;
      } else {
        return 'Request failed with status: ${response.statusCode}.\n\n${response.body}';
      }
    } catch (error) {
      throw Exception('Error sending POST request: $error');
    }
  }

  void prepareSummary() async {
    if (isSummaryPresent) {
      return;
    }

    String summary = await generateSummary();
    setState(() {
      recording.copyWith(summarizedText: summary);
      isSummaryPresent = true;
      recordingsBox.putAt(widget.index, recording);
    });
  }

  @override
  Widget build(BuildContext context) {
    return isSummaryPresent
        ? Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                child: const Text(
                  "Here are your summarized notes of the meeting:",
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold),
                ),
              ),
              //listview builder inside a expanded widget
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: 400,
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      recording.summarizedText,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    // child: Text("CHat screen"),
                  ),
                ),
              ),

              //
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Press the button to generate summary",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              isButtonPressed
                  ? const LoadingIndicator(indicatorType: Indicator.ballPulse)
                  : Flexible(
                      child: ElevatedButton(
                          onPressed: () async {
                            prepareSummary();
                            setState(() {
                              isButtonPressed = true;
                            });
                          },
                          child: const Text("generate summary")),
                    ),
            ],
          );
  }
}
