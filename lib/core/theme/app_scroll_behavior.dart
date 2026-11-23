import 'package:material_ui/material_ui.dart';

/// One scroll feel for the whole app: iOS-style momentum and a soft bounce on
/// touch devices, no Android stretch glow, and predictable clamping elsewhere.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    switch (getPlatform(context)) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        );
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        );
    }
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
