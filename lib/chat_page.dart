import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'gemini_service.dart';

class ChatBotPage extends StatefulWidget {
  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    // Firestore にユーザーのメッセージを保存
    await FirebaseFirestore.instance.collection('chatMessages').add({
      'text': input,
      'isUser': true,
      'timestamp': Timestamp.now(),
    });

    _controller.clear();

    // Gemini の返答を取得
    final reply = await getGeminiResponse(input);

    // Firestore に AI の返答を保存
    await FirebaseFirestore.instance.collection('chatMessages').add({
      'text': reply,
      'isUser': false,
      'timestamp': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gemini チャット')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chatMessages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index];
                    final text = data['text'];
                    final isUser = data['isUser'] as bool;

                    return Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(text),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(child: TextField(controller: _controller)),
              IconButton(icon: Icon(Icons.send), onPressed: _sendMessage),
            ],
          ),
        ],
      ),
    );
  }
}
