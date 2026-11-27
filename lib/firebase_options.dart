// Firebase configuration for the ThinkLab app.
// Android values come from android/app/google-services.json.
// Other platforms should be registered in the same Firebase project and added here
// via `flutterfire configure` or manual platform app registration.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCgKuQGoKYiM4-ZxqJZwUEfRPLOsWftln0',
    appId: '1:261274739006:android:b70c5243c7c0587fae4c6f',
    messagingSenderId: '261274739006',
    projectId: 'thinklab-96ba2',
    storageBucket: 'thinklab-96ba2.firebasestorage.app',
  );

  // Register an iOS app in Firebase project thinklab-96ba2 and replace these values.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCgKuQGoKYiM4-ZxqJZwUEfRPLOsWftln0',
    appId: '1:261274739006:ios:REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: '261274739006',
    projectId: 'thinklab-96ba2',
    storageBucket: 'thinklab-96ba2.firebasestorage.app',
    iosBundleId: 'com.example.thinkLab',
  );

  // Register a macOS app in Firebase project thinklab-96ba2 and replace these values.
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCgKuQGoKYiM4-ZxqJZwUEfRPLOsWftln0',
    appId: '1:261274739006:ios:REPLACE_WITH_MACOS_APP_ID',
    messagingSenderId: '261274739006',
    projectId: 'thinklab-96ba2',
    storageBucket: 'thinklab-96ba2.firebasestorage.app',
    iosBundleId: 'com.example.thinkLab',
  );

  // Register a Web app in Firebase project thinklab-96ba2 and replace these values.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCgKuQGoKYiM4-ZxqJZwUEfRPLOsWftln0',
    appId: '1:261274739006:web:REPLACE_WITH_WEB_APP_ID',
    messagingSenderId: '261274739006',
    projectId: 'thinklab-96ba2',
    storageBucket: 'thinklab-96ba2.firebasestorage.app',
    authDomain: 'thinklab-96ba2.firebaseapp.com',
  );

  // Register a Windows app in Firebase project thinklab-96ba2 and replace these values.
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCgKuQGoKYiM4-ZxqJZwUEfRPLOsWftln0',
    appId: '1:261274739006:web:REPLACE_WITH_WINDOWS_APP_ID',
    messagingSenderId: '261274739006',
    projectId: 'thinklab-96ba2',
    storageBucket: 'thinklab-96ba2.firebasestorage.app',
    authDomain: 'thinklab-96ba2.firebaseapp.com',
  );

  // Register a Linux app in Firebase project thinklab-96ba2 and replace these values.
  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyCgKuQGoKYiM4-ZxqJZwUEfRPLOsWftln0',
    appId: '1:261274739006:web:REPLACE_WITH_LINUX_APP_ID',
    messagingSenderId: '261274739006',
    projectId: 'thinklab-96ba2',
    storageBucket: 'thinklab-96ba2.firebasestorage.app',
    authDomain: 'thinklab-96ba2.firebaseapp.com',
  );
}
