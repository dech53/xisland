import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xisland/http/dio_instance.dart';
import 'package:xisland/http/static/api.dart';
import 'package:xisland/model/forum_post.dart';

final postsProvider =
    AsyncNotifierProvider<ForumPostNotifier, List<ForumPost>?>(
      ForumPostNotifier.new,
    );

class ForumInfo {
  final int id;
  final bool isTimeline;
  ForumInfo({required this.id, required this.isTimeline});
}

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

  @override
  FutureOr<List<ForumPost>?> build() async {
    _page = 1;
    final forumInfo = ref.read(forumInfoProvider);

    final res = await ref
        .read(networkServiceProvider)
        .get(
          path:
              "${Api.baseUrl}${forumInfo.isTimeline ? Api.timeLinePostsUrl : Api.forumPostsUrl}",
          param: {'id': forumInfo.id, 'page': _page++},
          options: Options(
            headers: {
              'Cookie':
                  'userhash=%90q%EC%18%8EMu%C1%C5%8Dpo%209%93%F4E%10%28%18%3E%E5b6',
            },
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
              headers: {
                'Cookie':
                    'userhash=%90q%EC%18%8EMu%C1%C5%8Dpo%209%93%F4E%10%28%18%3E%E5b6',
              },
            ),
          );
      return ForumPostList.fromJson(res.data).posts;
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
            headers: {
              'Cookie':
                  'userhash=%90q%EC%18%8EMu%C1%C5%8Dpo%209%93%F4E%10%28%18%3E%E5b6',
            },
          ),
        );
    final newPosts = ForumPostList.fromJson(res.data).posts;
    if (newPosts == null) {
      return;
    }
    final oldPosts = state.value ?? [];
    state = AsyncData([...oldPosts, ...newPosts]);
  }
}
