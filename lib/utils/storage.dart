import 'package:flutter/rendering.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xisland/model/cookie.dart';
import 'package:xisland/model/mainforums.dart';
import 'package:xisland/model/settings.dart';
import 'package:xisland/utils/parse_sections.dart';

class SPStorage {
  static late final Box<dynamic> localCache;
  static late double statusBarHeight;
  static late final Box<Settings> settings;
  static late final List<MainForum> mainForums;
  static late final List<TimeLine> timeLines;
  static late final List<ForumSection> forumSections;
  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter('${dir.path}/hive');
    regAdapter();
    localCache = await Hive.openBox(
      'localCache',
      compactionStrategy: (int entries, int deletedEntries) {
        return deletedEntries > 4;
      },
    );
    forumSections = parseSections(mainForums: mainForums);

    settings = await Hive.openBox<Settings>('setting');
  }

  static void regAdapter() {
    Hive.registerAdapter(SettingsAdapter());
    Hive.registerAdapter(CookieAdapter());
  }

  static Future<void> close() async {
    localCache.compact();
    localCache.close();
    settings.close();
  }

  
}
