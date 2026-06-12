import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:garbo_swms/core/services/firebase_messaging_service.dart';
import 'package:garbo_swms/firebase_options.dart';

/// Whether Firebase native plugins initialized successfully this session.
bool isFirebaseAvailable = false;

/// Initializes Firebase and FCM background handler.
///
/// Returns false when native plugins are unavailable (e.g. after hot restart
/// before a full rebuild). The app can still run with API-only notifications.
Future<bool> bootstrapFirebase() async {
  try {
    if (Firebase.apps.isNotEmpty) {
      isFirebaseAvailable = true;
      return true;
    }

    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    isFirebaseAvailable = true;
    return true;
  } on UnsupportedError catch (e) {
    debugPrint('Firebase not supported on this platform: $e');
    return false;
  } catch (e, st) {
    debugPrint(
      'Firebase initialization failed — push notifications disabled. '
      'Stop the app and run `flutter run` (not hot restart) after adding Firebase.\n'
      '$e\n$st',
    );
    return false;
  }
}
