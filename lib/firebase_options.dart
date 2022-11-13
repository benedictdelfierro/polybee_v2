// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAUDOd9dcxy_GOS0uYpS2P8aJ9Q0SfYC_0',
    appId: '1:440212825933:android:1f6f94583ef5867da23904',
    messagingSenderId: '440212825933',
    projectId: 'polybee-b7606',
    databaseURL: 'https://polybee-b7606-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'polybee-b7606.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDLnZn3P0FL6c2_lJHAa67oob347E1F-Ag',
    appId: '1:440212825933:ios:7f42d79dee010b3ca23904',
    messagingSenderId: '440212825933',
    projectId: 'polybee-b7606',
    databaseURL: 'https://polybee-b7606-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'polybee-b7606.appspot.com',
    iosClientId: '440212825933-pum808sqspvjbeb69p3tof192f1ptece.apps.googleusercontent.com',
    iosBundleId: 'com.example.polybeeV2',
  );
}
