import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/backend/backend_bootstrap.dart';
import 'state/session_provider.dart';
import 'state/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final backend = await BackendBootstrap.create(prefs);
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        backendProvider.overrideWithValue(backend),
      ],
      child: const YouAndMeApp(),
    ),
  );
}
