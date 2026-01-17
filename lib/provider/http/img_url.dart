import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xisland/http/dio_instance.dart';
import 'package:xisland/model/cdn_path.dart';

final imgUrlNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<ImgUrlNotifier, CdnPathList, NetworkService>(ImgUrlNotifier.new);

class ImgUrlNotifier extends AsyncNotifier<CdnPathList> {
  final NetworkService service;
  ImgUrlNotifier(this.service);
  @override
  FutureOr<CdnPathList> build() {
    return _fetchImgUrl(ref);
  }

  Future<CdnPathList> _fetchImgUrl(Ref ref) async {
    final res = await service.get(path: "https://api.nmb.best/api/getCDNPath");
    return CdnPathList.fromJson(res.data);
  }
}