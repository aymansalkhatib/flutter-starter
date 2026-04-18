import 'package:get_it/get_it.dart';

/// Extends [GetIt] with a replace-aware singleton registration.
///
/// Use this for flow-scoped singletons — BLoCs that must stay alive
/// across multiple screens in the same flow, but should be recreated
/// fresh when the flow is entered again.
///
/// Example:
/// ```dart
/// // On entering Screen A:
/// sl.replaceSingleton<CheckoutCubit>(CheckoutCubit());
///
/// // Screen B reads the same live instance:
/// sl<CheckoutCubit>().state; // same state as Screen A
///
/// // On re-entering the flow, a clean instance is created automatically.
/// ```
extension GetItExtension on GetIt {
  /// Registers [instance] as a singleton, replacing any existing registration.
  Future<void> replaceSingleton<T extends Object>(
    T instance, {
    String? instanceName,
  }) async {
    if (isRegistered<T>(instanceName: instanceName)) {
      await unregister<T>(instanceName: instanceName);
    }
    registerSingleton<T>(instance, instanceName: instanceName);
  }
}
