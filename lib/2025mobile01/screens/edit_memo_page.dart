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
          TextButton(
              onPressed: () => Navigator.pop(context, true),
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
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteMemo,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'タイトル'),
            ),
            SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: InputDecoration(labelText: '内容'),
                maxLines: null,
                expands: true,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updateMemo,
              child: Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
