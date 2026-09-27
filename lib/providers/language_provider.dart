import 'package:flutter/material.dart';
import '../utils/app_strings.dart';

class LanguageProvider extends ChangeNotifier {
  AppLanguage _language = AppLanguage.english;
  AppLanguage get language => _language;

  AppStrings get strings => AppStrings(_language);

  void setLanguage(AppLanguage lang) {
    _language = lang;
    notifyListeners();
  }
}