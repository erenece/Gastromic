import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flavor/flavor.dart';
import 'package:gastromic/firebase_options_dev.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:gastromic/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();
  await Hive.openBox('settings');

  Flavor.create(
    Environment.dev,
    name: 'DEV',
    color: Colors.orange,
    properties: {
      Keys.apiUrl: 'https://TODO-dev-backend-url',
      Keys.appTitle: 'Gastromic Dev',
    },
  );
  runApp(App());
}
