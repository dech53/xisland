import 'package:hive_flutter/hive_flutter.dart';
part 'cookie.g.dart';

@HiveType(typeId: 2)
class Cookie {
  @HiveField(0)
  final String cookie;

  @HiveField(1)
  final String name;

  @HiveField(2)
  bool isMain;

  Cookie({required this.cookie, required this.name, this.isMain = false});

  factory Cookie.fromJson(Map<String, dynamic> json) {
    return Cookie(
      cookie: json['cookie'] as String,
      name: json['name'] as String,
      isMain: false,
    );
  }
}

extension CookieCopy on Cookie {
  Cookie copyWith({String? cookie, String? name, bool? isMain}) {
    return Cookie(
      cookie: cookie ?? this.cookie,
      name: name ?? this.name,
      isMain: isMain ?? this.isMain,
    );
  }
}
