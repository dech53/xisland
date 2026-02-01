import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xisland/provider/http/post/posts.dart';
import 'package:xisland/provider/ui/scroll_controller.dart';
import 'package:xisland/provider/ui/settings.dart';
import 'package:xisland/utils/storage.dart';

class RootPage extends ConsumerStatefulWidget {
  const RootPage({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<RootPage> createState() => _RootPageState();
}

class _RootPageState extends ConsumerState<RootPage> {
  static const tabs = ['/home', '/fav', '/settings'];

  int _indexFromLocation(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    return tabs.indexWhere((e) => location.startsWith(e));
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final index = _indexFromLocation(context);
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                child: Text(
                  '板块',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              ExpansionTile(
                leading: const Icon(Icons.timeline),
                title: const Text("时间线"),
                children: SPStorage.timeLines.map((timeline) {
                  return ListTile(
                    title: Text(timeline.displayName ?? timeline.name ?? ''),
                    onTap: () {
                      ref
                          .read(postsProvider.notifier)
                          .changeForum(newId: timeline.id!, isTimeline: true);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
              ...SPStorage.mainForums.map((mainForums) {
                final forums = mainForums.forums ?? [];
                return ExpansionTile(
                  leading: const Icon(Icons.forum),
                  title: Text(mainForums.name ?? ''),
                  children: forums.map((forum) {
                    return ListTile(
                      title: Text(forum.name ?? ''),
                      onTap: () {
                        ref
                            .read(postsProvider.notifier)
                            .changeForum(newId: forum.id!, isTimeline: false);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          if (settings.enableGradientBg)
            Align(
              alignment: Alignment.topLeft,
              child: Opacity(
                opacity: Theme.of(context).brightness == Brightness.dark
                    ? 0.3
                    : 0.6,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.7),
                        Theme.of(context).colorScheme.surface,
                        Theme.of(
                          context,
                        ).colorScheme.surface.withValues(alpha: 0.3),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          widget.child,
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index < 0 ? 0 : index,
        onDestinationSelected: (i) {
          if (i == 0)
            ref.read(homeScrollControllerProvider.notifier).scrollToTop();
          context.go(tabs[i]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_border),
            selectedIcon: Icon(Icons.star),
            label: '收藏',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}
