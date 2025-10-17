import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:rema_1001/page/about.dart';
import 'package:rema_1001/page/home.dart';
import 'package:rema_1001/router/route_names.dart';

final GoRouter router = GoRouter(
  initialLocation: "/",
  debugLogDiagnostics: kDebugMode,
  routes: <RouteBase>[
    ShellRoute(
      routes: [
        GoRoute(
          path: "/",
          name: RouteNames.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: "/about",
          name: RouteNames.about,
          builder: (context, state) => const AboutScreen(),
        ),
      ],
    ),
  ],
);
