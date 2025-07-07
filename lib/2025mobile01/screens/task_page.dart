import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TaskPage extends StatefulWidget {
  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    double progress = 0;
    String status = '未着手';
    DateTime? selectedDate;

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
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s),
                          ))
                      .toList(),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Text(selectedDate == null
                        ? '期限なし'
                        : '期限: ${selectedDate!.toLocal().toString().split(' ')[0]}'),
                    Spacer(),
                    TextButton(
                      child: Text('日付選択'),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now().subtract(Duration(days: 1)),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    )
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

              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('tasks')
                    .add({
                  'title': title,
                  'progress': progress.round(),
                  'status': status,
                  'deadline': selectedDate != null
                      ? selectedDate!.toLocal().toString().split(' ')[0]
                      : '',
                  'timestamp': FieldValue.serverTimestamp(),
                });

                Navigator.pop(context); // 成功時に閉じる
              } catch (e) {
                print('保存エラー: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('追加に失敗しました')),
                );
              }
            },
            child: Text('追加'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('進捗管理')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('tasks')
            .orderBy('timestamp')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) return Center(child: Text('進捗タスクがありません'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index];
              return ListTile(
                title: Text(data['title']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('進捗: ${data['progress']}%'),
                    Text('ステータス: ${data['status']}'),
                    if ((data['deadline'] ?? '').isNotEmpty)
                      Text('期限: ${data['deadline']}'),
                  ],
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  // 後で編集ページに遷移させる予定
                },
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
