import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // 🔹 Web の場合
        GoogleAuthProvider googleProvider = GoogleAuthProvider();

        UserCredential userCredential =
            await _auth.signInWithPopup(googleProvider);

        return userCredential.user;
      } else {
        // 🔹 Android / iOS の場合
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      }
    } catch (e) {
      print('Googleログインエラー: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  Stream<User?> get userChanges => _auth.authStateChanges();
}
