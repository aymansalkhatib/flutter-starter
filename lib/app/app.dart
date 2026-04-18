import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_genesis/core/routing/navigation_service.dart';
import 'package:flutter_genesis/core/routing/notification_navigator.dart';
import 'package:flutter_genesis/core/themes/app_theme_manager.dart';

import '../core/constants/app_settings.dart';
import '../core/di/service_locator.dart';
import '../core/localization/app_localizations.dart';
import '../core/localization/app_localizations_delegate.dart';
import '../core/routing/app_route.dart';
import '../core/routing/route_manager.dart';
import '../core/services/fcm_service.dart';
import '../core/themes/dark_theme.dart';
import '../core/themes/light_theme.dart';
import 'cubit/app_cubit.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
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
    return BlocProvider(
      create: (_) => sl<AppCubit>(),
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          final cubit = context.read<AppCubit>();
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
              return child!;
            },
            theme: LightTheme().themeData,
            darkTheme: DarkTheme().themeData,
            themeMode: cubit.currentThemeMode,
            localizationsDelegates: appLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            localeResolutionCallback: resolveDeviceLocale,
            locale: cubit.currentLocale,
            onGenerateRoute: RouteManager.generateRoute,
            initialRoute: AppRoute.splashScreen.path,
          );
        },
      ),
    );
  }
}
