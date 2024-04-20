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
    apiKey: 'AIzaSyBfC-4MUCzfRY00COGP1gdayakF91IXPHg',
    appId: '1:534840396002:web:458aed36a5fd1668a3f6bb',
    messagingSenderId: '534840396002',
    projectId: 'ar-interior-6d6c5',
    authDomain: 'ar-interior-6d6c5.firebaseapp.com',
    storageBucket: 'ar-interior-6d6c5.appspot.com',
    measurementId: 'G-SP9H6CZCP1',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBMEP8zyFyupQyDyc9wCKHC_Q6dHy6LVFw',
    appId: '1:534840396002:android:dfd73420540ef0bea3f6bb',
    messagingSenderId: '534840396002',
    projectId: 'ar-interior-6d6c5',
    storageBucket: 'ar-interior-6d6c5.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAhegYMPLzBFUsoMq4740C8MfPtnolXJNU',
    appId: '1:534840396002:ios:646679c5c96cc631a3f6bb',
    messagingSenderId: '534840396002',
    projectId: 'ar-interior-6d6c5',
    storageBucket: 'ar-interior-6d6c5.appspot.com',
    iosBundleId: 'com.example.seproject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAhegYMPLzBFUsoMq4740C8MfPtnolXJNU',
    appId: '1:534840396002:ios:646679c5c96cc631a3f6bb',
    messagingSenderId: '534840396002',
    projectId: 'ar-interior-6d6c5',
    storageBucket: 'ar-interior-6d6c5.appspot.com',
    iosBundleId: 'com.example.seproject',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBfC-4MUCzfRY00COGP1gdayakF91IXPHg',
    appId: '1:534840396002:web:ca3dd77d5ea26f4da3f6bb',
    messagingSenderId: '534840396002',
    projectId: 'ar-interior-6d6c5',
    authDomain: 'ar-interior-6d6c5.firebaseapp.com',
    storageBucket: 'ar-interior-6d6c5.appspot.com',
    measurementId: 'G-V9H91DQXTN',
  );

}