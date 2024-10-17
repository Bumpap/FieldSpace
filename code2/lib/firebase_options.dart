// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB8HTb39DruaJy9eX-eoA4ycsqalWUp1Do',
    appId: '1:819134436103:web:60d878d04eac18f2ed6ba2',
    messagingSenderId: '819134436103',
    projectId: 'duancntt2-3d4c7',
    authDomain: 'duancntt2-3d4c7.firebaseapp.com',
    storageBucket: 'duancntt2-3d4c7.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDHxF9ff9kecVHF4aJXsG_SlAZRVN-QnK4',
    appId: '1:819134436103:android:e9ec9467e51536f0ed6ba2',
    messagingSenderId: '819134436103',
    projectId: 'duancntt2-3d4c7',
    storageBucket: 'duancntt2-3d4c7.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAq03kJshEB-_3w3cqBEX2dPEQhOWXwqdQ',
    appId: '1:819134436103:ios:6bba5dc564f5fd9ded6ba2',
    messagingSenderId: '819134436103',
    projectId: 'duancntt2-3d4c7',
    storageBucket: 'duancntt2-3d4c7.appspot.com',
    iosBundleId: 'com.example.login',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAq03kJshEB-_3w3cqBEX2dPEQhOWXwqdQ',
    appId: '1:819134436103:ios:6bba5dc564f5fd9ded6ba2',
    messagingSenderId: '819134436103',
    projectId: 'duancntt2-3d4c7',
    storageBucket: 'duancntt2-3d4c7.appspot.com',
    iosBundleId: 'com.example.login',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB8HTb39DruaJy9eX-eoA4ycsqalWUp1Do',
    appId: '1:819134436103:web:f26dffc7942ed012ed6ba2',
    messagingSenderId: '819134436103',
    projectId: 'duancntt2-3d4c7',
    authDomain: 'duancntt2-3d4c7.firebaseapp.com',
    storageBucket: 'duancntt2-3d4c7.appspot.com',
  );
}