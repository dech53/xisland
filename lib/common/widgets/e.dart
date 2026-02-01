import 'package:flutter/material.dart';

class ExpandableRef extends StatefulWidget {
  final String refId;
  final int parentId;
  final Widget collapsed;
  final Widget expanded;

  const ExpandableRef({
    super.key,
    required this.refId,
    required this.parentId,
    required this.collapsed,
    required this.expanded,
  });

  @override
  State<ExpandableRef> createState() => _ExpandableRefState();
}

class _ExpandableRefState extends State<ExpandableRef> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Padding(
          padding: _isExpanded
              ? const EdgeInsets.symmetric(vertical: 8.0)
              : EdgeInsets.zero,
          child: _isExpanded ? widget.expanded : widget.collapsed,
        ),
      ),
    );
  }
}
