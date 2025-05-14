import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();

  // Firestoreのインスタンスを作成
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // メモのリストを取得する
  Future<void> _addMemo() async {
    if (_controller.text.isNotEmpty) {
      await _firestore.collection('memos').add({
        'content': _controller.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _controller.clear();
    }
  }

  // メモを削除する
  Future<void> _deleteMemo(String id) async {
    await _firestore.collection('memos').doc(id).delete();
  }

  // メモを更新する
  Future<void> _updateMemo(String id) async {
    if (_controller.text.isNotEmpty) {
      await _firestore.collection('memos').doc(id).update({
        'content': _controller.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _controller.clear();
    }
  }

  // 編集用のダイアログを表示
  void _showEditDialog(String memoId, String currentContent) {
    _controller.text = currentContent;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Memo'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: 'Edit memo'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _updateMemo(memoId);
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Memo App')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Write a memo'),
            ),
          ),
          ElevatedButton(
            onPressed: _addMemo,
            child: Text('Add Memo'),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('memos')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No memos yet.'));
                }

                final memos = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: memos.length,
                  itemBuilder: (context, index) {
                    final memo = memos[index];
                    return ListTile(
                      title: Text(memo['content']),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteMemo(memo.id),
                      ),
                      onTap: () => _showEditDialog(memo.id, memo['content']),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
