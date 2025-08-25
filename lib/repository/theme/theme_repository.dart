import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pos/repository/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeRepository {
  final BuildContext context;
  final StreamController<ThemeStyle> _controller =
      StreamController<ThemeStyle>.broadcast();
  ThemeStyle? _currentTheme;
  SharedPreferences? prefs;

  static const String themeKey = 'THEME_POS';

  ThemeRepository({required this.context}) {
    SharedPreferences.getInstance().then((value) {
      prefs = value;
      int? val = prefs!.getInt(themeKey);
      setTheme(AppTheme.values[val ?? AppTheme.maroonGoldLight.index]);
    });
  }

  Stream<ThemeStyle> get stream => _controller.stream;

  ThemeStyle? get currentTheme => _currentTheme;

  void setTheme(AppTheme selectedTheme) {
    prefs?.setInt(themeKey, selectedTheme.index);
    switch (selectedTheme) {
      case AppTheme.maroonGoldLight:
        _currentTheme = _buildMaroonGoldLight();
        break;
      case AppTheme.maroonGoldDark:
        _currentTheme = _buildMaroonGoldDark();
        break;
    }

    if (_currentTheme != null) {
      _controller.add(_currentTheme!);
    }
  }

  ThemeStyle initialTheme() {
    _currentTheme = _buildMaroonGoldLight();
    return _currentTheme!;
  }

  ThemeStyle _buildMaroonGoldLight() {
    return AppThemeStyle(
      themeData: appThemeData[AppTheme.maroonGoldLight],
      drawerGradientStartColor: AppColors.maroon,
      drawerGradientEndColor: AppColors.darkGold,
    );
  }

  ThemeStyle _buildMaroonGoldDark() {
    return AppThemeStyle(
      themeData: appThemeData[AppTheme.maroonGoldDark],
      drawerGradientStartColor: AppColors.darkGold,
      drawerGradientEndColor: AppColors.maroon,
    );
  }
}
