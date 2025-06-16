import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '2025mobile01/services/firebase_options.dart';
import '2025mobile01/screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
