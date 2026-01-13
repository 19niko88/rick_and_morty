import 'package:flutter/material.dart';
import 'package:rick_and_morty/presentation/screens/home/home_screen.dart';

class RickAndMartyApp extends StatelessWidget {
  const RickAndMartyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const HomeScreen(),
    );
  }
}
