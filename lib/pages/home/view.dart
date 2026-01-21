import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xisland/common/constants.dart';
import 'package:xisland/common/skeleton/post_card.dart';
import 'package:xisland/common/widgets/post_card.dart';
import 'package:xisland/http/dio_instance.dart';
import 'package:xisland/model/mainforums.dart';
import 'package:xisland/provider/http/post/posts.dart';
import 'package:xisland/provider/ui/scroll_controller.dart';
import 'package:xisland/utils/storage.dart';

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
    final scrollController = ref.read(homeScrollControllerProvider);
    final posts = ref.watch(postsProvider);
    final forumInfo = ref.watch(forumInfoProvider);
    return Column(
      children: [
        AppBar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.01),
          titleSpacing: 0,
          title: Row(
            children: [
              Text(
                forumInfo.isTimeline
                    ? SPStorage.timeLines
                              .firstWhere(
                                (e) => e.id == forumInfo.id,
                                orElse: () => TimeLine(name: '未知'),
                              )
                              .name ??
                          '未知'
                    : SPStorage.forumSections
                          .firstWhere(
                            (e) => e.id == forumInfo.id,
                            orElse: () => ForumSection(id: 0, name: '未知'),
                          )
                          .name,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
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
                controller: scrollController,
                key: const PageStorageKey('home_scroll'),
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
                      error: (err, _) {
                        final message = err is ApiException
                            ? err.message
                            : '加载失败';

                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  message,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                  ),
                                ),
                                SizedBox(height: 6,),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    ref.read(postsProvider.notifier).refresh();
                                  },
                                  label: Text("重试"),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
    );
  }
}
