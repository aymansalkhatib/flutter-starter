part of 'app_cubit.dart';

@freezed
class AppState with _$AppState {
  /// Emitted on first load and when the OS changes system settings.
  const factory AppState.initial({
    required ThemeMode themeMode,
    required Locale locale,
  }) = _InitialState;

  /// Emitted when the user changes the theme.
  const factory AppState.themeChanged({
    required ThemeMode themeMode,
  }) = _ThemeChangedState;

  /// Emitted when the user changes the language.
  const factory AppState.languageChanged({
    required Locale locale,
  }) = _LanguageChangedState;
}
