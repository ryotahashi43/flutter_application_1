import 'package:flutter/material.dart';
import 'package:flutter_application_1/2025zen/firebase/auth_service.dart'; // AuthServiceをインポート
import 'package:flutter_application_1/2025zen/screens/home_screen.dart'; // ホーム画面へ遷移
import 'package:flutter_application_1/2025zen/screens/register_screen.dart'; // 新規登録画面をインポート

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('メールアドレスとパスワードを入力してください')),
      );
      return;
    }

    final user = await _authService.signInWithEmailPassword(email, password);
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ログイン失敗')),
      );
    }
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ログイン")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text("ログイン"),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _navigateToRegister,
              child: Text("新規登録"),
            ),
          ],
        ),
      ),
    );
  }
}
