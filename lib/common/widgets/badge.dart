import 'package:flutter/material.dart';

class PBadge extends StatelessWidget {
  final String? text;
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  final String? type;
  final String? size;
  final String? stack;
  final double? fs;
  final VoidCallback? onTap;
  final EdgeInsets? outerPadding;

  const PBadge({
    super.key,
    this.text,
    this.top,
    this.right,
    this.bottom,
    this.left,
    this.type = 'primary',
    this.size = 'medium',
    this.stack = 'position',
    this.fs,
    this.onTap,
    this.outerPadding,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme t = Theme.of(context).colorScheme;
    Color bgColor = t.primary;
    Color color = t.onPrimary;
    Color borderColor = Colors.transparent;

    switch (type) {
      case 'gray':
        bgColor = Colors.black54.withValues(alpha: 0.4);
        color = Colors.white;
        break;
      case 'color':
        bgColor = t.primaryContainer.withValues(alpha: 0.6);
        color = t.primary;
        break;
      case 'line':
        bgColor = Colors.transparent;
        color = t.primary;
        borderColor = t.primary.withValues(alpha: 0.5);
        break;
    }

    EdgeInsets paddingStyle = const EdgeInsets.symmetric(
      vertical: 1,
      horizontal: 6,
    );
    double defaultFontSize = 11;
    BorderRadius br = BorderRadius.circular(8);

    if (size == 'small') {
      paddingStyle = const EdgeInsets.symmetric(vertical: 0, horizontal: 3);
      defaultFontSize = 8;
      br = BorderRadius.circular(10);
    }

    final double fontSize = fs ?? defaultFontSize;

    Widget content = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: paddingStyle,
        decoration: BoxDecoration(
          borderRadius: br,
          color: bgColor,
          border: Border.all(color: borderColor),
        ),
        child: outerPadding != null
            ? Padding(
                padding: outerPadding!,
                child: Text(
                  text ?? '',
                  style: TextStyle(fontSize: fontSize, color: color),
                ),
              )
            : Text(
                text ?? '',
                style: TextStyle(fontSize: fontSize, color: color),
              ),
      ),
    );

    if (stack == 'position') {
      return Positioned(
        top: top,
        left: left,
        right: right,
        bottom: bottom,
        child: content,
      );
    } else {
      return content;
    }
  }
}