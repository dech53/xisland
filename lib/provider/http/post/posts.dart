import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xisland/http/dio_instance.dart';
import 'package:xisland/http/static/api.dart';
import 'package:xisland/model/cookie.dart';
import 'package:xisland/model/forum_post.dart';
import 'package:xisland/provider/local/cookie.dart';

class ForumInfo {
  final int id;
  final bool isTimeline;
  ForumInfo({required this.id, required this.isTimeline});
}

final postsProvider =
    AsyncNotifierProvider<ForumPostNotifier, List<ForumPost>?>(
      ForumPostNotifier.new,
    );

final forumInfoProvider = NotifierProvider<ForumInfoNotifier, ForumInfo>(
  ForumInfoNotifier.new,
);

class ForumInfoNotifier extends Notifier<ForumInfo> {
  @override
  ForumInfo build() => ForumInfo(id: 1, isTimeline: true);

  void change({required int newId, required bool isTimeline}) {
    state = ForumInfo(id: newId, isTimeline: isTimeline);
  }
}

class ForumPostNotifier extends AsyncNotifier<List<ForumPost>?> {
  int _page = 1;
  late Cookie _mainCookie;

  @override
  FutureOr<List<ForumPost>?> build() async {
    _page = 1;
    final forumInfo = ref.read(forumInfoProvider);
    final cookies = await ref.read(cookiesProvider.future);
    _mainCookie = cookies.firstWhere(
      (c) => c.isMain,
      orElse: () => Cookie(cookie: '', name: '', isMain: false),
    );
    final res = await ref
        .read(networkServiceProvider)
        .get(
          path:
              "${Api.baseUrl}${forumInfo.isTimeline ? Api.timeLinePostsUrl : Api.forumPostsUrl}",
          param: {'id': forumInfo.id, 'page': _page++},
          options: Options(
            headers: {'Cookie': 'userhash=${_mainCookie.cookie}'},
          ),
        );
    final posts = ForumPostList.fromJson(res.data).posts;
    return posts;
  }

  Future<void> changeForum({
    required int newId,
    required bool isTimeline,
  }) async {
    final forumInfoNotifier = ref.read(forumInfoProvider.notifier);
    final forumInfo = ref.read(forumInfoProvider);
    if (newId == forumInfo.id && isTimeline == forumInfo.isTimeline) return;
    forumInfoNotifier.change(newId: newId, isTimeline: isTimeline);
    await refresh();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _page = 1;
      final forumInfo = ref.read(forumInfoProvider);
      final res = await ref
          .read(networkServiceProvider)
          .get(
            path:
                "${Api.baseUrl}${forumInfo.isTimeline ? Api.timeLinePostsUrl : Api.forumPostsUrl}",
            param: {'id': forumInfo.id, 'page': _page++},
            options: Options(
              headers: {'Cookie': 'userhash=${_mainCookie.cookie}'},
            ),
          );
      final data = res.data;
      if (data is Map<String, dynamic>) {
        if (data['success'] == false) {
          throw ApiException(data['error'] ?? '未知错误');
        } else {
          throw ApiException('接口返回异常');
        }
      }

      if (data is List) {
        return ForumPostList.fromJson(data).posts ?? [];
      }

      throw ApiException('无法识别的返回数据');
    });
  }

  Future loadMore() async {
    final forumInfo = ref.read(forumInfoProvider);
    final res = await ref
        .read(networkServiceProvider)
        .get(
          path:
              "${Api.baseUrl}${forumInfo.isTimeline ? Api.timeLinePostsUrl : Api.forumPostsUrl}",
          param: {'id': forumInfo.id, 'page': _page++},
          options: Options(
            headers: {'Cookie': 'userhash=${_mainCookie.cookie}'},
          ),
        );
    final newPosts = ForumPostList.fromJson(res.data).posts;
    if (newPosts == null) {
      return;
    }
    final oldPosts = state.value ?? [];
    state = AsyncData([...oldPosts, ...newPosts]);
  }

  void updateMainCookie(Cookie mainCookie) {
    _mainCookie = mainCookie;
    debugPrint('修改后的maincookie是${_mainCookie.name}');
  }
}
