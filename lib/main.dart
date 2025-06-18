import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart'; // ← 追加
import '2025mobile01/services/firebase_options.dart';
import '2025mobile01/screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🌐 日本語ローカライズ初期化（他のロケールに変える場合は 'en' など指定）
  await initializeDateFormatting('ja'); // ← ここ追加！

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '学習アシスタント',
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
