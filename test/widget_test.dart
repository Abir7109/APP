import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:you_and_me/app.dart';
import 'package:you_and_me/data/backend/demo_backend.dart';
import 'package:you_and_me/state/session_provider.dart';
import 'package:you_and_me/state/theme_provider.dart';

Future<void> _pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final backend = DemoBackend(prefs);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        backendProvider.overrideWithValue(backend),
      ],
      child: const YouAndMeApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows setup when there is no space yet', (tester) async {
    await _pumpApp(tester);

    expect(find.text('A private space for two'), findsOneWidget);
    expect(find.text('Create a space'), findsWidgets);
    expect(find.text('Open the demo space'), findsOneWidget);
  });

  testWidgets('opens the demo space and lands on home', (tester) async {
    await _pumpApp(tester);

    final demoButton = find.text('Open the demo space');
    await tester.ensureVisible(demoButton);
    await tester.pumpAndSettle();
    await tester.tap(demoButton);
    await tester.pumpAndSettle();

    expect(find.text('Quick actions'), findsOneWidget);
    expect(find.text('Next up'), findsOneWidget);
    expect(find.text('Alex & Sam'), findsOneWidget);
  });
}
