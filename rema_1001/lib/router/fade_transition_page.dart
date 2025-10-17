import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Transition page that fades in over the previous page.
///
/// ### Example:
/// ```dart
/// FadeTransitionPage<void>(
///  child: const MyPage(),
///  key: state.pageKey,
///  restorationId: state.pageKey.value,
///  transitionDuration: 800.ms,
/// ),
/// ```
class FadeTransitionPage<T> extends CustomTransitionPage<T> {
  /// Constructor for a page with no transition functionality.
  FadeTransitionPage({
    required super.child,
    required GoRouterState state,
    super.name,
    super.arguments,
    super.transitionDuration = const Duration(milliseconds: 150),
    super.reverseTransitionDuration = const Duration(milliseconds: 150),
  }) : super(
          transitionsBuilder: _transitionsBuilder,
          restorationId: state.pageKey.value,
          key: state.pageKey,
        );

  static Widget _transitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return Opacity(
      opacity: animation.value,
      child: child,
    );
  }
}
