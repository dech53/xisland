import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

class NetworkImgLayer extends StatelessWidget {
  const NetworkImgLayer({
    super.key,
    required this.src,
    this.origWidth,
    this.origHeight,
    this.type,
    this.quality,
    this.maxWidth,
    this.useOrig = false,
  });

  final String src;
  final double? origWidth;
  final double? origHeight;
  final String? type;
  final int? quality;
  final double? maxWidth;
  final bool useOrig;

  @override
  Widget build(BuildContext context) {
    if (src.isEmpty) return placeholder(context);
    final double containerMaxWidth =
        maxWidth ?? MediaQuery.of(context).size.width - 32;
    double displayWidth = origWidth ?? containerMaxWidth;
    double displayHeight = origHeight ?? (displayWidth * 9 / 16);
    if (displayWidth > containerMaxWidth) {
      displayHeight = displayHeight * (containerMaxWidth / displayWidth);
      displayWidth = containerMaxWidth;
    }
    displayHeight = displayHeight.clamp(80.0, 400.0);
    int memCacheWidth = (displayWidth * MediaQuery.of(context).devicePixelRatio)
        .round();
    int memCacheHeight =
        (displayHeight * MediaQuery.of(context).devicePixelRatio).round();
    if (src.contains('/thumb/') && !useOrig) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(StyleString.imgRadius.x),
        child: CachedNetworkImage(
          imageUrl: src,
          width: displayWidth,
          height: displayHeight,
          memCacheWidth: memCacheWidth,
          memCacheHeight: memCacheHeight,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          fadeOutDuration: const Duration(milliseconds: 120),
          fadeInDuration: const Duration(milliseconds: 120),
          filterQuality: FilterQuality.low,
          placeholder: (context, url) => placeholder(context),
          errorWidget: (context, url, error) => placeholder(context),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(StyleString.imgRadius.x),
        child: CachedNetworkImage(
          imageUrl: src,
          width: containerMaxWidth,
          fit: BoxFit.fitWidth,
          alignment: Alignment.center,
          fadeOutDuration: const Duration(milliseconds: 120),
          fadeInDuration: const Duration(milliseconds: 120),
          filterQuality: FilterQuality.low,
          placeholder: (context, url) => placeholder(context),
          errorWidget: (context, url, error) => placeholder(context),
        ),
      );
    }
  }

  Widget placeholder(BuildContext context) {
    return Container(
      width: maxWidth ?? MediaQuery.of(context).size.width,
      height: 200,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.onInverseSurface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(
          type == 'avatar'
              ? 50
              : type == 'emote'
              ? 0
              : StyleString.imgRadius.x,
        ),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
