import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/constants/hive/storage_keys.dart';
import 'package:flutter_starter/core/extensions/index.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/localization/translation_manager.dart';
import '../../core/storage/hive/hive_boxes.dart';
import '../../core/storage/hive/hive_storage_service.dart';
import '../../core/themes/app_theme_manager.dart';

part 'app_cubit.freezed.dart';
part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  final HiveStorageService<dynamic> _appBox = HiveBoxes.appBox;

  Locale _locale;
  ThemeMode _themeMode;

  factory AppCubit() {
    return AppCubit._(
      locale: TranslationManager.fetchPreferredLanguage(),
      themeMode: AppThemeManager.getCurrentThemeMode(),
    );
  }

  AppCubit._({required Locale locale, required ThemeMode themeMode})
      : _locale = locale,
        _themeMode = themeMode,
        super(AppState.initial(themeMode: themeMode, locale: locale));

  Locale get currentLocale => _locale;
  ThemeMode get currentThemeMode => _themeMode;

  Future<void> updateAppLanguage(Locale? newLocale) async {
    if (newLocale == null) {
      await _appBox.delete(StorageKeys.languagePreference);
      _locale = TranslationManager.fetchPreferredLanguage();
    } else {
      _locale = newLocale;
      await _appBox.put(StorageKeys.languagePreference, newLocale.languageCode);
    }
    safeEmit(AppState.languageChanged(locale: _locale));
  }

  Future<void> switchAppTheme(
    ThemeMode newThemeMode, {
    bool shouldSave = true,
  }) async {
    _themeMode = newThemeMode;
    if (shouldSave) {
      if (newThemeMode == ThemeMode.system) {
        await _appBox.delete(StorageKeys.themeModePreference);
      } else {
        await _appBox.put(StorageKeys.themeModePreference, newThemeMode.name);
      }
    }
    safeEmit(AppState.themeChanged(themeMode: _themeMode));
  }

  void syncWithSystemSettings() {
    _themeMode = AppThemeManager.getCurrentThemeMode();
    _locale = TranslationManager.fetchPreferredLanguage();
    safeEmit(AppState.initial(themeMode: _themeMode, locale: _locale));
  }
}
