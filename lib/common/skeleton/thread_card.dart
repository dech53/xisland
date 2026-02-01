import 'package:flutter/material.dart';
import 'package:xisland/common/skeleton/skeleton.dart';

class ThreadCardSkeleton extends StatelessWidget {
  const ThreadCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget box({
      double? width,
      required double height,
      BorderRadius borderRadius = const BorderRadius.all(Radius.circular(4)),
    }) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.3),
          borderRadius: borderRadius,
        ),
      );
    }

    return Skeleton(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              box(width: 80, height: 14),
              const SizedBox(height: 6),
              Row(
                children: [
                  box(width: 120, height: 12),
                  const Spacer(),
                  box(width: 50, height: 12),
                ],
              ),
              const SizedBox(height: 8),
              box(width: 160, height: 16),
              const SizedBox(height: 12),
              box(height: 12),
              const SizedBox(height: 6),
              box(height: 12),
              const SizedBox(height: 6),
              box(width: 220, height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
