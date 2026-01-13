import 'package:flutter/material.dart';
import 'package:rick_and_morty/rick_and_marty_app.dart';

import 'config/locator/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeGetIt();
  runApp(const RickAndMartyApp());
}


