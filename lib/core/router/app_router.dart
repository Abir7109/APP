import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/album/album_screen.dart';
import '../../features/bucket/bucket_screen.dart';
import '../../features/capsules/capsules_screen.dart';
import '../../features/checkin/checkin_screen.dart';
import '../../features/chores/chores_screen.dart';
import '../../features/connect/connect_screen.dart';
import '../../features/coupons/coupons_screen.dart';
import '../../features/deep_talk/deep_talk_screen.dart';
import '../../features/goals/goals_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/more/more_screen.dart';
import '../../features/plans/plans_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/setup/setup_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/splash/splash_screen.dart';
import '../../state/session_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen<SessionState>(sessionProvider, (previous, next) {
    refresh.value++;
  });
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final location = state.matchedLocation;

      if (session.status == SessionStatus.loading) {
        return location == '/' ? null : '/';
      }
      if (session.status == SessionStatus.needsSetup) {
        return location == '/setup' ? null : '/setup';
      }
      if (location == '/' || location == '/setup') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/setup',
        builder: (context, state) => const SetupScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/plans',
                builder: (context, state) => const PlansScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/connect',
                builder: (context, state) => const ConnectScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/album',
                builder: (context, state) => const AlbumScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/more',
                builder: (context, state) => const MoreScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/bucket',
        builder: (context, state) => const BucketScreen(),
      ),
      GoRoute(
        path: '/capsules',
        builder: (context, state) => const CapsulesScreen(),
      ),
      GoRoute(
        path: '/coupons',
        builder: (context, state) => const CouponsScreen(),
      ),
      GoRoute(
        path: '/goals',
        builder: (context, state) => const GoalsScreen(),
      ),
      GoRoute(
        path: '/chores',
        builder: (context, state) => const ChoresScreen(),
      ),
      GoRoute(
        path: '/deep-talk',
        builder: (context, state) => const DeepTalkScreen(),
      ),
      GoRoute(
        path: '/check-in',
        builder: (context, state) => const CheckInScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
