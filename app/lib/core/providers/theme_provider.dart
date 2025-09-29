import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const _themeBox = 'theme_box';
  static const _themeKey = 'selected_theme';
  static const _modeKey = 'theme_mode';
  static const _quickSwitchKey = 'quick_switch';

  ThemeProvider() {
    _load();
  }

  late AppPalette _currentPalette = ThemeCatalog.palettes.first;
  ThemeMode _themeMode = ThemeMode.system;
  bool _quickSwitchEnabled = false;

  AppPalette get currentTheme => _currentPalette;
  ThemeMode get themeMode => _themeMode;
  bool get quickSwitchEnabled => _quickSwitchEnabled;

  Future<void> _load() async {
    final box = await Hive.openBox(_themeBox);
    final name = box.get(_themeKey) as String?;
    final modeIndex = box.get(_modeKey) as int?;
    final quickSwitch = box.get(_quickSwitchKey) as bool?;

    if (name != null) {
      _currentPalette = ThemeCatalog.palettes.firstWhere(
        (element) => element.name == name,
        orElse: () => ThemeCatalog.palettes.first,
      );
    }

    if (modeIndex != null) {
      _themeMode = ThemeMode.values[modeIndex];
    }

    _quickSwitchEnabled = quickSwitch ?? false;
    notifyListeners();
  }

  Future<void> updatePalette(AppPalette palette) async {
    _currentPalette = palette;
    final box = await Hive.openBox(_themeBox);
    await box.put(_themeKey, palette.name);
    notifyListeners();
  }

  Future<void> updateMode(ThemeMode mode) async {
    _themeMode = mode;
    final box = await Hive.openBox(_themeBox);
    await box.put(_modeKey, mode.index);
    notifyListeners();
  }

  Future<void> toggleQuickSwitch(bool value) async {
    _quickSwitchEnabled = value;
    final box = await Hive.openBox(_themeBox);
    await box.put(_quickSwitchKey, value);
    notifyListeners();
  }
}
