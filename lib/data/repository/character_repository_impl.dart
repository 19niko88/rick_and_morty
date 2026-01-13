import 'package:injectable/injectable.dart';
import '../../config/locator/service_locator.dart';
import '../../domain/models/character/character.dart';
import '../../domain/repository/character_repository.dart';
import '../local/character_local_data_source.dart';
import '../remote/rick_and_morty_api.dart';
import 'package:dio/dio.dart';

@LazySingleton(as: CharacterRepository)
class CharacterRepositoryImpl implements CharacterRepository {

  final CharacterLocalDataSource _localDataSource;

  CharacterRepositoryImpl(this._localDataSource);

  @override
  Future<Character> getCharacterById(int id) async {
    try {
      final character = await getIt<RickAndMortyApi>().characterById(id);
      final isFav = await _localDataSource.isFavorite(id);
      return character.copyWith(isFavorite: isFav);
    } catch (e) {
      if (e is DioException || e is StateError) {
        final cached = await _localDataSource.getCachedCharacters();
        final character = cached.cast<Character?>().firstWhere(
          (c) => c?.id == id,
          orElse: () => null,
        );
        
        if (character != null) {
          final isFav = await _localDataSource.isFavorite(id);
          return character.copyWith(isFavorite: isFav);
        }
        
        throw Exception('Data not available offline');
      }
      rethrow;
    }
  }

  @override
  Future<(List<Character>, bool)> getCharacters(
    int page, {
    String? name,
    String? status,
    String? species,
    String? type,
    String? gender,
  }) async {
    try {
      final response = await getIt<RickAndMortyApi>().character(
        page,
        name: name,
        status: status,
        species: species,
        type: type,
        gender: gender,
      );
      final characters = response.results;
      final hasNext = response.info.next != null;

      await _localDataSource.cacheCharacters(characters);

      return (await _enhanceWithFavorites(characters), hasNext);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          return (<Character>[], false);
        }

        final cached = await _localDataSource.getCachedCharacters();
        if (cached.isNotEmpty) {
          final filtered = cached.where((c) {
            bool matches = true;
            if (name != null && !c.name.toLowerCase().contains(name.toLowerCase())) {
              matches = false;
            }
            if (status != null && c.status.toLowerCase() != status.toLowerCase()) {
              matches = false;
            }
            if (species != null && !c.species.toLowerCase().contains(species.toLowerCase())) {
              matches = false;
            }
            if (type != null && !c.type.toLowerCase().contains(type.toLowerCase())) {
              matches = false;
            }
            if (gender != null && c.gender.toLowerCase() != gender.toLowerCase()) {
              matches = false;
            }
            return matches;
          }).toList();

          if (page == 1) {
            return (await _enhanceWithFavorites(filtered), false);
          } else {
            return (<Character>[], false);
          }
        }
      }
      rethrow;
    }
  }

  @override
  Future<List<Character>> getFavorites() async {
    final favoriteIds = await _localDataSource.getFavoriteIds();
    if (favoriteIds.isEmpty) return [];

    try {
      final idsString = favoriteIds.join(',');
      final characters = await getIt<RickAndMortyApi>().characterByIds(idsString);
      return characters.map((e) => e.copyWith(isFavorite: true)).toList();
    } catch (e) {
      final cached = await _localDataSource.getCachedCharacters();
      return cached
          .where((c) => favoriteIds.contains(c.id))
          .map((e) => e.copyWith(isFavorite: true))
          .toList();
    }
  }

  @override
  Future<void> toggleFavorite(int characterId) async {
    await _localDataSource.toggleFavorite(characterId);
  }

  @override
  Future<bool> isFavorite(int characterId) async {
    return await _localDataSource.isFavorite(characterId);
  }

  @override
  Stream<int> get watchFavorites async* {
    final stream = await _localDataSource.watchFavorites();
    yield* stream.map((event) => event.key as int);
  }

  Future<List<Character>> _enhanceWithFavorites(
    List<Character> characters,
  ) async {
    final favoriteIds = await _localDataSource.getFavoriteIds();
    return characters.map((c) {
      return c.copyWith(isFavorite: favoriteIds.contains(c.id));
    }).toList();
  }
}
