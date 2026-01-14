import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rick_and_morty/utils/theme/bloc/theme_bloc.dart';
import 'config/config.dart';
import 'domain/domain.dart';

class RickAndMortyApp extends StatelessWidget {
  const RickAndMortyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ThemeBloc>()..add(const ThemeEvent.started()),
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, _) {
          return BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return MaterialApp.router(
                title: 'Rick & Morty',
                debugShowCheckedModeBanner: false,
                routerConfig: getIt<AppRouter>().config(),
                themeMode: _getThemeMode(state.mode),
                theme: ThemeData(
                  useMaterial3: true,
                  brightness: Brightness.light,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.lightGreen,
                    brightness: Brightness.light,
                  ),
                ),
                darkTheme: ThemeData(
                  useMaterial3: true,
                  brightness: Brightness.dark,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.lightGreen,
                    brightness: Brightness.dark,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  ThemeMode _getThemeMode(AppThemeModeEnum mode) {
    return switch (mode) {
      AppThemeModeEnum.system => ThemeMode.system,
      AppThemeModeEnum.light => ThemeMode.light,
      AppThemeModeEnum.dark => ThemeMode.dark,
    };
  }
}

