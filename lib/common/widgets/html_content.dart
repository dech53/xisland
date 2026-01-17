import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

class HtmlContent extends StatelessWidget {
  final String? htmlContent;

  const HtmlContent({super.key, this.htmlContent});

  @override
  Widget build(BuildContext context) {
    return Html(
      data: htmlContent,
      onLinkTap: (String? url, Map<String, String> buildContext, attributes)async {
        await launchUrl(Uri.parse(url!));
      },
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
}
