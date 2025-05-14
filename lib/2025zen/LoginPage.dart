import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoginMode = true; // ログイン / 新規登録 モードの切り替え

  // ログイン処理
  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ログイン成功！')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ログイン失敗: $e')),
      );
    }
  }

  // 新規登録処理
  Future<void> register() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('登録成功！')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('登録失敗: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLoginMode ? 'ログイン' : '新規登録')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'メールアドレス'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'パスワード'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoginMode ? login : register,
              child: Text(isLoginMode ? 'ログイン' : '新規登録'),
            ),
            const SizedBox(height: 20),
            // ログイン / 新規登録 モードの切り替えボタン
            TextButton(
              onPressed: () {
                setState(() {
                  isLoginMode = !isLoginMode; // モードの切り替え
                });
              },
              child: Text(isLoginMode ? '新規登録がまだの方はこちら' : 'すでにアカウントをお持ちの方はこちら'),
            ),
          ],
        ),
      ),
    );
  }
}
