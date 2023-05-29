import 'package:e_trace_app/firebase_options.dart';
import 'package:e_trace_app/screen/home/counter_notifier.dart';
import 'package:e_trace_app/screen/login/companies_notifier.dart';
import 'package:e_trace_app/screen/main/main_notifier.dart';
import 'package:e_trace_app/screen/point/point_notifier.dart';
import 'package:e_trace_app/screen/data_screen/read_data_notifier.dart';
import 'package:e_trace_app/utils/theme_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_trace_app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFirebase();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(lazy: false, create: (_) => CounterNotifier()),
        ChangeNotifierProvider(lazy: false, create: (_) => MainNotifier()),
        ChangeNotifierProvider(lazy: false, create: (_) => ReadDataNotifier()),
        ChangeNotifierProvider(lazy: false, create: (_) => PointNotifier()),
        ChangeNotifierProvider(lazy: false, create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(lazy: false, create: (_) => CompanyViewModel()),
      ],
      child: App(),
    ),
  );
}

Future<void> initFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await FirebaseService().initializeFirebaseMessaging();
  // await FirebaseService().initializeFirebaseMessagingHandler();
}
