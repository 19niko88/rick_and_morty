import 'dart:async';
import 'package:rick_and_morty/config/config.dart';
import 'package:rick_and_morty/domain/domain.dart';

part 'characters_event.dart';
part 'characters_state.dart';
part 'characters_bloc.freezed.dart';

@injectable
class CharactersBloc extends Bloc<CharactersEvent, CharactersState> {

  int _currentPage = 1;
  StreamSubscription? _favoritesSubscription;

  bool _isFetching = false;

  CharactersBloc() : super(const CharactersState.initial()) {
    _favoritesSubscription = getIt<CharacterRepository>().watchFavorites.listen((characterId) async {
       final isFavorite = await getIt<CharacterRepository>().isFavorite(characterId);
       add(CharactersEvent.updateFavoriteStatus(characterId, isFavorite));
    });

    on<CharactersEvent>((event, emit) async {
      await event.when(
        fetch: () => _onFetch(emit),
        toggleFavorite: (characterId) => _onToggleFavorite(characterId, emit),
        refresh: () => _onRefresh(emit),
        updateFavoriteStatus: (id, isFav) => _onUpdateFavoriteStatus(id, isFav, emit),
        updateFilters: (name, status, species, type, gender) => 
            _onUpdateFilters(emit, name, status, species, type, gender),
        clearFilters: () => _onClearFilters(emit),
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
    if (currentState is _Loaded && currentState.hasReachedMax) return;
    if (_isFetching) return;
    _isFetching = true;

    List<Character> oldCharacters = [];
    String? name, status, species, type, gender;

    if (currentState is _Loaded) {
      oldCharacters = currentState.characters;
      name = currentState.name;
      status = currentState.status;
      species = currentState.species;
      type = currentState.type;
      gender = currentState.gender;
    }

    if (_currentPage == 1) {
      emit(const CharactersState.loading());
    }

    try {
      final (newCharacters, hasNext) = await getIt<CharacterRepository>().getCharacters(
        _currentPage,
        name: name,
        status: status,
        species: species,
        type: type,
        gender: gender,
      );
      
      final reachedEnd = !hasNext || newCharacters.isEmpty || newCharacters.length < 20;
      
      final allCharacters = [...oldCharacters, ...newCharacters];
      // Ensure unique characters by ID
      final Map<int, Character> uniqueMap = {
        for (final c in allCharacters) c.id: c
      };
      
      emit(CharactersState.loaded(
        characters: uniqueMap.values.toList(),
        hasReachedMax: reachedEnd,
        name: name,
        status: status,
        species: species,
        type: type,
        gender: gender,
      ));
      if (!reachedEnd) {
        _currentPage++;
      }
    } catch (e) {
      if (_currentPage == 1) {
        emit(CharactersState.error(message: e.toString()));
      } else {
         if (state is _Loaded) {
           emit((state as _Loaded).copyWith(hasReachedMax: true));
         }
      }
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _onRefresh(Emitter<CharactersState> emit) async {
    _currentPage = 1;
    _isFetching = true;
    String? name, status, species, type, gender;
    
    if (state is _Loaded) {
      final s = state as _Loaded;
      name = s.name;
      status = s.status;
      species = s.species;
      type = s.type;
      gender = s.gender;
    }

    emit(const CharactersState.loading());
    try {
      final (characters, hasNext) = await getIt<CharacterRepository>().getCharacters(
        _currentPage,
        name: name,
        status: status,
        species: species,
        type: type,
        gender: gender,
      );
      final reachedEnd = !hasNext || characters.isEmpty || characters.length < 20;
      emit(CharactersState.loaded(
        characters: characters,
        hasReachedMax: reachedEnd,
        name: name,
        status: status,
        species: species,
        type: type,
        gender: gender,
      ));
      if (!reachedEnd) {
        _currentPage++;
      }
    } catch (e) {
      emit(CharactersState.error(message: e.toString()));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _onUpdateFilters(
    Emitter<CharactersState> emit,
    String? name,
    String? status,
    String? species,
    String? type,
    String? gender,
  ) async {
    _currentPage = 1;
    _isFetching = true;
    emit(const CharactersState.loading());
    try {
      final (characters, hasNext) = await getIt<CharacterRepository>().getCharacters(
        _currentPage,
        name: name,
        status: status,
        species: species,
        type: type,
        gender: gender,
      );
      final reachedEnd = !hasNext || characters.isEmpty || characters.length < 20;
      emit(CharactersState.loaded(
        characters: characters,
        hasReachedMax: reachedEnd,
        name: name,
        status: status,
        species: species,
        type: type,
        gender: gender,
      ));
      if (!reachedEnd) {
        _currentPage++;
      }
    } catch (e) {
      emit(CharactersState.error(message: e.toString()));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _onClearFilters(Emitter<CharactersState> emit) async {
    _currentPage = 1;
    _isFetching = true;
    emit(const CharactersState.loading());
    try {
      final (characters, hasNext) = await getIt<CharacterRepository>().getCharacters(_currentPage);
      final reachedEnd = !hasNext || characters.isEmpty || characters.length < 20;
      emit(CharactersState.loaded(
        characters: characters,
        hasReachedMax: reachedEnd,
      ));
      if (!reachedEnd) {
        _currentPage++;
      }
    } catch (e) {
      emit(CharactersState.error(message: e.toString()));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _onToggleFavorite(int characterId, Emitter<CharactersState> emit) async {
    await getIt<CharacterRepository>().toggleFavorite(characterId);
    // UI update will be handled by the stream listener in watchFavorites
  }

  Future<void> _onUpdateFavoriteStatus(int characterId, bool isFavorite, Emitter<CharactersState> emit) async {
    final currentState = state;
    if (currentState is _Loaded) {
      final updatedCharacters = currentState.characters.map((c) {
        if (c.id == characterId) {
          return c.copyWith(isFavorite: isFavorite);
        }
        return c;
      }).toList();
      
      emit(currentState.copyWith(characters: updatedCharacters));
    }
  }
}
