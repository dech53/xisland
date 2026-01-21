import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xisland/http/dio_instance.dart';
import 'package:xisland/http/static/api.dart';
import 'package:xisland/model/cookie.dart';
import 'package:xisland/model/thread.dart';
import 'package:xisland/provider/local/cookie.dart';

//逻辑上还差得多，过段时间再改改

final threadDetailProvider = AsyncNotifierProvider.autoDispose
    .family<ThreadDetailNotifier, ThreadDetailState, int>(
      ThreadDetailNotifier.new,
    );

class ThreadDetailState {
  final Reply main;
  final List<Reply> replies;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final bool hasNext;
  final bool hasPrev;

  ThreadDetailState({
    required this.main,
    required this.replies,
    required this.totalCount,
    required this.currentPage,
    this.pageSize = 20,
  }) : hasNext = replies.length < totalCount,
       hasPrev = currentPage > 1;

  ThreadDetailState copyWith({List<Reply>? replies, int? currentPage}) {
    return ThreadDetailState(
      main: main,
      replies: replies ?? this.replies,
      totalCount: totalCount,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class ThreadDetailNotifier extends AsyncNotifier<ThreadDetailState> {
  late Cookie _mainCookie;
  final int id;

  ThreadDetailNotifier(this.id);

  @override
  FutureOr<ThreadDetailState> build() async {
    final cookies = await ref.read(cookiesProvider.future);
    _mainCookie = cookies.firstWhere(
      (c) => c.isMain,
      orElse: () => Cookie(cookie: '', name: '', isMain: false),
    );

    final firstPage = await _fetchPage(1);
    return firstPage;
  }

  Future<ThreadDetailState> _fetchPage(int page) async {
    final res = await ref
        .read(networkServiceProvider)
        .get(
          path: Api.baseUrl + Api.thread_detial,
          param: {'id': id, 'page': page, 'page_size': 20},
          options: Options(
            headers: {'Cookie': 'userhash=${_mainCookie.cookie}'},
          ),
        );

    final threadDetail = ThreadDetail.fromJson(res.data);

    return ThreadDetailState(
      main: threadDetail.main,
      replies: threadDetail.replies,
      totalCount: threadDetail.main.replyCount ?? 0,
      currentPage: page,
    );
  }

  Future<void> loadNext() async {
    if (state.value == null) return;
    final currentState = state.value!;
    if (!currentState.hasNext) return;

    final nextPage = currentState.currentPage + 1;
    final nextPageData = await _fetchPage(nextPage);

    final fetchedReplies = nextPageData.replies;
    final hasMore = fetchedReplies.length == currentState.pageSize;

    final allReplies = [
      ...currentState.replies,
      ...fetchedReplies.where(
        (r) => currentState.replies.every((e) => e.id != r.id),
      ),
    ];

    state = AsyncValue.data(
      currentState.copyWith(
        replies: allReplies,
        currentPage: hasMore ? nextPage : currentState.currentPage,
      ),
    );
  }

  Future<void> loadPrev() async {
    if (state.value == null) return;
    final currentState = state.value!;
    if (!currentState.hasPrev) return;

    final prevPage = currentState.currentPage - 1;
    final prevPageData = await _fetchPage(prevPage);

    state = AsyncValue.data(
      currentState.copyWith(
        replies: [...prevPageData.replies, ...currentState.replies],
        currentPage: prevPage,
      ),
    );
  }

  Future<void> jumpToPage(int page) async {
    state = AsyncLoading();
    final pageData = await _fetchPage(page);
    state = AsyncValue.data(pageData);
  }
}
