import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazy_load_indexed_stack/lazy_load_indexed_stack.dart';
import 'package:xisland/model/mainforums.dart';
import 'package:xisland/pages/fav/view.dart';
import 'package:xisland/pages/home/view.dart';
import 'package:xisland/pages/settings/view.dart';
import 'package:xisland/provider/http/posts.dart';
import 'package:xisland/provider/ui/settings.dart';
import 'package:xisland/utils/storage.dart';

class RootPage extends ConsumerStatefulWidget {
  const RootPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RootPageState();
}

class _RootPageState extends ConsumerState<RootPage>
    with AutomaticKeepAliveClientMixin {
  int _index = 0;
  @override
  void dispose() async {
    await SPStorage.close();
    super.dispose();
  }

  List rootApp = [
    {
      "selectedIcon": Icons.home,
      "unSelectedIcon": Icons.home_outlined,
      "text": "首页",
    },
    {
      "selectedIcon": Icons.star,
      "unSelectedIcon": Icons.star_border,
      "text": "收藏",
    },
    {
      "selectedIcon": Icons.settings,
      "unSelectedIcon": Icons.settings_outlined,
      "text": "设置",
    },
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final settings = ref.watch(settingsProvider);
    final forumInfo = ref.watch(forumInfoProvider);
    return Scaffold(
      extendBody: false,
      appBar: AppBar(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.40),
        titleSpacing: 0, 
        title: Row(
          children: [
            Text(
              forumInfo.isTimeline
                  ? SPStorage.timeLines
                            .firstWhere(
                              (e) => e.id == forumInfo.id,
                              orElse: () => TimeLine(name: '未知'),
                            )
                            .name ??
                        '未知'
                  : SPStorage.forumSections
                        .firstWhere(
                          (e) => e.id == forumInfo.id,
                          orElse: () => ForumSection(id: 0, name: '未知'),
                        )
                        .name,
              style: TextStyle(
                fontSize: 18
              ),
            ),
          ],
        ),
      ),
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
                title: Text("时间线"),
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
                      title: Text(
                         forum.name ?? '',
                      ),
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
          LazyLoadIndexedStack(
            index: _index,
            children: [HomePage(), FavPage(), SettingsPage()],
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (value) => setState(() {
          _index = value;
        }),
        selectedIndex: _index,
        destinations: <Widget>[
          ...rootApp.map((e) {
            return NavigationDestination(
              icon: Icon(e['unSelectedIcon']),
              label: e['text'],
              selectedIcon: Icon(e['selectedIcon']),
            );
          }),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
