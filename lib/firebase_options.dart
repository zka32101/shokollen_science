// firebase_options.dart
// google-services.json (petit-works-apps-9029a) から生成
// package: com.petitworksapps.shougakukore.rika

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web is not supported');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCkIt1e0hN8K3dl7HN2CoH_h95ztkNrgmg',
    appId: '1:216377882454:android:382d9097bd5d650bd108f7',
    messagingSenderId: '216377882454',
    projectId: 'petit-works-apps-9029a',
    storageBucket: 'petit-works-apps-9029a.firebasestorage.app',
  );
}
