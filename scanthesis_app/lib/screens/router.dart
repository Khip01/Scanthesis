import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:scanthesis_app/screens/home/views/home_screen.dart';
import 'package:scanthesis_app/screens/settings/views/settings_screen.dart';

// for getting global context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: "/",
  routes: [
    GoRoute(
      name: RouterEnum.home.name,
      path: "/",
      pageBuilder: (_, state) {
        return buildPageWithTransition(
          state: state,
          child: const HomeScreen(),
          transitionDuration: Duration(milliseconds: 300),
          transitionType: CustomTransitionTypeEnum.fade,
        );
      },
      routes: [
        GoRoute(
          name: RouterEnum.settings.name,
          path: "settings",
          pageBuilder: (_, state) {
            return buildPageWithTransition(
              state: state,
              child: SettingsScreen(),
              transitionDuration: Duration(milliseconds: 400),
              transitionType: CustomTransitionTypeEnum.slide,
            );
          },
        ),
      ],
    ),
  ],
);

// custom transition
CustomTransitionPage buildPageWithTransition({
  required GoRouterState state,
  required Widget child,
  required Duration transitionDuration,
  required CustomTransitionTypeEnum transitionType,
}) {
  return CustomTransitionPage(
    child: child,
    transitionDuration: transitionDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      switch (transitionType) {
        case CustomTransitionTypeEnum.fade:
          return FadeTransition(opacity: animation, child: child);
        case CustomTransitionTypeEnum.slide:
          const beginOffset = Offset(1.0, 0.0);
          const endOffset = Offset.zero;
          const curve = Curves.easeOutCubic;

          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: curve,
            reverseCurve: Curves.easeInCubic,
          );

          final offsetTween = Tween<Offset>(begin: beginOffset, end: endOffset);
          final opacityTween = Tween<double>(begin: 0.0, end: 1.0);

          return SlideTransition(
            position: offsetTween.animate(curvedAnimation),
            child: FadeTransition(
              opacity: opacityTween.animate(curvedAnimation),
              child: child,
            ),
          );
      }
    },
  );
}

enum RouterEnum { home, settings }

enum CustomTransitionTypeEnum { slide, fade }
