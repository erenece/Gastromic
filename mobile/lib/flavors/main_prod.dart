import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flavor/flavor.dart';
import 'package:gastromic/firebase_options_prod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:gastromic/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();
  await Hive.openBox('settings');

  Flavor.create(
    Environment.production,
    properties: {
      Keys.apiUrl: 'https://TODO-prod-backend-url',
      Keys.appTitle: 'Gastromic',
    },
  );
  runApp(App());
}
