import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xisland/http/dio_instance.dart';
import 'package:xisland/http/static/api.dart';
import 'package:xisland/model/thread.dart';

class ThreadBottomBarVisibleNotifier extends Notifier<bool> {
  @override
  bool build() {
    return true;
  }

  void show() => state = true;
  void hide() => state = false;
  void toggle() => state = !state;
}

final threadBottomBarVisibleProvider =
    NotifierProvider.autoDispose<ThreadBottomBarVisibleNotifier, bool>(
      ThreadBottomBarVisibleNotifier.new,
    );

final threadQuote = NotifierProvider.autoDispose
    .family<ThreadQuoteProvider, List<Reply>, int>(ThreadQuoteProvider.new);

class ThreadQuoteProvider extends Notifier<List<Reply>> {
  int threadId;
  ThreadQuoteProvider(this.threadId);
  @override
  List<Reply> build() {
    return [];
  }

  Future<void> fetchReply(int replyId) async {
    if (state.any((r) => r.id == replyId)) return;
    try {
      final res = await ref
          .read(networkServiceProvider)
          .get(
            path: Api.baseUrl + Api.thread_detial,
            param: {'id': replyId},
            options: Options(
              headers: {
                'Cookie':
                    'userhase=LD-N%17x%11%03%10%81%C7%DER%3A%09%7E%BF%AC%3F%1F%C9%24%B6%18',
              },
            ),
          );
      final newReply = ThreadDetail.fromJson(res.data);
      newReply.main.isOuter = true;
      addReplies([newReply.main]);
    } catch (e) {
      debugPrint("获取回复失败: $e");
    }
  }

  void addReplies(List<Reply> newItems) {
    if (newItems.isEmpty) return;
    final existingIds = state.map((r) => r.id).toSet();
    final uniqueNewItems = newItems
        .where((item) => !existingIds.contains(item.id))
        .toList();
    if (uniqueNewItems.isNotEmpty) {
      state = [...state, ...uniqueNewItems];
    }
  }

  void clear() {
    state = [];
  }

  Reply? findReplyById(int id) {
    try {
      return state.firstWhere((reply) => reply.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Reply> getAll() {
    return state;
  }
}

class RefExpandedNotifier extends Notifier<bool> {
  final String key;
  RefExpandedNotifier(this.key);
  @override
  bool build() {
    return false;
  }

  void show() => state = true;
  void hide() => state = false;
  void toggle() => state = !state;
}

final refExpandedProvider = NotifierProvider.autoDispose
    .family<RefExpandedNotifier, bool, String>(RefExpandedNotifier.new);
