import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xisland/http/http_methods.dart';
import 'package:xisland/http/static/num.dart';

final networkServiceProvider = Provider<NetworkService>((ref) {
  final dio = ref.read(_dioProvider);
  return NetworkService(dio);
});

class NetworkService {
  final Dio dio;
  NetworkService(this.dio);
  Future<Response> get({
    required String path,
    Map<String, dynamic>? param,
    Options? options,
    CancelToken? cancelToken,
    Map<String, dynamic>? extra,
  }) async {
    debugPrint("path:$path");
    final Options opt = options ?? Options();
    if (extra != null && extra['ua'] != null) {
      opt.headers = {'user-agent': headerUa(type: extra['ua'])};
    }
    return dio.get(
      path,
      queryParameters: param,
      options: opt,
      cancelToken: cancelToken,
    );
  }

  Future<Response> post({
    required String path,
    Object? data,
    Map<String, dynamic>? param,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final Options opt = options ?? Options(method: HttpMethods.post);
    return dio.post(
      path,
      data: data,
      queryParameters: param,
      options: opt,
      cancelToken: cancelToken,
    );
  }
}

final _dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  dio.options = BaseOptions(
    connectTimeout: NumStatics.defaultTimeout,
    receiveTimeout: NumStatics.defaultTimeout,
    sendTimeout: NumStatics.defaultTimeout,
    responseType: ResponseType.json,
    maxRedirects: 3,
    headers: {'user-agent': headerUa()},
  );
  return dio;
});

String headerUa({type = 'mob'}) {
  String headerUa = '';
  if (type == 'mob') {
    if (Platform.isIOS) {
      headerUa =
          'Mozilla/5.0 (iPhone; CPU iPhone OS 14_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1 Mobile/15E148 Safari/604.1';
    } else {
      headerUa =
          'Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.101 Mobile Safari/537.36';
    }
  } else {
    headerUa =
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.2 Safari/605.1.15';
  }
  return headerUa;
}
