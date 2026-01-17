import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:xisland/common/widgets/badge.dart';
import 'package:xisland/common/widgets/circle_icon.dart';
import 'package:xisland/common/widgets/html_content.dart';
import 'package:xisland/common/widgets/network_img_layer.dart';
import 'package:xisland/http/static/api.dart';
import 'package:xisland/model/forum_post.dart';
import 'package:xisland/plugins/gallery/gallery_viewer.dart';
import 'package:xisland/plugins/gallery/hero_route.dart';
import 'package:xisland/provider/ui_data/image_wh.dart';
import 'package:xisland/utils/storage.dart';

void onPreviewImg(picList, initIndex, context) {
  Navigator.of(context).push(
    HeroRoute<void>(
      builder: (BuildContext context) => Material(
        color: Colors.transparent,
        child: GalleryViewer(
          sources: picList,
          initIndex: initIndex,
          onPageChanged: (int pageIndex) {},
        ),
      ),
    ),
  );
}

class PostCard extends StatelessWidget {
  final ForumPost post;
  final bool showSectionBanner;
  final void Function(int, bool)? changeSection;

  const PostCard({
    super.key,
    required this.post,
    required this.showSectionBanner,
    this.changeSection,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.userHash ?? '',
                style: TextStyle(
                  color: post.userHash == 'Admin' ? Colors.red : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    post.now?.replaceAll(RegExp(r'\(.*?\)'), '  ') ?? '',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    'No.${post.id}',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                ],
              ),
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
              //富文本内容
              SelectionArea(child: HtmlContent(htmlContent: post.content)),
              //https://image.nmb.best/image/2025-01-15/678787a6e4cb4.jpg
              //图片内容
              if (post.img != '')
                Hero(
                  tag: Api.imgBestUrl + post.img! + post.ext!,
                  child: GestureDetector(
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
                ),
              const SizedBox(height: 8),
              if (showSectionBanner) ...[
                PBadge(
                  text: SPStorage.forumSections
                      .firstWhere((section) => section.id == post.fid)
                      .name,
                  type: 'line',
                  fs: 14,
                  stack: "forum_name",
                  outerPadding: EdgeInsets.all(2),
                  onTap: () {
                    if (changeSection != null) {
                      changeSection!(post.fid!, false);
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
              //操作项
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleIcon(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.2),
                        icon: Icons.more_vert_outlined,
                      ),
                      const SizedBox(width: 6),
                      CircleIcon(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.2),
                        icon: Icons.share,
                        onTap: () {
                          SharePlus.instance.share(
                            ShareParams(
                              text: "https://www.nmbxd1.com/t/${post.id}",
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      CircleIcon(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.2),
                        icon: Icons.star_border_outlined,
                      ),
                      const SizedBox(width: 6),
                      CircleIcon(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.2),
                        icon: Icons.message,
                        notice: post.reaminReplies,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
