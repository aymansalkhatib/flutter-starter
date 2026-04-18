import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_genesis/core/routing/navigation_service.dart';
import 'package:flutter_genesis/core/routing/notification_navigator.dart';
import 'package:flutter_genesis/core/themes/app_theme_manager.dart';

import '../../../../app/cubit/app_cubit.dart';
import '../../../constants/app_settings.dart';
import '../../../di/service_locator.dart';
import '../../../localization/app_localizations.dart';
import '../../../localization/app_localizations_delegate.dart';
import '../../../routing/app_route.dart';
import '../../../routing/route_manager.dart';
import '../../../services/fcm_service.dart';
import '../../../themes/dark_theme.dart';
import '../../../themes/light_theme.dart';
import 'device_preview_screenshot_tool.dart';

/// A [MyApp] variant wired for [DevicePreview].
///
/// Lives entirely inside `lib/core/components/device_preview/`.
/// To remove device_preview in production:
///   1. Delete this folder.
///   2. Remove the ternary in `main.dart` — keep only `runApp(const MyApp())`.
///   3. Remove the package from `pubspec.yaml`.
class DevicePreviewApp extends StatefulWidget {
  const DevicePreviewApp({super.key});

  @override
  State<DevicePreviewApp> createState() => _DevicePreviewAppState();
}

class _DevicePreviewAppState extends State<DevicePreviewApp> {
  @override
  void initState() {
    super.initState();
    _setupNotificationNavigation();
  }

  void _setupNotificationNavigation() {
    // Background → foreground: user taps the notification.
    FcmService().onMessageOpenedApp.listen(NotificationNavigator.handle);

    // Terminated state: navigator isn't ready during FcmService.initialize(),
    // so we defer handling until after the first frame is rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationNavigator.handlePending();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DevicePreview(
      defaultDevice: Devices.android.samsungGalaxyA50,
      storage: DevicePreviewStorage.preferences(),
      tools: const [
        ...DevicePreview.defaultTools,
        DevicePreviewScreenshotTool(),
      ],
      availableLocales: AppLocalizations.supportedLocales,
      builder: (context) => BlocProvider(
        create: (_) => sl<AppCubit>(),
        child: BlocBuilder<AppCubit, AppState>(
          builder: (context, state) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: AppSettings.appName,
              navigatorKey: sl<GlobalKey<NavigatorState>>(),
              scaffoldMessengerKey: sl<GlobalKey<ScaffoldMessengerState>>(),
              navigatorObservers: AppSettings.isProduction
                  ? []
                  : [NavigationService.routeObserver],
              builder: (context, child) {
                AppThemeManager.updateStatusBar(context);
                return DevicePreview.appBuilder(context, child);
              },
              theme: LightTheme().themeData,
              darkTheme: DarkTheme().themeData,
              localizationsDelegates: appLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              localeResolutionCallback: resolveDeviceLocale,
              locale: DevicePreview.locale(context),
              onGenerateRoute: RouteManager.generateRoute,
              initialRoute: AppRoute.splashScreen.path,
            );
          },
        ),
      ),
    );
  }
}
