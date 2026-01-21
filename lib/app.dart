import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xisland/provider/local/cookie.dart';

class AppLifecycleWatcher extends ConsumerStatefulWidget {
  final Widget child;
  const AppLifecycleWatcher({required this.child, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AppLifecycleWatcherState();
}

class _AppLifecycleWatcherState extends ConsumerState<AppLifecycleWatcher>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      await ref.read(cookiesProvider.notifier).saveToBox();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
