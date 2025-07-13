import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // ← 日付・時刻表示用
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
      appBar: AppBar(
        title: const Text('学習アシスタントチャット'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            tooltip: '全履歴削除',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('チャット履歴を削除しますか？'),
                  content: Text('すべてのチャット履歴が削除されます。'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('キャンセル')),
                    ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('削除')),
                  ],
                ),
              );
              if (confirmed == true) {
                final chats = await _firestore
                    .collection('users')
                    .doc(uid)
                    .collection('chats')
                    .get();
                for (var doc in chats.docs) {
                  await doc.reference.delete();
                }
              }
            },
          )
        ],
      ),
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

                  final ts = data['timestamp'] as Timestamp?;
                  final date = ts?.toDate();
                  final dateLabel = date != null
                      ? DateFormat('yyyy年M月d日（EEE）', 'ja').format(date)
                      : '不明な日付';
                  final timeLabel =
                      date != null ? DateFormat('HH:mm').format(date) : '';

                  // 日付が変わったら日付ラベルを表示
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

                  // メッセージ本体 + 送信時刻
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(data['text'] ?? ''),
                            SizedBox(height: 4),
                            Text(
                              timeLabel,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
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
