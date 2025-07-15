import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskPage extends StatefulWidget {
  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  bool _showCompleted = true;

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    double progress = 0;
    String status = '未着手';
    DateTime? startDate;
    DateTime? endDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('新しい目標を追加'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'タイトル'),
                ),
                SizedBox(height: 12),
                Text('進捗: ${progress.round()}%'),
                Slider(
                  value: progress,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '${progress.round()}%',
                  onChanged: (value) {
                    setState(() {
                      progress = value;
                    });
                  },
                ),
                DropdownButton<String>(
                  value: status,
                  onChanged: (value) {
                    if (value != null) setState(() => status = value);
                  },
                  items: ['未着手', '進行中', '完了']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '開始日: ${startDate != null ? DateFormat('yyyy/MM/dd').format(startDate!) : '未設定'}',
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => startDate = picked);
                      },
                      child: Text('開始日を選択'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '終了日: ${endDate != null ? DateFormat('yyyy/MM/dd').format(endDate!) : '未設定'}',
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: startDate ?? DateTime.now(),
                          firstDate: startDate ?? DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => endDate = picked);
                      },
                      child: Text('終了日を選択'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('タイトルを入力してください')),
                );
                return;
              }

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('tasks')
                  .add({
                'title': title,
                'progress': progress.round(),
                'status': status,
                'startDate': startDate != null
                    ? DateFormat('yyyy-MM-dd').format(startDate!)
                    : '',
                'endDate': endDate != null
                    ? DateFormat('yyyy-MM-dd').format(endDate!)
                    : '',
                'timestamp': FieldValue.serverTimestamp(),
              });

              Navigator.pop(context);
            },
            child: Text('追加'),
          )
        ],
      ),
    );
  }

  void _showEditTaskDialog(String docId, Map<String, dynamic> data) {
    final titleController = TextEditingController(text: data['title']);
    double progress = (data['progress'] ?? 0).toDouble();
    String status = data['status'] ?? '未着手';
    DateTime? startDate =
        data['startDate'] != '' ? DateTime.tryParse(data['startDate']) : null;
    DateTime? endDate =
        data['endDate'] != '' ? DateTime.tryParse(data['endDate']) : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('タスクを編集'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: 'タイトル')),
                SizedBox(height: 12),
                Text('進捗: ${progress.round()}%'),
                Slider(
                  value: progress,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '${progress.round()}%',
                  onChanged: (value) => setState(() => progress = value),
                ),
                DropdownButton<String>(
                  value: status,
                  onChanged: (value) {
                    if (value != null) setState(() => status = value);
                  },
                  items: ['未着手', '進行中', '完了']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '開始日: ${startDate != null ? DateFormat('yyyy/MM/dd').format(startDate!) : '未設定'}',
                    ),
                    Spacer(),
                    TextButton(
                      child: Text('開始日を選択'),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: startDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => startDate = picked);
                      },
                    )
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '終了日: ${endDate != null ? DateFormat('yyyy/MM/dd').format(endDate!) : '未設定'}',
                    ),
                    Spacer(),
                    TextButton(
                      child: Text('終了日を選択'),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: endDate ?? startDate ?? DateTime.now(),
                          firstDate: startDate ?? DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => endDate = picked);
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('削除', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('tasks')
                    .doc(docId)
                    .delete();
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('キャンセル'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text('保存'),
              onPressed: () async {
                final newTitle = titleController.text.trim();
                if (newTitle.isEmpty) return;
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('tasks')
                    .doc(docId)
                    .update({
                  'title': newTitle,
                  'progress': progress.round(),
                  'status': status,
                  'startDate': startDate != null
                      ? DateFormat('yyyy-MM-dd').format(startDate!)
                      : '',
                  'endDate': endDate != null
                      ? DateFormat('yyyy-MM-dd').format(endDate!)
                      : '',
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('進捗管理'),
        actions: [
          IconButton(
            icon:
                Icon(_showCompleted ? Icons.visibility : Icons.visibility_off),
            tooltip: _showCompleted ? '完了を非表示' : '完了を表示',
            onPressed: () {
              setState(() {
                _showCompleted = !_showCompleted;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('tasks')
            .orderBy('startDate')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs
              .where((doc) => _showCompleted || (doc['status'] ?? '') != '完了')
              .toList();

          if (docs.isEmpty) return Center(child: Text('進捗タスクがありません'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final start = data['startDate'] ?? '';
              final end = data['endDate'] ?? '';

              return ListTile(
                title: Text(data['title']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('進捗: ${data['progress']}%'),
                    Text('ステータス: ${data['status']}'),
                    if (start.isNotEmpty && end.isNotEmpty)
                      Text('期間: $start ～ $end'),
                  ],
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () => _showEditTaskDialog(doc.id, data),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _showAddTaskDialog,
      ),
    );
  }
}
