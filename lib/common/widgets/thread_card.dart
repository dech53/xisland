import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xisland/common/widgets/badge.dart';
import 'package:xisland/common/widgets/html_content.dart';
import 'package:xisland/common/widgets/network_img_layer.dart';
import 'package:xisland/http/static/api.dart';
import 'package:xisland/plugins/gallery/gallery_viewer.dart';
import 'package:xisland/plugins/gallery/hero_route.dart';
import 'package:xisland/provider/ui_data/image_wh.dart';
import 'package:xisland/utils/html_preprocessor.dart';

void onPreviewImg(List<String> picList, int initIndex, BuildContext context) {
  // context.push('/gallery?index=$initIndex', extra: picList);

  Navigator.of(context).push(
    HeroRoute(
      builder: (BuildContext context) => Material(
        child: GalleryViewer(
          sources: picList,
          initIndex: initIndex,
          onPageChanged: (int pageIndex) {},
        ),
      ),
    ),
  );
}

class ThreadCard extends StatelessWidget {
  final dynamic post;
  final bool isDetail;
  final bool isTips;
  final bool isPo;
  final int mainId;
  final bool isQuote;
  final String mainHash;
  final void Function(int, bool)? changeSection;

  const ThreadCard({
    super.key,
    required this.post,
    this.changeSection,
    this.isDetail = false,
    required this.isTips,
    required this.isPo,
    required this.mainId,
    this.isQuote = false,
    required this.mainHash,
  });

  void _onReplyLinkTap(String replyId) {
    if (isDetail && replyId.isNotEmpty) {
      print('跳转到回复: No.$replyId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: !isQuote
          ? BorderRadius.circular(10)
          : BorderRadius.circular(0),
      onTap: () {
        if (!isDetail) {
          context.push('/thread_detail/${post.id}');
        } else {}
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: !isQuote
              ? BorderRadius.circular(10)
              : BorderRadius.circular(0),
          side: !isQuote
              ? BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.5),
                  width: 1,
                )
              : BorderSide.none,
        ),
        child: Padding(
          padding: !isQuote
              ? const EdgeInsets.all(16)
              : const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    post.userHash ?? '',
                    style: TextStyle(
                      color: post.userHash == 'Admin'
                          ? Colors.red
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 6),
                  if (isPo) PBadge(text: 'Po', fs: 8, stack: "forum_name"),
                ],
              ),
              const SizedBox(height: 2),
              if (!isTips)
                Row(
                  children: [
                    Text(
                      post.now?.replaceAll(RegExp(r'\(.*?\)'), '  ') ?? '',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'No.${post.id}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              if (!isTips) ...[
                if (post.sage == 1)
                  const Text(
                    '已SAGE',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                if (post.title != '无标题')
                  Text(
                    "${post.title}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),

                const SizedBox(height: 4),
              ],
              // 富文本内容（带回复链接点击功能）
              HtmlContent(
                htmlContent: HtmlPreprocessor.preprocess(post.content),
                onReplyLinkTap: _onReplyLinkTap,
                id: post.id,
                mainId: mainId,
                mainUserHash: mainHash,
              ),
              //https://image.nmb.best/image/2025-01-15/678787a6e4cb4.jpg
              //图片内容
              if (post.img != '')
                GestureDetector(
                  onTap: () => onPreviewImg(
                    [Api.imgBestUrl + post.img! + post.ext!],
                    1,
                    context,
                  ),
                  child: Consumer(
                    builder: (context, ref, _) {
                      final imgUrl = Api.imgThumbUrl + post.img! + post.ext!;
                      final imageSizeAsync = ref.watch(
                        imageSizeProvider(imgUrl),
                      );
                      return LayoutBuilder(
                        builder: (context, boxConstraints) {
                          final maxWidth = boxConstraints.maxWidth;
                          return imageSizeAsync.when(
                            loading: () => SizedBox(
                              width: maxWidth,
                              height: 200,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            error: (_, __) => const SizedBox(),
                            data: (size) {
                              return NetworkImgLayer(
                                origWidth: size.width,
                                origHeight: size.height,
                                src: imgUrl,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              if (post.isOuter)
                TextButton(
                  onPressed: () {
                    context.push(
                      '/thread_detail/${post.id}',
                      extra: {'fid': post.fid},
                    );
                  },
                  child: Text("查看原串"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
