import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;



class AskAnything extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChatScreen(roomName: 'Traveler\'s Lounge');
  }
}

class ChatScreen extends StatefulWidget {
  final String roomName;

  const ChatScreen({super.key, required this.roomName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<MessageModel> messages = [];
  TextEditingController _controller = TextEditingController();
  late ChatAPI _chatAPI;

  @override
  void initState() {
    super.initState();
    _chatAPI = ChatAPI();
  }

  Future<void> sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    String content = _controller.text.trim();
    DateTime now = DateTime.now();

    MessageModel newMessage = MessageModel(
      name: widget.roomName,
      isUser: true,
      content: content,
      time: now,
    );

    setState(() {
      messages.add(newMessage);
    });

    _controller.clear();

    await generateResponse(content);
  }

  Future<void> generateResponse(String userMessage) async {
    String llamaAnswer = await _chatAPI.generateResponse(userMessage);

    DateTime now = DateTime.now();
    MessageModel llamaMessage = MessageModel(
      name: widget.roomName,
      isUser: false,
      content: llamaAnswer,
      time: now,
    );

    setState(() {
      messages.add(llamaMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.flight_takeoff, color: Colors.black),
            SizedBox(width: 8),
            Text(widget.roomName),
          ],
        ),
        backgroundColor: Colors.orange.shade300,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: message.isUser
                      ? UserMessageWidget(message: message)
                      : AgentMessageWidget(message: message),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      filled: true,
                      fillColor: Colors.black,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                color: Colors.orange.shade600,
                onPressed: sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MessageModel {
  final String name;
  final bool isUser;
  final String content;
  final DateTime time;

  MessageModel({
    required this.name,
    required this.isUser,
    required this.content,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'isUser': isUser,
    'content': content,
    'time': time.toIso8601String(),
  };

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      name: json['name'],
      isUser: json['isUser'],
      content: json['content'],
      time: DateTime.parse(json['time']),
    );
  }
}

class UserMessageWidget extends StatelessWidget {
  final MessageModel message;

  const UserMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.orange.shade200,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Text(
          message.content,
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}

class AgentMessageWidget extends StatelessWidget {
  final MessageModel message;

  const AgentMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          children: [
            Icon(Icons.map, color: Colors.orange.shade600),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message.content,
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatAPI {
  final String apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  final String apiKey = 'Bearer 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';

  Future<String> generateResponse(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': apiKey,
        },
        body: jsonEncode({
          'model': 'llama3-8b-8192',
          'messages': [
            {'role': 'user', 'content': userMessage}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        print("Error generating response: ${response.statusCode}");
        return "Error: Failed to generate response.";
      }
    } catch (e) {
      print("Error generating response: $e");
      return "Error: Failed to generate response.";
    }
  }
}
