import 'dart:async';
import 'package:rick_and_morty/config/config.dart';
import 'package:rick_and_morty/domain/domain.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';
part 'favorites_bloc.freezed.dart';

@injectable
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  StreamSubscription? _favoritesSubscription;

  FavoritesBloc() : super(const FavoritesState.initial()) {
    _favoritesSubscription = getIt<CharacterRepository>().watchFavorites.listen((_) {
      add(const FavoritesEvent.fetch());
    });

    on<FavoritesEvent>((event, emit) async {
      await event.when(
        fetch: () => _onFetch(emit),
        changeSort: (sortBy) => _onChangeSort(sortBy, emit),
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
      final characters = await getIt<CharacterRepository>().getFavorites();
      final currentState = state;
      final sortBy = currentState is _Loaded ? currentState.sortBy : FavoriteSortEnum.name;
      
      emit(FavoritesState.loaded(
        characters: _sortCharacters(characters, sortBy),
        sortBy: sortBy,
      ));
    } catch (e) {
      emit(FavoritesState.error(message: e.toString()));
    }
  }

  Future<void> _onChangeSort(FavoriteSortEnum sortBy, Emitter<FavoritesState> emit) async {
    final currentState = state;
    if (currentState is _Loaded) {
      emit(currentState.copyWith(
        characters: _sortCharacters(currentState.characters, sortBy),
        sortBy: sortBy,
      ));
    }
  }

  Future<void> _onRemove(int characterId, Emitter<FavoritesState> emit) async {
    await getIt<CharacterRepository>().toggleFavorite(characterId);
    
    final currentState = state;
    if (currentState is _Loaded) {
      final updatedCharacters = currentState.characters.where((c) => c.id != characterId).toList();
      emit(currentState.copyWith(
        characters: _sortCharacters(updatedCharacters, currentState.sortBy),
      ));
    }
  }

  List<Character> _sortCharacters(List<Character> characters, FavoriteSortEnum sortBy) {
    final List<Character> sortedList = List.from(characters);
    if (sortBy == FavoriteSortEnum.name) {
      sortedList.sort((a, b) => a.name.compareTo(b.name));
    } else {
      sortedList.sort((a, b) => a.status.compareTo(b.status));
    }
    return sortedList;
  }
}
