import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String prefSelectedLanguageCode = "SelectedLanguageCode";

class LocalRepository {
  final StreamController<Locale?> _controller =
      StreamController<Locale?>.broadcast();
  SharedPreferences? _prefs;
  Locale? _locale;

  LocalRepository() {
    SharedPreferences.getInstance().then((value) {
      _prefs = value;
      String? languageCode = _prefs!.getString(prefSelectedLanguageCode);
      if (languageCode == null) {
        List<Locale> locales = WidgetsBinding.instance.platformDispatcher.locales;
        _locale = locales.isEmpty ? const Locale('en', 'US') : locales.first;
      } else {
        String countryCode = languageCode == 'th' ? 'TH' : 'US';
        _locale = languageCode.isNotEmpty
            ? Locale(languageCode, countryCode)
            : const Locale('en', 'US');
      }

      _controller.add(_locale);
    });
  }

  Stream<Locale?> get stream => _controller.stream;

  String get languageCode => _locale!.languageCode;

  void changeLanguage(BuildContext context, String selectedLanguageCode) async {
    _locale = await setLocale(selectedLanguageCode);
    _controller.add(_locale);
  }

  void close() {
    _controller.close();
  }
}

Future<Locale> setLocale(String languageCode) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(prefSelectedLanguageCode, languageCode);
  return _locale(languageCode);
}

Future<Locale?> getLocale(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? languageCode = prefs.getString(prefSelectedLanguageCode);
  return languageCode == null ? null : _locale(languageCode);
}

Locale _locale(String? languageCode) {
  String countryCode = languageCode == 'th' ? 'TH' : 'US';
  return languageCode != null && languageCode.isNotEmpty
      ? Locale(languageCode, countryCode)
      : const Locale('en', '');
}

// void changeLanguage(BuildContext context, String selectedLanguageCode) async {
//   var _locale = await setLocale(selectedLanguageCode);
//   MyApp.setLocale(context, _locale);
// }