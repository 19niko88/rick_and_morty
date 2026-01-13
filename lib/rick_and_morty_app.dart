import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/presentation/blocs/characters/characters_bloc.dart';
import 'package:rick_and_morty/presentation/blocs/favorites/favorites_bloc.dart';
import 'package:rick_and_morty/config/locator/service_locator.dart';
import 'package:rick_and_morty/presentation/screens/home/home_screen.dart';

class RickAndMortyApp extends StatelessWidget {
  const RickAndMortyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<CharactersBloc>()),
        BlocProvider(create: (context) => getIt<FavoritesBloc>()),
      ],
      child: MaterialApp(
        title: 'Rick & Morty',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.lightGreen,
            brightness: Brightness.light,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
