import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/gemini_service.dart';

class ChatPage extends StatefulWidget {
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _firestore = FirebaseFirestore.instance;
  late final String uid;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
  }

  Future<void> _sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;
    _controller.clear();

    await _firestore.collection('users').doc(uid).collection('chats').add({
      'role': 'user',
      'text': input,
      'timestamp': FieldValue.serverTimestamp(),
    });

    final reply = await getGeminiResponse(input);
    await _firestore.collection('users').doc(uid).collection('chats').add({
      'role': 'assistant',
      'text': reply,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // メッセージ送信後に自動スクロール
    Future.delayed(Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F7FB),
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

                  // 日付ラベル
                  if (lastDateLabel != dateLabel) {
                    messageWidgets.add(
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(
                          child: Text(
                            dateLabel,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                    lastDateLabel = dateLabel;
                  }

                  // 吹き出しメッセージ
                  messageWidgets.add(
                    Row(
                      mainAxisAlignment: isUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isUser)
                          CircleAvatar(
                            backgroundColor: Colors.green[400],
                            child: Icon(Icons.school, color: Colors.white),
                            radius: 18,
                          ),
                        if (!isUser) SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 4),
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 14),
                            decoration: BoxDecoration(
                              color: isUser ? Colors.blue[300] : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                                bottomLeft: Radius.circular(isUser ? 16 : 4),
                                bottomRight: Radius.circular(isUser ? 4 : 16),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 2,
                                  offset: Offset(1, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  data['text'] ?? '',
                                  style: TextStyle(
                                    color:
                                        isUser ? Colors.white : Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  timeLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isUser) SizedBox(width: 8),
                        if (isUser)
                          CircleAvatar(
                            backgroundColor: Colors.blue[400],
                            child: Icon(Icons.person, color: Colors.white),
                            radius: 18,
                          ),
                      ],
                    ),
                  );
                }

                return ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 10, left: 8, right: 8),
                  children: messageWidgets,
                );
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '質問を入力...',
                      filled: true,
                      fillColor: Color(0xFFF6F7FB),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue[400],
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
