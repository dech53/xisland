import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:xisland/model/cookie.dart';
import 'package:xisland/provider/http/post/posts.dart';

final cookiesProvider = AsyncNotifierProvider<CookiesNotifier, List<Cookie>>(
  CookiesNotifier.new,
);

class CookiesNotifier extends AsyncNotifier<List<Cookie>> {
  @override
  Future<List<Cookie>> build() async {
    final box = await Hive.openBox<Cookie>('cookies');
    final cookies = box.isEmpty ? <Cookie>[] : box.values.toList();
    final mainCookie = cookies.firstWhere(
      (c) => c.isMain,
      orElse: () => Cookie(cookie: '', name: '', isMain: false),
    );
    if (mainCookie.cookie.isNotEmpty) {
      ref.read(postsProvider.notifier).updateMainCookie(mainCookie);
    }

    return cookies;
  }

  Future add(Cookie cookie) async {
    final current = state.value ?? [];
    final exists = current.any((c) => c.cookie == cookie.cookie);
    if (exists) return;
    final newCookie = current.isEmpty
      ? cookie.copyWith(isMain: true)
      : cookie;
      if(newCookie.isMain){
        ref
          .read(postsProvider.notifier).updateMainCookie(Cookie(cookie: newCookie.cookie, name: newCookie.name));
      }
    final updated = [...current, newCookie];
    state = AsyncData(updated);
  }

  void removeAt(int index) {
    final current = state.value ?? [];
    if (index < 0 || index >= current.length) return;

    final removed = current[index];
    final newList = List<Cookie>.from(current)..removeAt(index);

    if (newList.isNotEmpty) {
      if (removed.isMain) {
        newList[0] = newList[0].copyWith(isMain: true);
        for (var i = 1; i < newList.length; i++) {
          newList[i] = newList[i].copyWith(isMain: false);
        }
      }
    } else {
      ref
          .read(postsProvider.notifier)
          .updateMainCookie(Cookie(cookie: '', name: ''));
    }

    state = AsyncData(newList);
  }

  void setMain(int index) {
    final current = state.value ?? [];
    if (index < 0 || index >= current.length) return;
    final newList = [
      for (int i = 0; i < current.length; i++)
        current[i].copyWith(isMain: i == index),
    ];
    state = AsyncData(newList);
    ref.read(postsProvider.notifier).updateMainCookie(newList[index]);
  }

  Future<void> saveToBox() async {
    final current = state.value ?? [];
    final box = await Hive.openBox<Cookie>('cookies');
    await box.clear();
    for (var cookie in current) {
      await box.add(cookie);
    }
  }
}
