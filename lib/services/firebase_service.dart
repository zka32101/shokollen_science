import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

class FirebaseService {
  static bool _initialized = false;
  static String? _userId;

  static bool get isAvailable => _initialized;
  static String? get userId => _userId;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
      final auth = FirebaseAuth.instance;
      if (auth.currentUser == null) {
        final cred = await auth.signInAnonymously();
        _userId = cred.user?.uid;
      } else {
        _userId = auth.currentUser?.uid;
      }
      debugPrint('[Firebase] 初期化成功: $_userId');
    } catch (e) {
      debugPrint('[Firebase] 初期化失敗 (ローカルモードで継続): $e');
      _initialized = false;
    }
  }
}
