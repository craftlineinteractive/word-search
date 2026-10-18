import 'package:flutter/material.dart';
class ThemeManager {
  static final ThemeManager instance = ThemeManager._internal();

  factory ThemeManager() => instance;

  ThemeManager._internal();

  final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

  ThemeMode get currentThemeMode => ThemeMode.light;

  Future<void> init() async {
    themeModeNotifier.value = ThemeMode.light;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    // Single light mode enforced across entire game
    themeModeNotifier.value = ThemeMode.light;
  }
}
