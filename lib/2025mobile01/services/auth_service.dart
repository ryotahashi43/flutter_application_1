import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Googleログイン
  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web対応
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final userCredential = await _auth.signInWithPopup(googleProvider);
        return userCredential.user;
      } else {
        // Android/iOS対応
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return null;

        final googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      }
    } catch (e) {
      print('Googleログイン失敗: $e');
      return null;
    }
  }

  // ログアウト
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await GoogleSignIn().signOut(); // モバイルのセッション破棄
      }
      await _auth.signOut(); // Firebaseセッション終了
    } catch (e) {
      print('ログアウト失敗: $e');
    }
  }

  // ユーザー状態監視（必要に応じて使用）
  Stream<User?> get userChanges => _auth.authStateChanges();

  // 現在のユーザーを取得
  User? get currentUser => _auth.currentUser;
}
