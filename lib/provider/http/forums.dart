import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xisland/http/dio_instance.dart';
import 'package:xisland/http/static/api.dart';
import 'package:xisland/model/mainforums.dart';

final getMainForums = FutureProvider.autoDispose<List<MainForum>?>((ref) async {
  var res = await ref
      .read(networkServiceProvider)
      .get(path: Api.baseUrl + Api.mainForumsUrl);
  final mainForums = Mainforums.fromJson(res.data);
  for (var e in mainForums.list!) {
    debugPrint(e.name!);
  }
  return mainForums.list;
});

final getTimelines = FutureProvider.autoDispose<List<TimeLine>?>((ref) async {
  var res = await ref
      .read(networkServiceProvider)
      .get(path: Api.baseUrl + Api.timeLinesUrl);
  final timeLines = TimeLines.fronJson(res.data);
  for (var r in timeLines.list!) {
    debugPrint(r.name);
  }
  return timeLines.list;
});

// final getForumSections = FutureProvider<List<ForumSection>>((ref) async {
//   final mainRes = await ref.read(getMainForums.future);
//   final timelineRes = await ref.read(getTimelines.future);
//   final mainForums = mainRes ?? [];
//   final timelines = timelineRes ?? [];
//   return parseSections(mainForums: mainForums, timelines: timelines);
// });
