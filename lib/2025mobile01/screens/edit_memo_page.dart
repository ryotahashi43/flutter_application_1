import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditMemoPage extends StatefulWidget {
  final DocumentSnapshot note;

  EditMemoPage({required this.note});

  @override
  _EditMemoPageState createState() => _EditMemoPageState();
}

class _EditMemoPageState extends State<EditMemoPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note['title'] ?? '');
    _contentController =
        TextEditingController(text: widget.note['content'] ?? '');
  }

  Future<void> _updateMemo() async {
    await widget.note.reference.update({
      'title': _titleController.text.trim(),
      'content': _contentController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });
    Navigator.pop(context);
  }

  Future<void> _deleteMemo() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('削除の確認'),
        content: Text('このメモを削除しますか？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('キャンセル')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('削除する')),
        ],
      ),
    );

    if (confirm == true) {
      await widget.note.reference.delete();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('メモの編集'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // タイトル入力
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

            // 内容入力
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
                icon: Icon(Icons.save),
                label: Text('保存する'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  textStyle: TextStyle(fontSize: 16),
                ),
                onPressed: _updateMemo,
              ),
            ),

            SizedBox(height: 12),

            // 削除ボタン
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: Icon(Icons.delete, color: Colors.red),
                label: Text('削除する', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _deleteMemo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
