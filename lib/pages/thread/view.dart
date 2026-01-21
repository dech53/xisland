import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xisland/common/skeleton/post_card.dart';
import 'package:xisland/common/widgets/html_content.dart';
import 'package:xisland/provider/http/post/post_detail.dart';

class ThreadDetailPage extends ConsumerStatefulWidget {
  final int id;
  const ThreadDetailPage({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ThreadDetailPageState();
}

class _ThreadDetailPageState extends ConsumerState<ThreadDetailPage> {
  @override
  Widget build(BuildContext context) {
    final threadDetail = ref.watch(threadDetailProvider(widget.id));
    final threadDetailNotifier = ref.read(
      threadDetailProvider(widget.id).notifier,
    );
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          threadDetailNotifier.jumpToPage(2);
        },
      ),
      body: threadDetail.when(
        data: (threadState) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: threadState.replies.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        title: HtmlContent(
                          htmlContent: threadState.main.content,
                        ),
                        subtitle: Text('${threadState.main.userHash}'),
                      );
                    }
                    if (index ==
                        threadState.replies.length +
                            1 -
                            threadState.currentPage) {
                      threadDetailNotifier.loadNext();
                      return PostCardSkeleton();
                    }
                    final reply = threadState.replies[index - 1];
                    return ListTile(
                      title: HtmlContent(htmlContent: reply.content),
                      subtitle: Text('${reply.userHash}'),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
