import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:path/path.dart';

class TranscriptionHandler {
  final String revAiAccessToken;
  final http.Client client;

  TranscriptionHandler({required this.revAiAccessToken, required this.client});

  Future<String> submitJob(String filePath) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.rev.ai/speechtotext/v1/jobs'),
    );
    request.headers.addAll({
      'Authorization': 'Bearer $revAiAccessToken',
    });
    request.files.add(await http.MultipartFile.fromPath(
      'media',
      filePath,
    ));
    request.fields['options'] = jsonEncode({'metadata': 'This is a test'});

    var response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['id'];
    } else {
      throw Exception('Failed to submit job');
    }
  }

  Future<Map<String, dynamic>> getJob(String jobId) async {
    final response = await client.get(
      Uri.parse('https://api.rev.ai/speechtotext/v1/jobs/$jobId'),
      headers: {'Authorization': 'Bearer $revAiAccessToken'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get job');
    }
  }

  Future<Map<String, dynamic>> getTranscript(String jobId) async {
    final response = await client.get(
      Uri.parse('https://api.rev.ai/speechtotext/v1/jobs/$jobId/transcript'),
      headers: {
        'Authorization': 'Bearer $revAiAccessToken',
        'Accept': 'application/vnd.rev.transcript.v1.0+json',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get transcript');
    }
  }

  String transcriptToText(Map<String, dynamic> transcript) {
    final monologues = transcript['monologues'] as List<dynamic>;
    final buffer = StringBuffer();

    for (final monologue in monologues) {
      final elements = monologue['elements'] as List<dynamic>;

      for (final element in elements) {
        if (element['type'] == 'text' || element['type'] == 'punct') {
          buffer.write(element['value']);
        }
      }
    }

    return buffer.toString();
  }
}
