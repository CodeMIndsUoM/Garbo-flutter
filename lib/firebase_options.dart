import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase config generated from [android/app/google-services.json].
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Firebase is not configured for web.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Firebase is not supported on $defaultTargetPlatform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyApaMaE6C0lpOvkMRQN-8zPyUTBMJZWLds',
    appId: '1:1073203146993:android:35bd57b5e83416dc847950',
    messagingSenderId: '1073203146993',
    projectId: 'garbo-1fa07',
    storageBucket: 'garbo-1fa07.firebasestorage.app',
  );

  /// Placeholder until GoogleService-Info.plist is added for iOS builds.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyApaMaE6C0lpOvkMRQN-8zPyUTBMJZWLds',
    appId: '1:1073203146993:ios:0000000000000000000000',
    messagingSenderId: '1073203146993',
    projectId: 'garbo-1fa07',
    storageBucket: 'garbo-1fa07.firebasestorage.app',
    iosBundleId: 'com.garbo',
  );
}
