import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_genesis/core/constants/app_settings.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'core/di/service_locator.dart';
import 'core/observers/app_bloc_observer.dart';
// import 'core/services/fcm_service.dart';
import 'core/storage/hive/hive_boxes.dart';
import 'core/ui/components/device_preview/device_preview_app.dart';
import 'core/utils/orientation_manager.dart';
// import 'hive_registrar.g.dart';

void main() async {
  /// Ensures Flutter framework initialization before app execution.
  WidgetsFlutterBinding.ensureInitialized();

  /// Enables BLoC observer in debug mode to track state management events.
  if (!AppSettings.isProduction) {
    Bloc.observer = AppBlocObserver();
  }

  await Future.wait<void>([
    /// Restricts screen orientation to portrait mode for consistent UI/UX.
    OrientationManager.allowOnlyPortrait(),

    /// Initializes Hive for local storage management.
    Hive.initFlutter(),
  ]);

  /// Registers Hive adapters for data serialization/deserialization.
  // Hive.registerAdapters();

  /// Opens predefined Hive boxes for persistent data access.
  await HiveBoxes.initialize();

  /// Configures service locator for dependency injection (Clean Architecture).
  initializeDependencies();

  /// Initializes Firebase and FCM. Must run after Hive and service locator.
  // await FcmService().initialize();

  /// Launches the app. DevicePreviewApp is used in non-production builds only.
  /// To remove device_preview: delete the ternary, keep only `const App()`.
  runApp(
    AppSettings.isDevicePreviewActive
        ? const DevicePreviewApp()
        : const App(),
  );
}
