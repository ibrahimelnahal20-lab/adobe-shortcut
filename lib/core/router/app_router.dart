import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/home_page.dart';
import '../../features/shortcuts/shortcuts_page.dart';
import '../../features/about/about_page.dart';

import '../../features/app_details/app_details_page.dart';
import '../../features/app_details/unsupported_app_page.dart';
import '../../features/bookmarks/bookmarks_page.dart';

import 'route_names.dart';
import 'route_paths.dart';
import 'not_found_page.dart';

import '../../shared/widgets/app_navbar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RoutePaths.home,
  errorBuilder: (context, state) => NotFoundPage(error: state.error),
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return AppNavbar(child: child);
      },
      routes: [
        GoRoute(
          path: RoutePaths.home,
          name: RouteNames.home,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomePage(),
          ),
        ),
        GoRoute(
          path: RoutePaths.shortcuts,
          name: RouteNames.shortcuts,
          pageBuilder: (context, state) {
            final query = state.uri.queryParameters['q'];
            return NoTransitionPage(
              key: state.pageKey,
              child: ShortcutsPage(initialSearchQuery: query),
            );
          },
        ),
        GoRoute(
          path: RoutePaths.about,
          name: RouteNames.about,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AboutPage(),
          ),
        ),
        GoRoute(
          path: RoutePaths.bookmarks,
          name: 'bookmarks',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: BookmarksPage(),
          ),
        ),
        GoRoute(
          path: RoutePaths.appDetails,
          name: RouteNames.appDetails,
          pageBuilder: (context, state) {
            final slug = state.pathParameters['slug']!;
            final query = state.uri.queryParameters['q'];

            const unsupportedApps = ['lightroom', 'acrobat', 'figma'];
            if (unsupportedApps.contains(slug)) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const UnsupportedAppPage(),
                transitionDuration: const Duration(milliseconds: 180),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: CurveTween(curve: Curves.easeOutCubic).animate(animation),
                    child: child,
                  );
                },
              );
            }

            return CustomTransitionPage(
              key: state.pageKey,
              child: AppDetailsPage(
                appSlug: slug,
                initialSearchQuery: query,
              ),
              transitionDuration: const Duration(milliseconds: 180),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: CurveTween(curve: Curves.easeOutCubic).animate(animation),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.02),
                      end: Offset.zero,
                    ).animate(CurveTween(curve: Curves.easeOutCubic).animate(animation)),
                    child: child,
                  ),
                );
              },
            );
          },
        ),
      ],
    ),
  ],
);
