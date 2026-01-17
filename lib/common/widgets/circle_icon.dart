import 'package:flutter/material.dart';
import 'package:xisland/common/widgets/badge.dart';

class CircleIcon extends StatelessWidget {
  final Color color;
  final IconData icon;
  final double size;
  final double iconSize;
  final VoidCallback? onTap;
  final int? notice;

  const CircleIcon({
    Key? key,
    required this.color,
    required this.icon,
    this.size = 36.0,
    this.iconSize = 20.0,
    this.onTap,
    this.notice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: iconSize, color: Colors.black),
            if (notice != 0 && notice != null)
              PBadge(
                text: notice.toString(),
                size: 'small',
                right: 0.0,
                top: 0.0,
                fs: 10,
              ),
          ],
        ),
      ),
    );
  }
}
