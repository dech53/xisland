class MainForum {
  int? id;
  int? sort;
  String? name;
  String? status;
  List<Forum>? forums;
  MainForum({this.id, this.sort, this.name, this.status, this.forums});
  MainForum.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id']);
    sort = int.parse(json['sort']);
    name = json['name'];
    status = json['status'];
    forums = [
      for (var e in json['forums'])
        if (Forum.fromJson(e).id != -1) Forum.fromJson(e),
    ];
  }
}

class Mainforums {
  List<MainForum>? list;
  Mainforums({this.list});
  Mainforums.fromJson(List<dynamic> jsonList) {
    list = jsonList
        .map((e) => MainForum.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class Forum {
  int? id;
  String? fgroup;
  String? sort;
  String? name;
  String? showName;
  String? msg;
  String? interval;
  String? safeMode;
  String? autoDelete;
  String? threadCount;
  String? permissionLevel;
  String? forumFuseId;
  String? createdAt;
  String? updateAt;
  String? status;

  Forum({
    this.id,
    this.fgroup,
    this.sort,
    this.name,
    this.showName,
    this.msg,
    this.interval,
    this.safeMode,
    this.autoDelete,
    this.threadCount,
    this.permissionLevel,
    this.forumFuseId,
    this.createdAt,
    this.updateAt,
    this.status,
  });

  Forum.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? int.parse(json['id']) : 0;
    fgroup = json['fgroup'] ?? '';
    sort = json['sort'] ?? '';
    name = json['name'];
    showName = json['showName'] ?? '';
    msg = json['msg'];
    interval = json['interval'] ?? '';
    safeMode = json['safe_mode'] ?? '';
    autoDelete = json['auto_delete'] ?? '';
    threadCount = json['thread_count'] ?? '';
    permissionLevel = json['permission_level'] ?? '';
    forumFuseId = json['forum_fuse_id'] ?? '';
    createdAt = json['createdAt'] ?? '';
    updateAt = json['updateAt'] ?? '';
    status = json['status'] ?? '';
  }
}

class TimeLine {
  int? id;
  String? name;
  String? displayName;
  String? notice;
  int? maxPage;
  TimeLine({this.id, this.name, this.displayName, this.notice, this.maxPage});
  TimeLine.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    displayName = json['display_name'];
    notice = json['notice'];
    maxPage = 20;
  }
}

class TimeLines {
  List<TimeLine>? list;
  TimeLines({this.list});
  TimeLines.fronJson(List<dynamic> jsonList) {
    list = jsonList
        .map((e) => TimeLine.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
class ForumSection {
  final int id;
  final String name;

  ForumSection({
    required this.id,
    required this.name,
  });
}