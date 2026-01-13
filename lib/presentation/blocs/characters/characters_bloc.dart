import 'dart:async';
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
  StreamSubscription? _favoritesSubscription;

  CharactersBloc(this._repository) : super(const CharactersState.initial()) {
    _favoritesSubscription = _repository.watchFavorites.listen((characterId) async {
       final isFavorite = await _repository.isFavorite(characterId);
       add(CharactersEvent.updateFavoriteStatus(characterId, isFavorite));
    });

    on<CharactersEvent>((event, emit) async {
      await event.when(
        fetch: () => _onFetch(emit),
        toggleFavorite: (characterId) => _onToggleFavorite(characterId, emit),
        refresh: () => _onRefresh(emit),
        updateFavoriteStatus: (id, isFav) => _onUpdateFavoriteStatus(id, isFav, emit),
      );
    });
  }

  @override
  Future<void> close() {
    _favoritesSubscription?.cancel();
    return super.close();
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
    // UI update will be handled by the stream listener in watchFavorites
  }

  Future<void> _onUpdateFavoriteStatus(int characterId, bool isFavorite, Emitter<CharactersState> emit) async {
    final currentState = state;
    if (currentState is _Loaded) {
      final updatedCharacters = currentState.characters.map((c) {
        if (c.id == characterId) {
          if (c.isFavorite == isFavorite) return c; // No change needed
          return c.copyWith(isFavorite: isFavorite);
        }
        return c;
      }).toList();
      
      // Only emit if there's an actual change in the list
      bool hasChange = false;
      for (int i = 0; i < currentState.characters.length; i++) {
        if (currentState.characters[i] != updatedCharacters[i]) {
          hasChange = true;
          break;
        }
      }
      
      if (hasChange) {
        emit(CharactersState.loaded(characters: updatedCharacters));
      }
    }
  }
}
