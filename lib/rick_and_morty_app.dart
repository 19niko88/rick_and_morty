import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/config.dart';

class RickAndMortyApp extends StatelessWidget {
  const RickAndMortyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) {
        return MaterialApp.router(
          title: 'Rick & Morty',
          debugShowCheckedModeBanner: false,
          routerConfig: getIt<AppRouter>().config(),
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.lightGreen,
            ),
          ),
        );
      },
    );
  }
}

