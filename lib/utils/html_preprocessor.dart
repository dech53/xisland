class HtmlPreprocessor {
  static final RegExp _replyPattern = RegExp('<font[^>]*color\s*=\s*["\']?([^"\']+)["\']?[^>]*>(&gt;|&gt;)*No\.(\d+)</font>',caseSensitive: false);

  static final RegExp _simpleReplyPattern = RegExp(
    r'(&gt;|&gt;)*No\.(\d+)',
    caseSensitive: false,
  );

  static String preprocess(String? htmlContent) {
    if (htmlContent == null || htmlContent.isEmpty) {
      return '';
    }

    String processed = htmlContent;

    processed = processed.replaceAllMapped(_replyPattern, (match) {
      final color = match.group(1) ?? '#000000';
      final replyId = match.group(3) ?? '';
      return '<reply-link color="$color" id="$replyId">>>No.$replyId</reply-link><br />\n';
    });

    processed = processed.replaceAllMapped(_simpleReplyPattern, (match) {
      if (match.group(0)!.startsWith('>>') || match.group(0)!.startsWith('&gt;')) {
        final replyId = match.group(2);
        if (replyId != null) {
          return '<reply-link id="$replyId">>>No.$replyId</reply-link><br />\n';
        }
      }
      return match.group(0)!;
    });

    return processed;
  }
}
