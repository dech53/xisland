import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeScrollControllerProvider =
    NotifierProvider<HomeScrollControllerProvider, ScrollController>(
      HomeScrollControllerProvider.new,
    );

class HomeScrollControllerProvider extends Notifier<ScrollController> {
  @override
  ScrollController build() {
    final controller = ScrollController();
    ref.onDispose((){
      controller.dispose();
    });
    return controller;
  }
  void scrollToTop({Duration duration = const Duration(milliseconds: 300)}) {
    if (state.hasClients) {
      state.animateTo(
        0,
        duration: duration,
        curve: Curves.easeOut,
      );
    }
  }
}
