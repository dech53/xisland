class ForumPostList {
  List<ForumPost>? posts;
  ForumPostList({this.posts});
  ForumPostList.fromJson(List<dynamic> jsonList) {
    posts = jsonList
        .map((e) => ForumPost.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class ForumPost {
  int? id;
  int? fid;
  int? replyCount;
  String? img;
  String? ext;
  String? now;
  String? userHash;
  String? name;
  String? title;
  String? content;
  int? sage;
  int? admin;
  int? hide;
  List? replies;
  int? reaminReplies;

  ForumPost({
    this.id,
    this.fid,
    this.replyCount,
    this.img,
    this.ext,
    this.now,
    this.userHash,
    this.name,
    this.title,
    this.content,
    this.sage,
    this.admin,
    this.hide,
    this.replies,
    this.reaminReplies,
  });

  ForumPost.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fid = json['fid'];
    replyCount = json['ReplyCount'];
    img = json['img'];
    ext = json['ext'];
    now = json['now'];
    userHash = json['user_hash'];
    name = json['name'];
    title = json['title'];
    content = json['content'];
    sage = json['sage'];
    admin = json['admin'];
    hide = json['Hide'];
    replies = json['Replies'];
    reaminReplies = json['RemainReplies'];
  }
}
