// File manually updated for HabitHero project.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
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
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCfkWN0GvdL-A2qa1ibZARc9AMuvFiukrw',
    appId: '1:1042646575861:web:ae200b2d733bb7bbd5b3bc',
    messagingSenderId: '1042646575861',
    projectId: 'habithero-e2f63',
    authDomain: 'habithero-e2f63.firebaseapp.com',
    storageBucket: 'habithero-e2f63.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your-android-api-key',
    appId: 'your-android-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'habithero-e2f63',
    storageBucket: 'habithero-e2f63.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-ios-api-key',
    appId: 'your-ios-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'habithero-e2f63',
    storageBucket: 'habithero-e2f63.appspot.com',
    iosBundleId: 'com.example.habithero',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'your-macos-api-key',
    appId: 'your-macos-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'habithero-e2f63',
    storageBucket: 'habithero-e2f63.appspot.com',
    iosBundleId: 'com.example.habithero',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'your-windows-api-key',
    appId: 'your-windows-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'habithero-e2f63',
    storageBucket: 'habithero-e2f63.appspot.com',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'your-linux-api-key',
    appId: 'your-linux-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'habithero-e2f63',
    storageBucket: 'habithero-e2f63.appspot.com',
  );
}
