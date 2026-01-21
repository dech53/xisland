import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.01),
          centerTitle: false,
          title: Text("设置"),
        ),
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
          leading: Icon(Icons.color_lens_rounded),
          title: Text("主题选择"),
          onTap: () {},
        ),
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
          leading: Icon(Icons.cookie),
          title: Text("饼干管理"),
          onTap: () =>context.push('/cookies'),
        ),
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
          leading: Icon(Icons.settings),
          title: Text('设置'),
          onTap: () {},
        ),
      ],
    );
  }
}
