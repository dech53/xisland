import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:xisland/common/constants.dart';
import 'package:xisland/common/skeleton/thread_card.dart';
import 'package:xisland/common/widgets/thread_card.dart';
import 'package:xisland/pages/thread/provider.dart';
import 'package:xisland/provider/http/post/post_detail.dart';
import 'package:xisland/provider/ui/settings.dart';
import 'package:xisland/utils/storage.dart';

class ThreadDetailPage extends ConsumerStatefulWidget {
  final int id;
  final int fid;
  const ThreadDetailPage({super.key, required this.id, required this.fid});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ThreadDetailPageState();
}

class _ThreadDetailPageState extends ConsumerState<ThreadDetailPage> with AutomaticKeepAliveClientMixin{
  final ScrollController _scrollController = ScrollController();
  bool _hasShownNoNewReplies = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _hasShownNoNewReplies = false;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    final direction = position.userScrollDirection;
    final bottomBarNotifier = ref.read(threadBottomBarVisibleProvider.notifier);

    if (direction == ScrollDirection.reverse) {
      bottomBarNotifier.hide();
    } else if (direction == ScrollDirection.forward) {
      bottomBarNotifier.show();
    }
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(threadDetailProvider(widget.id).notifier).loadNext();
    }
  }


  Future<int?> _showJumpPageDialog({
    required BuildContext context,
    required int currentPage,
    required int totalPages,
  }) {
    final controller = TextEditingController(text: currentPage.toString());

    return SmartDialog.show<int?>(
      builder: (_) {
        return AlertDialog(
          title: const Text('跳页'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    tooltip: '首页',
                    icon: const Icon(Icons.first_page),
                    onPressed: currentPage > 1
                        ? () => SmartDialog.dismiss(result: 1)
                        : null,
                  ),
                  IconButton(
                    tooltip: '上一页',
                    icon: const Icon(Icons.chevron_left),
                    onPressed: currentPage > 1
                        ? () => SmartDialog.dismiss(result: currentPage - 1)
                        : null,
                  ),
                  SizedBox(
                    width: 70,
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '页数',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('/ $totalPages'),
                  IconButton(
                    tooltip: '下一页',
                    icon: const Icon(Icons.chevron_right),
                    onPressed: currentPage < totalPages
                        ? () => SmartDialog.dismiss(result: currentPage + 1)
                        : null,
                  ),
                  IconButton(
                    tooltip: '尾页',
                    icon: const Icon(Icons.last_page),
                    onPressed: currentPage < totalPages
                        ? () => SmartDialog.dismiss(result: totalPages)
                        : null,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => SmartDialog.dismiss(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                final page = int.tryParse(controller.text);
                if (page != null && page >= 1 && page <= totalPages) {
                  SmartDialog.dismiss(result: page);
                }
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final settings = ref.watch(settingsProvider);
    final threadDetail = ref.watch(threadDetailProvider(widget.id));
    final quoteProvider = ref.watch(threadQuote(widget.id));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.42),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                context.pop();
              },
              icon: Icon(Icons.arrow_back_ios),
            ),
            Text(
              "${SPStorage.forumSections.firstWhere((section) => section.id == widget.fid).name} · ${widget.id}",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          if (settings.enableGradientBg)
            Align(
              alignment: Alignment.topLeft,
              child: Opacity(
                opacity: Theme.of(context).brightness == Brightness.dark
                    ? 0.3
                    : 0.6,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.7),
                        Theme.of(context).colorScheme.surface,
                        Theme.of(
                          context,
                        ).colorScheme.surface.withValues(alpha: 0.3),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          threadDetail.when(
            data: (threadState) {
              return _ThreadContent(
                threadState: threadState,
                scrollController: _scrollController,
                onLoadPrev: () {
                  ref.read(threadDetailProvider(widget.id).notifier).loadPrev();
                  _hasShownNoNewReplies = false;
                },
                onLoadLatest: () {
                  _hasShownNoNewReplies = false;
                  return ref
                      .read(threadDetailProvider(widget.id).notifier)
                      .loadLatestReplies();
                },
                hasShownNoNewReplies: _hasShownNoNewReplies,
                onNoNewRepliesShown: () {
                  _hasShownNoNewReplies = true;
                },
              );
            },
            loading: () => const ThreadLoadingView(),
            error: (e, _) => Text(e.toString()),
          ),
        ],
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutExpo,
        height: 86,
        child: BottomAppBar(
          shape: CircularNotchedRectangle(),
          child: Row(
            children: [
              IconButton(
                tooltip: '收藏',
                onPressed: () {},
                icon: Icon(Icons.favorite_border),
              ),
              IconButton(
                tooltip: '跳页',
                icon: const Icon(Icons.move_down),
                onPressed: () async {
                  final state = ref.read(threadDetailProvider(widget.id)).value;
                  if (state == null) return;

                  final targetPage = await _showJumpPageDialog(
                    context: context,
                    currentPage: state.currentPage,
                    totalPages: state.totalPages,
                  );

                  if (targetPage == null || targetPage == state.currentPage)
                    return;
                  await ref
                      .read(threadDetailProvider(widget.id).notifier)
                      .jumpToPage(targetPage);

                  _hasShownNoNewReplies = false;
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(0);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        tooltip: '回复',
        child: Icon(Icons.create),
        onPressed: () {},
      ),
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}

class _ThreadContent extends StatelessWidget {
  final ThreadDetailState threadState;
  final ScrollController scrollController;
  final VoidCallback onLoadPrev;
  final Future<bool> Function() onLoadLatest;
  final bool hasShownNoNewReplies;
  final VoidCallback onNoNewRepliesShown;

  const _ThreadContent({
    required this.threadState,
    required this.scrollController,
    required this.onLoadPrev,
    required this.onLoadLatest,
    required this.hasShownNoNewReplies,
    required this.onNoNewRepliesShown,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            StyleString.safeSpace,
            StyleString.safeSpace,
            StyleString.safeSpace,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: ThreadCard(
              mainHash: threadState.main.userHash,
              mainId: threadState.main.id,
              post: threadState.main,
              isDetail: true,
              isTips: threadState.main.id == 9999999,
              isPo: true,
            ),
          ),
        ),
        if (threadState.minPage > 1) ...[_buildLoadPrevButton(context)],
        _buildRepliesList(),
        if (threadState.isLoadingNext) _buildLoadingIndicator(),
        _buildBottomArea(context),
        SliverToBoxAdapter(child: SizedBox(height: StyleString.safeSpace)),
      ],
    );
  }

  Widget _buildLoadPrevButton(BuildContext context) {
    if (threadState.isLoadingPrev) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            StyleString.safeSpace,
            StyleString.safeSpace / 2,
            StyleString.safeSpace,
            0,
          ),
          child: const ThreadCardSkeleton(),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, StyleString.safeSpace / 2, 0, 0),
        child: Center(
          child: ElevatedButton.icon(
            onPressed: onLoadPrev,
            icon: const Icon(Icons.arrow_upward),
            label: Text('加载第${threadState.minPage - 1}页及之前的回复'),
          ),
        ),
      ),
    );
  }

  Widget _buildRepliesList() {
    if (threadState.replies.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(padding: EdgeInsets.all(24), child: Text('暂无回复')),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final reply = threadState.replies[index];
        return Padding(
          padding: EdgeInsets.fromLTRB(
            StyleString.safeSpace,
            index == 0 ? 8 : 4,
            StyleString.safeSpace,
            4,
          ),
          child: ThreadCard(
            mainHash: threadState.main.userHash,
            mainId: threadState.main.id,
            post: reply,
            isDetail: true,
            isTips: reply.id == 9999999,
            isPo: reply.userHash == threadState.main.userHash,
          ),
        );
      }, childCount: threadState.replies.length),
    );
  }

  Widget _buildLoadingIndicator() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: const ThreadCardSkeleton(),
      ),
    );
  }

  Widget _buildBottomArea(BuildContext context) {
    final canLoadLatest = threadState.currentPage >= threadState.totalPages;

    if (!canLoadLatest) {
      return const SliverToBoxAdapter();
    }

    if (threadState.isCheckingNewReplies) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ThreadCardSkeleton(),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: OutlinedButton.icon(
            onPressed: () async {
              final hasNew = await onLoadLatest();
              if (!hasNew) {
                onNoNewRepliesShown();
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('尝试加载新回复'),
          ),
        ),
      ),
    );
  }
}

class ThreadLoadingView extends StatelessWidget {
  const ThreadLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            StyleString.safeSpace,
            StyleString.safeSpace,
            StyleString.safeSpace,
            0,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => const ThreadCardSkeleton(),
              childCount: 4,
            ),
          ),
        ),
      ],
    );
  }
}
