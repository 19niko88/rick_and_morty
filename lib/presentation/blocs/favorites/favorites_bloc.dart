import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/models/character/character.dart';
import '../../../domain/repository/character_repository.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';
part 'favorites_bloc.freezed.dart';

@injectable
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final CharacterRepository _repository;
  StreamSubscription? _favoritesSubscription;

  FavoritesBloc(this._repository) : super(const FavoritesState.initial()) {
    _favoritesSubscription = _repository.watchFavorites.listen((_) {
      add(const FavoritesEvent.fetch());
    });

    on<FavoritesEvent>((event, emit) async {
      await event.when(
        fetch: () => _onFetch(emit),
        removeFromFavorites: (characterId) => _onRemove(characterId, emit),
      );
    });
  }

  @override
  Future<void> close() {
    _favoritesSubscription?.cancel();
    return super.close();
  }

  Future<void> _onFetch(Emitter<FavoritesState> emit) async {
    emit(const FavoritesState.loading());
    try {
      final characters = await _repository.getFavorites();
      emit(FavoritesState.loaded(characters: characters));
    } catch (e) {
      emit(FavoritesState.error(message: e.toString()));
    }
  }

  Future<void> _onRemove(int characterId, Emitter<FavoritesState> emit) async {
    await _repository.toggleFavorite(characterId);
    
    final currentState = state;
    if (currentState is _Loaded) {
      final updatedCharacters = currentState.characters.where((c) => c.id != characterId).toList();
      emit(FavoritesState.loaded(characters: updatedCharacters));
    }
  }
}
