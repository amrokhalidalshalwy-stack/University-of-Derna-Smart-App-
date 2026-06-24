// Generated-style Firebase options for all platforms.
// Regenerate with FlutterFire CLI when you add/rotate apps:
//   dart pub global activate flutterfire_cli
//   dart run flutterfire_cli:flutterfire configure
//
// Android values match android/app/google-services*.json.
// Web values match the former inline configuration in main.dart.
// iOS/macOS: update appId when you register iOS/macOS apps in Firebase Console.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with `Firebase.initializeApp`.
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
          'DefaultFirebaseOptions have not been configured for Linux — '
          'run `flutterfire configure` or add Linux app in Firebase Console.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD3DgB4P3j-Jnqvr-epfcpelKQwF40Y690',
    appId: '1:77238783156:web:a6ba467547320aef32dbe1',
    messagingSenderId: '77238783156',
    projectId: 'smart-college-app-442cd',
    authDomain: 'smart-college-app-442cd.firebaseapp.com',
    storageBucket: 'smart-college-app-442cd.firebasestorage.app',
    measurementId: 'G-7B4MRK0GCV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCAvEza5-1cR5eVGV6YtbuwDT1uTwNXvcM',
    appId: '1:77238783156:android:94d7b4c1a454a01e32dbe1',
    messagingSenderId: '77238783156',
    projectId: 'smart-college-app-442cd',
    storageBucket: 'smart-college-app-442cd.firebasestorage.app',
  );

  /// Replace with real iOS app id from Firebase Console / `flutterfire configure`
  /// when you add `GoogleService-Info.plist`.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCAvEza5-1cR5eVGV6YtbuwDT1uTwNXvcM',
    appId: '1:77238783156:ios:94d7b4c1a454a01e32dbe1',
    messagingSenderId: '77238783156',
    projectId: 'smart-college-app-442cd',
    storageBucket: 'smart-college-app-442cd.firebasestorage.app',
    iosBundleId: 'com.uod.smartapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCAvEza5-1cR5eVGV6YtbuwDT1uTwNXvcM',
    appId: '1:77238783156:ios:94d7b4c1a454a01e32dbe1',
    messagingSenderId: '77238783156',
    projectId: 'smart-college-app-442cd',
    storageBucket: 'smart-college-app-442cd.firebasestorage.app',
    iosBundleId: 'com.uod.smartapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD3DgB4P3j-Jnqvr-epfcpelKQwF40Y690',
    appId: '1:77238783156:web:a6ba467547320aef32dbe1',
    messagingSenderId: '77238783156',
    projectId: 'smart-college-app-442cd',
    authDomain: 'smart-college-app-442cd.firebaseapp.com',
    storageBucket: 'smart-college-app-442cd.firebasestorage.app',
  );
}
