import 'package:hive_flutter/hive_flutter.dart';
part 'settings.g.dart';

@HiveType(typeId: 1)
class Settings {
  @HiveField(0)
  final bool enableGradientBg;

  const Settings(this.enableGradientBg);

  Settings copyWith({bool? enableGradientBg}) {
    return Settings(enableGradientBg ?? this.enableGradientBg);
  }
}
