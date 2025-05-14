import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 新規登録
  Future<User?> registerWithEmailPassword(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // FirebaseAuthExceptionのエラーコードによって処理を分ける
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      } else {
        print("Error registering user: ${e.message}");
      }
      return null;
    } catch (e) {
      // その他の予期しないエラー
      print("Error registering user: $e");
      return null;
    }
  }

  // ログイン
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      } else {
        print("Error signing in: ${e.message}");
      }
      return null;
    } catch (e) {
      print("Error signing in: $e");
      return null;
    }
  }

  // ログアウト
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
