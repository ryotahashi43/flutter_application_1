import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ← ★追加
import 'package:intl/date_symbol_data_local.dart';
import '2025mobile01/services/firebase_options.dart';
import '2025mobile01/screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('ja'); // ← 日付フォーマットの日本語化

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '学習アシスタント',
      debugShowCheckedModeBanner: false,
      locale: Locale('ja'), // ← ★アプリ全体のロケールを日本語に設定
      supportedLocales: const [
        Locale('ja'), // ← 日本語をサポート
        Locale('en'), // ← 英語も必要なら
      ],
      localizationsDelegates: const [
        // ← ★ローカライズの各種デリゲート
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: LoginPage(),
    );
  }
}
