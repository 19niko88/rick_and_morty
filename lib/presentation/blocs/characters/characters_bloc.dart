import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/models/character/character.dart';
import '../../../domain/repository/character_repository.dart';

part 'characters_event.dart';
part 'characters_state.dart';
part 'characters_bloc.freezed.dart';

@injectable
class CharactersBloc extends Bloc<CharactersEvent, CharactersState> {
  final CharacterRepository _repository;
  int _currentPage = 1;

  CharactersBloc(this._repository) : super(const CharactersState.initial()) {
    on<CharactersEvent>((event, emit) async {
      await event.when(
        fetch: () => _onFetch(emit),
        toggleFavorite: (characterId) => _onToggleFavorite(characterId, emit),
        refresh: () => _onRefresh(emit),
      );
    });
  }

  Future<void> _onFetch(Emitter<CharactersState> emit) async {
    final currentState = state;
    List<Character> oldCharacters = [];
    if (currentState is _Loaded) {
      oldCharacters = currentState.characters;
    }

    if (_currentPage == 1) {
      emit(const CharactersState.loading());
    }

    try {
      final newCharacters = await _repository.getCharacters(_currentPage);
      emit(CharactersState.loaded(characters: [...oldCharacters, ...newCharacters]));
      _currentPage++;
    } catch (e) {
      emit(CharactersState.error(message: e.toString()));
    }
  }

  Future<void> _onRefresh(Emitter<CharactersState> emit) async {
    _currentPage = 1;
    emit(const CharactersState.loading());
    try {
      final characters = await _repository.getCharacters(_currentPage);
      emit(CharactersState.loaded(characters: characters));
      _currentPage++;
    } catch (e) {
      emit(CharactersState.error(message: e.toString()));
    }
  }

  Future<void> _onToggleFavorite(int characterId, Emitter<CharactersState> emit) async {
    await _repository.toggleFavorite(characterId);
    
    final currentState = state;
    if (currentState is _Loaded) {
      final updatedCharacters = currentState.characters.map((c) {
        if (c.id == characterId) {
          return c.copyWith(isFavorite: !c.isFavorite);
        }
        return c;
      }).toList();
      emit(CharactersState.loaded(characters: updatedCharacters));
    }
  }
}
