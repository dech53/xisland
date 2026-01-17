import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavPage extends ConsumerStatefulWidget {
  const FavPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FavPageState();
}

class _FavPageState extends ConsumerState<FavPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Fav"),
    );
  }
}
