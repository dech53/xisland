import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xisland/common/skeleton/thread_card.dart';
import 'package:xisland/common/widgets/e.dart';
import 'package:xisland/common/widgets/thread_card.dart';
import 'package:xisland/pages/thread/provider.dart';

class HtmlContent extends StatelessWidget {
  final String? htmlContent;
  final int id;
  final int mainId;
  final String mainUserHash;
  final Function(String replyId)? onReplyLinkTap;

  const HtmlContent({
    super.key,
    this.htmlContent,
    this.onReplyLinkTap,
    required this.id,
    required this.mainId,
    this.mainUserHash = '',
  });

  @override
  Widget build(BuildContext context) {
    return Html(
      data: htmlContent,
      onLinkTap: (String? url, Map<String, String> attributes, element) async {
        await launchUrl(Uri.parse(url!));
      },
      extensions: [
        TagExtension(
          tagsToExtend: <String>{'reply-link'},
          builder: (extensionContext) {
            final ids = extensionContext.styledElement?.attributes['id'] ?? '';
            final colorStr =
                extensionContext.styledElement?.attributes['color'] ??
                '#789922';
            final color = _parseColor(colorStr);

            final int? replyId = int.tryParse(ids);

            return Consumer(
              builder: (context, ref, _) {
                ref.watch(threadQuote(mainId));
                final notifier = ref.read(threadQuote(mainId).notifier);

                Widget expandedChild;

                if (replyId == null) {
                  expandedChild = const Text("Invalid ID");
                } else {
                  final reply = notifier.findReplyById(replyId);
                  if (reply == null) {
                    notifier.fetchReply(replyId);
                    expandedChild = const Center(child: ThreadCardSkeleton());
                  } else {
                    expandedChild = ThreadCard(
                      isQuote: true,
                      post: reply,
                      isTips: false,
                      isPo: reply.userHash == mainUserHash,
                      mainId: mainId,
                      isDetail: true,
                      mainHash: mainUserHash,
                    );
                  }
                }

                return ExpandableRef(
                  key: ValueKey('ref-$id-$ids'),
                  parentId: id,
                  refId: ids,
                  collapsed: Text(
                    '>>No.$ids',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                  expanded: InputDecorator(
                    decoration: InputDecoration(
                      isDense: true,
                      label: Text(
                        'No.$ids',
                        style: const TextStyle(
                          color: Color(0xFF789922),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF789922),
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: expandedChild,
                  ),
                );
              },
            );
          },
        ),
      ],
      style: {
        "body": Style(
          fontSize: FontSize(14),
          color: Colors.black87,
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
        ),
      },
    );
  }

  Color _parseColor(String colorStr) {
    try {
      // 处理 #RRGGBB 格式
      if (colorStr.startsWith('#')) {
        final hex = colorStr.substring(1);
        if (hex.length == 6) {
          return Color(int.parse('FF$hex', radix: 16));
        } else if (hex.length == 8) {
          return Color(int.parse(hex, radix: 16));
        }
      }
      // 处理其他格式的颜色...
      return Colors.blue;
    } catch (e) {
      return Colors.blue;
    }
  }
}
