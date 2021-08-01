import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:recyminer_miner/localization/app_localization.dart';
import 'package:recyminer_miner/notification/my_notification.dart';
import 'package:recyminer_miner/provider/auth_provider.dart';
import 'package:recyminer_miner/provider/language_provider.dart';
import 'package:recyminer_miner/provider/localization_provider.dart';
import 'package:recyminer_miner/provider/location_mining_provider.dart';
import 'package:recyminer_miner/provider/location_order_provider.dart';
import 'package:recyminer_miner/provider/order_provider.dart';
import 'package:recyminer_miner/provider/profile_provider.dart';
import 'package:recyminer_miner/provider/splash_provider.dart';
import 'package:recyminer_miner/provider/theme_provider.dart';
import 'package:recyminer_miner/provider/tracker_provider.dart';
import 'package:recyminer_miner/theme/dark_theme.dart';
import 'package:recyminer_miner/theme/light_theme.dart';
import 'package:recyminer_miner/utill/app_constants.dart';
import 'package:recyminer_miner/view/screens/splash/splash_screen.dart';

import 'di_container.dart' as di;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.init();
  await MyNotification.initialize(flutterLocalNotificationsPlugin);
  FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => di.sl<ThemeProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<SplashProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<LanguageProvider>()),
      ChangeNotifierProvider(
          create: (context) => di.sl<LocalizationProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<AuthProvider>()),
      ChangeNotifierProvider(
          create: (context) => di.sl<LocalizationProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<ProfileProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<OrderProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<TrackerProvider>()),
      ChangeNotifierProvider(
          create: (context) => di.sl<LocationOrderProvider>()),
      ChangeNotifierProvider(
          create: (context) => di.sl<LocationMiningProvider>())
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Locale> _locals = [];
    AppConstants.languages.forEach((language) {
      _locals.add(Locale(language.languageCode, language.countryCode));
    });
    return MaterialApp(
      title: AppConstants.APP_NAME,
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).darkTheme ? dark : light,
      locale: Provider.of<LocalizationProvider>(context).locale,
      localizationsDelegates: [
        AppLocalization.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: _locals,
      home: SplashScreen(),
    );
  }
}
