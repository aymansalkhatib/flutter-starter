import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants/app_settings.dart';

/// Centralized logger for BLoC/Cubit lifecycle and state events.
class BlocLogger {
  factory BlocLogger() => _instance;
  BlocLogger._internal();
  static final BlocLogger _instance = BlocLogger._internal();

  void logCreation(BlocBase<dynamic> bloc) =>
      _log('[CREATED] ${bloc.runtimeType}', _LogLevel.create);

  void logEvent(Bloc<dynamic, dynamic> bloc, Object? event) =>
      _log('[EVENT] ${bloc.runtimeType} → $event', _LogLevel.event);

  void logChange(BlocBase<dynamic> bloc, Change<dynamic> change) => _log(
    '[CHANGE] ${bloc.runtimeType} | ${change.currentState} → ${change.nextState}',
    _LogLevel.change,
  );

  void logTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) => _log(
    '[TRANSITION] ${bloc.runtimeType} | event: ${transition.event} | ${transition.currentState} → ${transition.nextState}',
    _LogLevel.transition,
  );

  void logError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    final trace = stackTrace.toString().split('\n').take(8).join('\n');
    _log('[ERROR] ${bloc.runtimeType} | $error\n$trace', _LogLevel.error);
  }

  void logClosure(BlocBase<dynamic> bloc) =>
      _log('[CLOSED] ${bloc.runtimeType}', _LogLevel.close);

  void _log(String message, _LogLevel level) {
    if (!AppSettings.enableLogging || !AppSettings.enableBlocObserverLogger) {
      return;
    }
    dev.log('${level.emoji} $message', name: level.label);
  }
}

enum _LogLevel {
  create('Create', '🟢'),
  event('Event', '🔵'),
  change('Change', '🟡'),
  transition('Transition', '🟠'),
  error('Error', '🔴'),
  close('Close', '⚫');

  const _LogLevel(this.label, this.emoji);
  final String label;
  final String emoji;
}
