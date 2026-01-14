import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import '../../presentation/screens/characters/character_list_screen.dart';
import '../../presentation/screens/favorites/favorites_screen.dart';
import '../../presentation/screens/characters_detail/character_details_screen.dart';
import '../../presentation/screens/navigation/navigation_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          path: '/',
          page: NavigationRoute.page,
          children: [
            AutoRoute(path: 'characters', page: CharacterListRoute.page),
            AutoRoute(path: 'favorites', page: FavoritesRoute.page),
          ],
        ),
        AutoRoute(path: '/details/:id', page: CharacterDetailsRoute.page),
      ];
}
