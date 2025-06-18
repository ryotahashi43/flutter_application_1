import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // ← 日付表示用
import '../services/gemini_service.dart';

class ChatPage extends StatefulWidget {
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  late final String uid;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
  }

  // ───────── 送信 ─────────
  Future<void> _sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;
    _controller.clear();

    // user 発言
    await _firestore.collection('users').doc(uid).collection('chats').add({
      'role': 'user',
      'text': input,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Gemini 返信
    final reply = await getGeminiResponse(input);
    await _firestore.collection('users').doc(uid).collection('chats').add({
      'role': 'assistant',
      'text': reply,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ───────── UI ─────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('学習アシスタントチャット')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(uid)
                  .collection('chats')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                final List<Widget> messageWidgets = [];
                String? lastDateLabel;

                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final isUser = data['role'] == 'user';

                  // タイムスタンプ → 日付ラベル
                  final ts = data['timestamp'] as Timestamp?;
                  final dateLabel = ts != null
                      ? DateFormat('yyyy年M月d日（EEE）', 'ja').format(ts.toDate())
                      : '不明な日付';

                  // 日付が変わったらラベルを挿入
                  if (lastDateLabel != dateLabel) {
                    messageWidgets.add(
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(
                          child: Text(
                            dateLabel,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                    lastDateLabel = dateLabel;
                  }

                  // メッセージ本体
                  messageWidgets.add(
                    Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(data['text'] ?? ''),
                      ),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.only(bottom: 10),
                  children: messageWidgets,
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: '質問を入力...'),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
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
