import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();

  void go(String route, {Object? extra}) {
    final context = navigationKey.currentContext;
    if (context != null) {
      GoRouter.of(context).go(route, extra: extra);
    }
  }

  void push(String route, {Object? extra}) {
    final context = navigationKey.currentContext;
    if (context != null) {
      GoRouter.of(context).push(route, extra: extra);
    }
  }

  void pop<T extends Object?>([T? result]) {
    final context = navigationKey.currentContext;
    if (context != null) {
      Navigator.of(context).pop<T>(result);
    }
  }

}
