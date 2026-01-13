import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rick_and_morty/config/config.dart';
import 'package:rick_and_morty/domain/domain.dart';
import 'package:rick_and_morty/presentation/screens/favorites/bloc/favorites_bloc.dart';
import 'package:rick_and_morty/presentation/widgets/widgets.dart';



@RoutePage()
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FavoritesBloc>()..add(const FavoritesEvent.fetch()),
      child: const _FavoritesView(),
    );
  }
}

class _FavoritesView extends StatelessWidget {
  const _FavoritesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: true,
        actions: [
          BlocBuilder<FavoritesBloc, FavoritesState>(
            buildWhen: (previous, current) => current.maybeMap(
              loaded: (_) => true,
              orElse: () => false,
            ),
            builder: (context, state) {
              final sortBy = state.maybeMap(
                loaded: (s) => s.sortBy,
                orElse: () => FavoriteSortEnum.name,
              );
              return PopupMenuButton<FavoriteSortEnum>(
                icon: const Icon(Icons.sort),
                initialValue: sortBy,
                onSelected: (sort) {
                  context.read<FavoritesBloc>().add(FavoritesEvent.changeSort(sort));
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: FavoriteSortEnum.name,
                    child: Text('Sort by Name'),
                  ),
                  const PopupMenuItem(
                    value: FavoriteSortEnum.status,
                    child: Text('Sort by Status'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (characters, sortBy) {
              if (characters.isEmpty) {
                return const Center(child: Text('No favorites yet'));
              }

              return ListView.separated(
                padding: EdgeInsets.all(16.sp),
                itemCount: characters.length,
                separatorBuilder: (context, index) => SizedBox(height: 12.sp),
                itemBuilder: (context, index) {
                  final character = characters[index];
                  return CharacterCard(
                    character: character,
                    heroTag: 'fav_${character.id}',
                    onFavoriteToggle: () {
                      context.read<FavoritesBloc>().add(
                            FavoritesEvent.removeFromFavorites(character.id),
                          );
                    },
                  );
                },
              );
            },
            error: (message) => Center(child: Text('Error: $message')),
          );
        },
      ),
    );
  }
}
