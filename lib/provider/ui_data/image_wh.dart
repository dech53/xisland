import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xisland/http/dio_instance.dart';

final imageSizeProvider = FutureProvider.family<Size, String>((ref, url) async {
  final res = await ref
      .read(networkServiceProvider)
      .get(
        path: url,
        options: Options(responseType: ResponseType.bytes),
      );
  final data = res.data;
  if (data == null) {
    //数据检验
  }
  final bytes = Uint8List.fromList(data as List<int>);
  final image = await _decodeImage(bytes);
  return Size(image.width.toDouble(), image.height.toDouble());
});

Future<ui.Image> _decodeImage(Uint8List bytes) {
  final completer = Completer<ui.Image>();
  ui.decodeImageFromList(bytes, completer.complete);
  return completer.future;
}
