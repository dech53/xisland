import 'package:xisland/model/mainforums.dart';

List<ForumSection> parseSections({List<MainForum>? mainForums}) {
  final List<ForumSection> sections = [];
  if (mainForums != null) {
    for (var mf in mainForums) {
      if (mf.forums != null && mf.forums!.isNotEmpty) {
        for (var f in mf.forums!) {
          sections.add(ForumSection(id: f.id ?? 0, name: f.name ?? ''));
        }
      }
    }
  }
  return sections;
}
