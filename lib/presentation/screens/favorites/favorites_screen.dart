import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:rick_and_morty/config/config.dart';
import 'package:rick_and_morty/domain/domain.dart';
import 'package:rick_and_morty/presentation/blocs/favorites/favorites_bloc.dart';
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

class _FavoritesView extends StatefulWidget {
  const _FavoritesView();

  @override
  State<_FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<_FavoritesView> {

  FavoriteSortEnum _sortBy = FavoriteSortEnum.name;

  @override
  void initState() {
    super.initState();
    context.read<FavoritesBloc>().add(const FavoritesEvent.fetch());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: true,
        actions: [
          PopupMenuButton<FavoriteSortEnum>(
            icon: const Icon(Icons.sort),
            onSelected: (sort) {
              setState(() {
                _sortBy = sort;
              });
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
          ),
        ],
      ),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (characters) {
              if (characters.isEmpty) {
                return const Center(child: Text('No favorites yet'));
              }

              final sortedCharacters = _sortCharacters(characters);

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: sortedCharacters.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final character = sortedCharacters[index];
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

  List<Character> _sortCharacters(List<Character> characters) {
    final List<Character> sortedList = List.from(characters);
    if (_sortBy == FavoriteSortEnum.name) {
      sortedList.sort((a, b) => a.name.compareTo(b.name));
    } else {
      sortedList.sort((a, b) => a.status.compareTo(b.status));
    }
    return sortedList;
  }
}
