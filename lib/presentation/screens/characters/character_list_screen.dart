import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/characters/characters_bloc.dart';
import '../../widgets/character_card.dart';
import '../../../config/locator/service_locator.dart';

class CharacterListScreen extends StatefulWidget {
  const CharacterListScreen({super.key});

  @override
  State<CharacterListScreen> createState() => _CharacterListScreenState();
}

class _CharacterListScreenState extends State<CharacterListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      context.read<CharactersBloc>().add(const CharactersEvent.fetch());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Characters'),
        centerTitle: true,
      ),
      body: BlocBuilder<CharactersBloc, CharactersState>(
        builder: (context, state) {
          return state.when(
            initial: () {
              context.read<CharactersBloc>().add(const CharactersEvent.fetch());
              return const Center(child: CircularProgressIndicator());
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (characters) {
              if (characters.isEmpty) {
                return const Center(child: Text('No characters found'));
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<CharactersBloc>().add(const CharactersEvent.refresh());
                },
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: characters.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final character = characters[index];
                    return CharacterCard(
                      character: character,
                      onFavoriteToggle: () {
                        context.read<CharactersBloc>().add(
                              CharactersEvent.toggleFavorite(character.id),
                            );
                      },
                    );
                  },
                ),
              );
            },
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $message'),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CharactersBloc>().add(const CharactersEvent.refresh());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
