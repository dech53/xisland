import 'package:flutter/material.dart';

class CustomObserver extends NavigatorObserver {
  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    debugPrint('routerobserver Popped from ${route.settings.name}');
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    debugPrint('routerobserver Pushed to ${route.settings.name}');
  }
}
