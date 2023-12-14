import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:typewritertext/typewritertext.dart';

class ChatScreen extends StatefulWidget {
  final String contextText;

  const ChatScreen({super.key, required this.contextText});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();

  bool isLoading = false;
  final List<Message> messages = [];

  Future<String> _sendMessage(String question) async {
    var apiKey =
        'GOOGLE_GEN_AI_PaLM_API_KEY'; //Get API key from google PaLM GenAI

    var url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta3/models/chat-bison-001:generateMessage?key=$apiKey');
    var headers = {'Content-Type': 'application/json; charset=UTF-8'};
    final body = jsonEncode({
      "prompt": {
        "context":
            '${widget.contextText}.\n\nAnswer the following question with reference to the above text context, using a concise and informative style. Provide more detail only when explicitly asked.',
        // "examples": [],
        // "examples": [
        //   {
        //     "input": {"content": "Write a haiku about Google Photos."},
        //     "output": {
        //       "content":
        //           "Google Photos, my friend\nA journey of a lifetime\nCaptured in pixels"
        //     }
        //   }
        // ],
        "messages": [
          {"content": question}
        ]
      },
      "candidate_count": 3,
      "temperature": 1,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        // String answer = response.body;
        String answer = decodedResponse['candidates'][0]['content'];
        return answer;
      } else {
        return 'Request failed with status: ${response.statusCode}.\n\n${response.body}';
      }
    } catch (error) {
      throw Exception('Error sending POST request: $error');
    }
  }

  void _handleSubmitted(String text) async {
    FocusScopeNode currentFocus =
        FocusScope.of(context); // get the current focus node

    if (!currentFocus.hasPrimaryFocus) {
      // prevent Flutter from throwing an exception
      currentFocus
          .unfocus(); // unfocus from current focus, so that keyboard will dismiss
    }

    if (isLoading) {
      return;
    }

    _textController.clear();
    setState(() {
      isLoading = true;
      messages.add(Message(authorId: 0, content: text));
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        messages.add(Message(authorId: 1, content: ''));
      });
    });
    String answer = await _sendMessage(text);
    setState(() {
      messages.removeLast();
      messages.add(Message(authorId: 1, content: answer));
      isLoading = false;
    });
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).hintColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
        decoration: BoxDecoration(
          // color: Theme.of(context).colorScheme.secondary,
          color: Colors.lightBlueAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: const InputDecoration.collapsed(
                  hintText: "Ask me anything about your meeting",
                  hintStyle: TextStyle(color: Colors.white70),
                ),
              ),
            ),
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.white38,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // alignment: Alignment.bottomCenter,
      children: <Widget>[
        //listview builder inside a expande widget
        Expanded(
          child: ListView.builder(
            //item count is the number of messages in the chat
            itemCount: messages.length,
            //item builder builds each message
            itemBuilder: (BuildContext context, int index) {
              Message message = messages[index];
              return MessageItem(message: message);
            },
          ),
        ),
        _buildTextComposer(),
      ],
    );
  }
}

class MessageItem extends StatelessWidget {
  const MessageItem({
    super.key,
    required this.message,
  });

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            child: Icon(
              (message.authorId == 0) ? Icons.person : Icons.computer,
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Flexible(
            child: Container(
              alignment: Alignment.centerLeft,
              // margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(message.authorId == 0 ? 'You' : 'AI Assistant',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                    message.content == ''
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Asistant is thinking...'),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                width: 100,
                                child: const LoadingIndicator(
                                    indicatorType: Indicator.ballGridBeat),
                              ),
                            ],
                          )
                        : TypeWriterText(
                            text: Text(message.content),
                            duration: const Duration(milliseconds: 10),
                          ),
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final int authorId;
  final String content;

  Message({required this.authorId, required this.content});
}
