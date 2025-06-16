import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/gemini_service.dart';

class ChatPage extends StatefulWidget {
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final snapshot =
        await _firestore.collection('chatMessages').orderBy('timestamp').get();

    final chats = snapshot.docs
        .map((doc) => {
              "role": doc['role']?.toString() ?? '',
              "text": doc['text']?.toString() ?? '',
            })
        .toList();

    setState(() {
      _messages.addAll(chats);
    });
  }

  Future<void> _sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    _controller.clear();

    // ユーザーのメッセージをFirestoreに追加
    await _firestore.collection('chatMessages').add({
      'role': 'user',
      'text': input,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _messages.add({"role": "user", "text": input});
    });

    final reply = await getGeminiResponse(input);

    // Geminiの返答も保存
    await _firestore.collection('chatMessages').add({
      'role': 'assistant',
      'text': reply,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _messages.add({"role": "assistant", "text": reply});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('学習アシスタントチャット')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(message['text'] ?? ''),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: '質問を入力...'),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
