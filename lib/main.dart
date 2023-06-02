import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_blue/flutter_blue.dart';
// import 'find_bluetooth.dart';
import 'firebase_options.dart';
import 'my_home_body.dart';
import 'many_buttons_body.dart';
import 'constant.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); //縦向き指定
  MobileAds.instance.initialize();
  await dotenv.load(fileName: "assets/.env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => MaterialApp(
    builder: (BuildContext context, Widget? child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
      child: child!,
    ),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    title: appTitle,
    theme: ThemeData(primarySwatch: Colors.grey),
    debugShowCheckedModeBanner: false,
    initialRoute: "/h",
    routes: {
      "/h": (context) => const MyHomePage(),
      "/r": (context) => const ManyButtonsPage(),
      // "/b": (context) => StreamBuilder<BluetoothState>(
      //   stream: FlutterBlue.instance.state,
      //   initialData: BluetoothState.unknown,
      //   builder: (c, snapshot) => const FindBluetooth(),
      // ),
    },
    navigatorObservers: <NavigatorObserver>[
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      RouteObserver<ModalRoute>()
    ],
  );
}