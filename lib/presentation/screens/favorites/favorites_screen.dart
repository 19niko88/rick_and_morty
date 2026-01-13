import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/favorites/favorites_bloc.dart';
import '../../widgets/character_card.dart';
import '../../../domain/models/character/character.dart';

enum FavoriteSort { name, status }

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  FavoriteSort _sortBy = FavoriteSort.name;

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
          PopupMenuButton<FavoriteSort>(
            icon: const Icon(Icons.sort),
            onSelected: (sort) {
              setState(() {
                _sortBy = sort;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: FavoriteSort.name,
                child: Text('Sort by Name'),
              ),
              const PopupMenuItem(
                value: FavoriteSort.status,
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
    if (_sortBy == FavoriteSort.name) {
      sortedList.sort((a, b) => a.name.compareTo(b.name));
    } else {
      sortedList.sort((a, b) => a.status.compareTo(b.status));
    }
    return sortedList;
  }
}
