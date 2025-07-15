import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddMemoPage extends StatefulWidget {
  @override
  _AddMemoPageState createState() => _AddMemoPageState();
}

class _AddMemoPageState extends State<AddMemoPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _saveMemo() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('タイトルまたは内容を入力してください')),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notes')
        .add({
      'title': title,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context); // メモページに戻る
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('メモを追加')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // タイトル入力欄
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'タイトル',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            SizedBox(height: 16),

            // 内容入力欄
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: '内容',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              maxLines: 10,
              minLines: 6,
              keyboardType: TextInputType.multiline,
            ),
            SizedBox(height: 24),

            // 保存ボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveMemo,
                icon: Icon(Icons.save),
                label: Text('保存する'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
