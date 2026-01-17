import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:xisland/app.dart';
import 'package:xisland/provider/http/forums.dart';
import 'package:xisland/utils/logger.dart';
import 'package:xisland/utils/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer(observers: [Logger()]);
  final mainForums = await container.read(getMainForums.future);
  final timeLines = await container.read(getTimelines.future);
  SPStorage.mainForums = mainForums!;
  SPStorage.timeLines = timeLines!;
  // final forum_section = parseSections(
  //   mainForums: mainForums,
  //   timelines: timeLines,
  // );
  await SPStorage.init();
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        builder: FlutterSmartDialog.init(),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.cyan,
            brightness: Brightness.light,
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const MyApp(),
      ),
    ),
  );
}
