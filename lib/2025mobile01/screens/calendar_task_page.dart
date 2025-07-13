import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalendarTaskPage extends StatefulWidget {
  @override
  State<CalendarTaskPage> createState() => _CalendarTaskPageState();
}

class _CalendarTaskPageState extends State<CalendarTaskPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now(); // 初期状態で今日を選択
  final uid = FirebaseAuth.instance.currentUser!.uid;

  String _formatDate(DateTime date) {
    return date.toLocal().toString().split(' ')[0]; // yyyy-MM-dd
  }

  @override
  Widget build(BuildContext context) {
    final selectedDateStr =
        _selectedDay != null ? _formatDate(_selectedDay!) : null;

    return Scaffold(
      appBar: AppBar(title: Text('タスクカレンダー')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            locale: 'ja_JP',
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(height: 16),
          if (_selectedDay == null)
            Expanded(child: Center(child: Text('日付を選択してください')))
          else
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('tasks')
                    .where('deadline', isEqualTo: selectedDateStr)
                    //.orderBy('timestamp')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return Center(child: Text('この日のタスクはありません'));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final status = data['status'] ?? '未着手';

                      Color tileColor;
                      switch (status) {
                        case '進行中':
                          tileColor = Colors.blue[100]!;
                          break;
                        case '完了':
                          tileColor = Colors.green[100]!;
                          break;
                        default:
                          tileColor = Colors.grey[300]!;
                      }

                      return Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: tileColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          title: Text(data['title'] ?? ''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('進捗: ${data['progress'] ?? 0}%'),
                              Text('ステータス: $status'),
                            ],
                          ),
                          onTap: () {
                            _showEditTaskDialog(docs[index].id, data);
                          },
                        ),
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

  void _showEditTaskDialog(String docId, Map<String, dynamic> data) {
    final titleController = TextEditingController(text: data['title']);
    double progress = (data['progress'] ?? 0).toDouble();
    String status = data['status'] ?? '未着手';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('タスクを編集'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'タイトル'),
            ),
            SizedBox(height: 8),
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('tasks')
                  .doc(docId)
                  .delete();
              Navigator.pop(context);
            },
            child: Text('削除', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('キャンセル'),
          ),
          ElevatedButton(
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
              });

              Navigator.pop(context);
            },
            child: Text('保存'),
          ),
        ],
      ),
    );
  }
}
