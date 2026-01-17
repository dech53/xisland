import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:xisland/pages/root/view.dart';
import 'package:xisland/utils/storage.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    Box localCache = SPStorage.localCache;
    double sheetHeight = MediaQuery.sizeOf(context).height -
        MediaQuery.of(context).padding.top -
        MediaQuery.sizeOf(context).width * 9 / 16;
    localCache.put('sheetHeight', sheetHeight);
    SPStorage.statusBarHeight = statusBarHeight;
    return const RootPage();
  }
}
