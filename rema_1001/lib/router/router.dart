import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rema_1001/page/about.dart';
import 'package:rema_1001/page/home.dart';
import 'package:rema_1001/page/map.dart';
import 'package:rema_1001/page/profile.dart';
import 'package:rema_1001/router/fade_transition_page.dart';
import 'package:rema_1001/router/nav_bar.dart';
import 'package:rema_1001/router/route_names.dart';
import 'package:rema_1001/settings/settings.dart';
import 'package:rema_1001/settings/allergies_page.dart';

final GoRouter router = GoRouter(
  initialLocation: "/home",
  debugLogDiagnostics: kDebugMode,
  routes: <RouteBase>[
    ShellRoute(
      pageBuilder: (context, state, child) => MaterialPage(
        key: state.pageKey,
        restorationId: state.pageKey.value,
        child: Scaffold(body: child, bottomNavigationBar: const RoutedNavBar()),
      ),
      routes: [
        GoRoute(
          path: "/home",
          name: RouteNames.home,
          pageBuilder: (context, state) =>
              FadeTransitionPage<void>(state: state, child: const HomeScreen()),
        ),
        GoRoute(
          path: "/trips",
          name: RouteNames.trips,
          pageBuilder: (context, state) => FadeTransitionPage<void>(
            state: state,
            child: const TripsScreen(),
          ),
        ),
        GoRoute(
          path: "/lists",
          name: RouteNames.lists,
          pageBuilder: (context, state) => FadeTransitionPage<void>(
            state: state,
            child: const ListsScreen(),
          ),
        ),
        GoRoute(
          path: "/profile",
          name: RouteNames.profile,
          pageBuilder: (context, state) => FadeTransitionPage<void>(
            state: state,
            child: const ProfileScreen(),
          ),
          routes: [
            GoRoute(
              path: "settings",
              name: RouteNames.settings,
              pageBuilder: (context, state) => FadeTransitionPage<void>(
                state: state,
                child: const Settings(),
              ),
              routes: [
                GoRoute(
                  path: "allergies",
                  name: RouteNames.allergies,
                  pageBuilder: (context, state) => FadeTransitionPage<void>(
                    state: state,
                    child: const AllergiesPage(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
