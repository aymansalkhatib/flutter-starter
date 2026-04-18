import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../app/cubit/app_cubit.dart';
import '../di/service_locator.dart';
import 'app_localizations.dart';

const appLocalizationDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];


/// Resolves the device locale to a supported locale and syncs app state.
///
/// Called by [MaterialApp.localeResolutionCallback] on initial build
/// and whenever the system locale changes.
Locale resolveDeviceLocale(
  Locale? deviceLocale,
  Iterable<Locale> supportedLocales,
) {
  sl<AppCubit>().syncWithSystemSettings();

  if (deviceLocale != null) {
    for (final supported in supportedLocales) {
      if (deviceLocale.languageCode == supported.languageCode) {
        return supported;
      }
    }
  }

  return AppLocalizations.fallbackLocale;
}
