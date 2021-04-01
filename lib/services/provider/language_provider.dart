import 'package:flutter/cupertino.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _appLocale = Locale('es');

  Locale get appLocal => _appLocale ?? Locale("es");
  fetchLocale() async {
    String lang = await SharedPrefe().getValue('language_code') ?? 'es';
    _appLocale = Locale(lang);
    notifyListeners();
  }

  void changeLanguage(Locale type) async {
    if (_appLocale == type) {
      return;
    }
    if (type == Locale("es")) {
      _appLocale = Locale("es");
      await SharedPrefe().setStringValue('language_code', 'es');
      await SharedPrefe().setStringValue('countryCode', 'ES');
    } else {
      _appLocale = Locale("en");
      await SharedPrefe().setStringValue('language_code', 'en');
      await SharedPrefe().setStringValue('countryCode', 'US');
    }
    notifyListeners();
  }
}