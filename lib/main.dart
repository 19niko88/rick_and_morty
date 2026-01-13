import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rick_and_morty/rick_and_morty_app.dart';

import 'config/locator/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await initializeGetIt();
  runApp(const RickAndMortyApp());
}


