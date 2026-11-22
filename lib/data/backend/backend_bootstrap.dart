import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../firebase_options.dart';
import 'app_backend.dart';
import 'demo_backend.dart';
import 'firebase_backend.dart';

abstract final class BackendBootstrap {
  static Future<AppBackend> create(SharedPreferences prefs) async {
    try {
      if (Firebase.apps.isEmpty) {
        try {
          await Firebase.initializeApp();
        } catch (_) {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        }
      }
      final backend = FirebaseBackend();
      await backend.initialize();
      return backend;
    } catch (_) {
      return DemoBackend(prefs);
    }
  }
}
