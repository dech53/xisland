import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xisland/http/dio_instance.dart';
import 'package:xisland/http/static/api.dart';
import 'package:xisland/model/cookie.dart';
import 'package:xisland/model/thread.dart';
import 'package:xisland/pages/thread/provider.dart';
import 'package:xisland/provider/local/cookie.dart';

//逻辑上还差得多，过段时间再改改

final threadDetailProvider = AsyncNotifierProvider.autoDispose
    .family<ThreadDetailNotifier, ThreadDetailState, int>(
      ThreadDetailNotifier.new,
    );

bool _isTips(Reply reply) => reply.id == 9999999;

class ThreadDetailState {
  final Reply main;
  final List<Reply> replies;
  final int replyCountFromApi;
  final int currentPage;
  final int minPage;
  final int actualPageSize;
  final bool isLoadingNext;
  final bool isLoadingPrev;
  final bool isCheckingNewReplies;
  final List<int> lastReplyIds;
  late int totalPages;
  late final bool hasNext;
  late final bool hasPrev;
  int get displayedReplyCount => replies.length;

  ThreadDetailState({
    required this.main,
    required this.replies,
    required this.replyCountFromApi,
    required this.currentPage,
    required this.minPage,
    this.actualPageSize = 19,
    this.isLoadingNext = false,
    this.isLoadingPrev = false,
    this.isCheckingNewReplies = false,
    List<int>? lastReplyIds,
  }) : lastReplyIds = lastReplyIds ?? [] {
    _recalculatePages();
  }

  void _recalculatePages() {
    totalPages = (replyCountFromApi + actualPageSize - 1) ~/ actualPageSize;
    final theoreticalRepliesOnCurrentPage =
        replyCountFromApi - (currentPage - 1) * actualPageSize;
    if (theoreticalRepliesOnCurrentPage <= 0 && replyCountFromApi > 0) {
    } else if (currentPage == totalPages &&
        replies.length <
            replyCountFromApi -
                (minPage - 1) * actualPageSize +
                (minPage - 1) * actualPageSize) {
      totalPages = totalPages + 1;
    }

    hasNext = currentPage < totalPages;
    hasPrev = minPage > 1;
  }

  ThreadDetailState copyWith({
    Reply? main,
    List<Reply>? replies,
    int? replyCountFromApi,
    int? currentPage,
    int? minPage,
    bool? isLoadingNext,
    bool? isLoadingPrev,
    bool? isCheckingNewReplies,
    List<int>? lastReplyIds,
  }) {
    final newReplies = replies ?? this.replies;
    final newReplyCount = replyCountFromApi ?? this.replyCountFromApi;

    return ThreadDetailState(
      main: main ?? this.main,
      replies: newReplies,
      replyCountFromApi: newReplyCount,
      currentPage: currentPage ?? this.currentPage,
      minPage: minPage ?? this.minPage,
      actualPageSize: actualPageSize,
      isLoadingNext: isLoadingNext ?? this.isLoadingNext,
      isLoadingPrev: isLoadingPrev ?? this.isLoadingPrev,
      isCheckingNewReplies: isCheckingNewReplies ?? this.isCheckingNewReplies,
      lastReplyIds: lastReplyIds ?? this.lastReplyIds,
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
    final actualReplies = threadDetail.replies
        .where((r) => !_isTips(r))
        .toList();
    final replyCount = threadDetail.main.replyCount ?? 0;

    final List<Reply> dataToStoreInQuote = [
      if (threadDetail.main.id != 0) threadDetail.main,
      ...actualReplies,
    ];

    ref.read(threadQuote(id).notifier).addReplies(dataToStoreInQuote);

    return ThreadDetailState(
      main: threadDetail.main,
      replies: actualReplies,
      replyCountFromApi: replyCount,
      currentPage: page,
      minPage: page,
      lastReplyIds: actualReplies.map((r) => r.id).toList(),
    );
  }

  Future<void> loadNext() async {
    if (state.value == null) return;
    final currentState = state.value!;
    if (!currentState.hasNext) return;
    if (currentState.isLoadingNext) return;

    state = AsyncValue.data(currentState.copyWith(isLoadingNext: true));

    final nextPage = currentState.currentPage + 1;
    final nextPageData = await _fetchPage(nextPage);
    final fetchedReplies = nextPageData.replies;
    final allReplies = [
      ...currentState.replies,
      ...fetchedReplies.where(
        (r) => currentState.replies.every((e) => e.id != r.id),
      ),
    ];
    final allReplyIds = allReplies.map((r) => r.id).toList();
    final updatedReplyCount = nextPageData.replyCountFromApi;
    state = AsyncValue.data(
      currentState.copyWith(
        replies: allReplies,
        replyCountFromApi: updatedReplyCount,
        currentPage: nextPage,
        isLoadingNext: false,
        lastReplyIds: allReplyIds,
      ),
    );
  }

  Future<void> loadPrev() async {
    final currentState = state.value;
    if (currentState == null) return;
    if (!currentState.hasPrev) return;
    if (currentState.isLoadingPrev) return;

    // 设置加载状态
    state = AsyncValue.data(currentState.copyWith(isLoadingPrev: true));

    try {
      final prevPage = currentState.minPage - 1;
      final prevPageData = await _fetchPage(prevPage);
      final mergedReplies = [...prevPageData.replies, ...currentState.replies];

      state = AsyncValue.data(
        currentState.copyWith(
          replies: mergedReplies,
          minPage: prevPage,
          currentPage: prevPage,
          lastReplyIds: mergedReplies.map((r) => r.id).toList(),
          isLoadingPrev: false,
        ),
      );
    } catch (e) {
      // 发生错误时也要清除加载状态
      state = AsyncValue.data(currentState.copyWith(isLoadingPrev: false));
    }
  }

  Future<bool> loadLatestReplies() async {
    final currentState = state.value;
    if (currentState == null) return false;
    if (currentState.isCheckingNewReplies) return false;

    state = AsyncValue.data(currentState.copyWith(isCheckingNewReplies: true));

    try {
      final currentTotalPages = currentState.totalPages;
      final latestPageData = await _fetchPage(currentTotalPages);
      final latestReplyIds = latestPageData.replies.map((r) => r.id).toList();
      final existingIds = Set<int>.from(currentState.lastReplyIds);
      final hasNewReplies = latestReplyIds.any(
        (id) => !existingIds.contains(id),
      );
      if (hasNewReplies) {
        final newReplies = latestPageData.replies
            .where((r) => !existingIds.contains(r.id))
            .toList();

        final mergedReplies = [...currentState.replies, ...newReplies];

        state = AsyncValue.data(
          currentState.copyWith(
            replies: mergedReplies,
            replyCountFromApi: latestPageData.replyCountFromApi,
            currentPage: currentTotalPages,
            lastReplyIds: mergedReplies.map((r) => r.id).toList(),
          ),
        );
      } else {
        state = AsyncValue.data(
          currentState.copyWith(isCheckingNewReplies: false),
        );
      }

      return hasNewReplies;
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(isCheckingNewReplies: false),
      );
      return false;
    }
  }

  Future<void> jumpToPage(int page) async {
    state = const AsyncLoading();
    final pageData = await _fetchPage(page);

    state = AsyncValue.data(pageData.copyWith(minPage: page));
  }
}
