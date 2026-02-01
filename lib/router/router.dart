import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xisland/pages/cookie/view.dart';
import 'package:xisland/pages/fav/view.dart';
import 'package:xisland/pages/home/view.dart';
import 'package:xisland/pages/root/view.dart';
import 'package:xisland/pages/scan/view.dart';
import 'package:xisland/pages/settings/view.dart';
import 'package:xisland/pages/thread/view.dart';
import 'package:xisland/plugins/gallery/gallery_viewer.dart';
import 'package:xisland/router/custom_observer.dart';

final rootRouter = GoRouter(
  initialLocation: '/home',
  observers: [CustomObserver()],
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return RootPage(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomePage()),
        ),
        GoRoute(
          path: '/fav',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: FavPage()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SettingsPage()),
        ),
      ],
    ),
    GoRoute(
      path: '/gallery',
      pageBuilder: (context, state) {
        final picList = state.extra as List<String>;
        final initIndex = state.uri.queryParameters['index'] != null
            ? int.parse(state.uri.queryParameters['index']!)
            : 0;

        return CustomTransitionPage(
          child: GalleryViewer(
            sources: picList,
            initIndex: initIndex,
            onPageChanged: (int pageIndex) {},
          ),
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(path: '/cookies', builder: (context, state) => CookiePage()),
    GoRoute(
      path: '/scanCode',
      pageBuilder: (context, state) => NoTransitionPage(child: ScanPage()),
    ),
    GoRoute(
      path: '/thread_detail/:id',
      builder: (context, state) {
        final idStr = state.pathParameters['id']!;
        final id = int.parse(idStr);
        final extra = state.extra as Map<String, dynamic>;
        final fid = extra['fid'] as int;
        return ThreadDetailPage(id: id, fid: fid);
      },
    ),
  ],
);
