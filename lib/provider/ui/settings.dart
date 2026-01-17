import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xisland/model/settings.dart';
import 'package:xisland/utils/storage.dart';

class SettingNotifier extends Notifier<Settings> {
  @override
  Settings build() {
    return SPStorage.settings.get('settings') ?? Settings(
      true
    );
  }

  void setEnableGradientBg(bool value) {
    state = state.copyWith(enableGradientBg: value);
  }
}

final settingsProvider = NotifierProvider<SettingNotifier, Settings>(
  SettingNotifier.new,
);
