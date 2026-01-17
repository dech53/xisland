import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xisland/common/constants.dart';
import 'package:xisland/common/skeleton/post_card.dart';
import 'package:xisland/common/widgets/post_card.dart';
import 'package:xisland/provider/http/posts.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(postsProvider);
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(
                left: StyleString.safeSpace,
                right: StyleString.safeSpace,
              ),
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.read(postsProvider.notifier).refresh();
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        0,
                        StyleString.safeSpace,
                        0,
                        0,
                      ),
                      sliver: posts.when(
                        data: (data) {
                          if (data == null || data.isEmpty) {
                            return const SliverToBoxAdapter(
                              child: Center(child: Text('暂无帖子')),
                            );
                          }
                          return SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final isTimeLine = ref
                                  .read(forumInfoProvider)
                                  .isTimeline;
                              final post = data[index];
                              if (index == data.length - 1) {
                                ref.read(postsProvider.notifier).loadMore();
                                return PostCardSkeleton();
                              }
                              return PostCard(
                                post: post,
                                showSectionBanner: isTimeLine,
                                changeSection: (fid, isTimeline) {
                                  ref
                                      .read(postsProvider.notifier)
                                      .changeForum(
                                        newId: fid,
                                        isTimeline: isTimeline,
                                      );
                                },
                              );
                            }, childCount: data.length),
                          );
                        },
                        error: (err, _) => SliverToBoxAdapter(
                          child: Center(child: Text(err.toString())),
                        ),
                        loading: () => SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => PostCardSkeleton(),
                            childCount: 5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
