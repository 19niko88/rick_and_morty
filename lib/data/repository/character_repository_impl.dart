import 'package:injectable/injectable.dart';
import '../../domain/models/character/character.dart';
import '../../domain/repository/character_repository.dart';
import '../local/character_local_data_source.dart';
import '../remote/rick_and_morty_api.dart';
import 'package:dio/dio.dart';

@LazySingleton(as: CharacterRepository)
class CharacterRepositoryImpl implements CharacterRepository {
  final RickAndMortyApi _api;
  final CharacterLocalDataSource _localDataSource;

  CharacterRepositoryImpl(this._api, this._localDataSource);

  @override
  Future<List<Character>> getCharacters(int page) async {
    try {
      final response = await _api.character(page);
      final characters = response.results;
      
      // Cache characters
      await _localDataSource.cacheCharacters(characters);
      
      // Enhance with favorite status
      return await _enhanceWithFavorites(characters);
    } catch (e) {
      if (e is DioException) {
        // Fallback to cache if offline
        final cached = await _localDataSource.getCachedCharacters();
        if (cached.isNotEmpty) {
           return await _enhanceWithFavorites(cached);
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
      // Try to fetch newest data for favorites from API
      final idsString = favoriteIds.join(',');
      final characters = await _api.characterByIds(idsString);
      return characters.map((e) => e.copyWith(isFavorite: true)).toList();
    } catch (e) {
      // Fallback to cached characters if offline
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

  Future<List<Character>> _enhanceWithFavorites(List<Character> characters) async {
    final favoriteIds = await _localDataSource.getFavoriteIds();
    return characters.map((c) {
      return c.copyWith(isFavorite: favoriteIds.contains(c.id));
    }).toList();
  }
}
