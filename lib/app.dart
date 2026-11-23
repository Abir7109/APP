import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_scroll_behavior.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_illustration.dart';
import 'features/live/live_session_host.dart';
import 'state/theme_provider.dart';

class YouAndMeApp extends ConsumerStatefulWidget {
  const YouAndMeApp({super.key});

  @override
  ConsumerState<YouAndMeApp> createState() => _YouAndMeAppState();
}

class _YouAndMeAppState extends ConsumerState<YouAndMeApp> {
  bool _precacheScheduled = false;

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'YOU&ME',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode,
      routerConfig: router,
      scrollBehavior: const AppScrollBehavior(),
      builder: (context, child) {
        if (!_precacheScheduled) {
          _precacheScheduled = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) precacheAppArt(context);
          });
        }
        final dark = Theme.of(context).brightness == Brightness.dark;
        final overlay = (dark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark)
            .copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
        );
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlay,
          child: LiveSessionHost(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
