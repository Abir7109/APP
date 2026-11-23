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

    expect(find.text('Bucket list'), findsOneWidget);
    expect(find.text('Photo album'), findsOneWidget);
    expect(find.text('Time capsules'), findsOneWidget);
    expect(find.text('Alex & Sam'), findsOneWidget);
  });

  testWidgets('every tab survives 320dp, dark mode, and 200% text',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
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

    final demoButton = find.text('Open the demo space');
    await tester.ensureVisible(demoButton);
    await tester.pumpAndSettle();
    await tester.tap(demoButton);
    await tester.pumpAndSettle();

    for (final icon in [
      Icons.forum_outlined,
      Icons.grid_view_outlined,
      Icons.favorite_border_rounded,
    ]) {
      await tester.tap(find.byIcon(icon));
      await tester.pumpAndSettle();
    }
  });
}
