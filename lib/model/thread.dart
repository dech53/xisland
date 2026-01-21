class ThreadDetail {
  final Reply main;
  final List<Reply> replies;

  ThreadDetail({required this.main, required this.replies});

  factory ThreadDetail.fromJson(Map<String, dynamic> json) {
    return ThreadDetail(
      main: Reply.fromJson(json),
      replies:
          (json['Replies'] as List<dynamic>?)
              ?.map((e) => Reply.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <Reply>[],
    );
  }
}

class Reply {
  int id;
  int? fid;
  int? replyCount;
  String userHash;
  String name;
  String title;
  String content;
  String now;
  String img;
  String ext;
  int? sage;
  int? admin;
  int? hide;

  Reply({
    required this.id,
    required this.userHash,
    required this.name,
    required this.title,
    required this.content,
    required this.now,
    this.fid,
    this.replyCount,
    this.img = '',
    this.ext = '',
    this.sage,
    this.admin,
    this.hide,
  });

  Reply.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int,
      fid = json['fid'] as int?,
      replyCount = json['ReplyCount'] as int?,
      userHash = json['user_hash'] as String? ?? '',
      name = json['name'] as String? ?? '',
      title = json['title'] as String? ?? '',
      content = json['content'] as String? ?? '',
      now = json['now'] as String? ?? '',
      img = json['img'] as String? ?? '',
      ext = json['ext'] as String? ?? '',
      sage = json['sage'] as int?,
      admin = json['admin'] as int?,
      hide = json['Hide'] as int?;
}
