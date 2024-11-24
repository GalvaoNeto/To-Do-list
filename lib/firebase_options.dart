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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAyJSZC7mmrsFk_RiYYCVM3VkY1kjwPMZ4',
    appId: '1:860674975440:web:85ea44a9b051c4891060d5',
    messagingSenderId: '860674975440',
    projectId: 'todo-list-1de33',
    authDomain: 'todo-list-1de33.firebaseapp.com',
    storageBucket: 'todo-list-1de33.firebasestorage.app',
    measurementId: 'G-1DFCKTCWKF',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAsFIK8Jp2B96yqpyQSM-pDdJzwDOiX7kc',
    appId: '1:860674975440:android:039c6ebf6996ac391060d5',
    messagingSenderId: '860674975440',
    projectId: 'todo-list-1de33',
    storageBucket: 'todo-list-1de33.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBrQEvmtxELW4qIR4a6S_FDO_7tGq4IW3U',
    appId: '1:860674975440:ios:656ee77d8ccfd2fc1060d5',
    messagingSenderId: '860674975440',
    projectId: 'todo-list-1de33',
    storageBucket: 'todo-list-1de33.firebasestorage.app',
    iosBundleId: 'com.example.toDoList',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAyJSZC7mmrsFk_RiYYCVM3VkY1kjwPMZ4',
    appId: '1:860674975440:web:a63898f4857840d41060d5',
    messagingSenderId: '860674975440',
    projectId: 'todo-list-1de33',
    authDomain: 'todo-list-1de33.firebaseapp.com',
    storageBucket: 'todo-list-1de33.firebasestorage.app',
    measurementId: 'G-7R4ZSC05XB',
  );

}